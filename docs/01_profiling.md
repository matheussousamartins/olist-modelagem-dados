# Perfil dos dados - Olist

Fonte: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).
Queries usadas: `sql/01_exploracao.sql`.

## 1. Volume por tabela

| Tabela | Linhas |
| --- | ---: |
| orders | 99.441 |
| customers | 99.441 |
| order_items | 112.650 |
| payments | 103.886 |
| order_reviews | 99.224 |
| products | 32.951 |
| sellers | 3.095 |
| geolocation | 1.000.163 |
| category_translation | 71 |

## 2. Chaves

| Tabela | Chave testada | Linhas | Distintos | Única? |
| --- | --- | ---: | ---: | --- |
| orders | order_id | 99.441 | 99.441 | sim |
| customers | customer_id | 99.441 | 99.441 | sim |
| customers | customer_unique_id | 99.441 | 96.096 | **não** |
| order_items | order_id | 112.650 | 98.666 | **não** |
| order_items | order_id, order_item_id | 112.650 | 112.650 | sim |
| payments | order_id | 103.886 | 99.440 | **não** |
| payments | order_id, payment_sequential | 103.886 | 103.886 | sim |
| order_reviews | review_id | 99.224 | 98.410 | **não** |
| order_reviews | order_id | 99.224 | 98.673 | **não** |
| order_reviews | review_id, order_id | 99.224 | 99.224 | sim |
| products | product_id | 32.951 | 32.951 | sim |
| sellers | seller_id | 3.095 | 3.095 | sim |
| geolocation | geolocation_zip_code_prefix | 1.000.163 | 19.015 | **não** |

## 3. Descobertas

### `customer_id` não representa a pessoa
- **O que vi:** `customer_id` tem 99.441 valores distintos, o mesmo número de pedidos.
  `customer_unique_id` tem 96.096. Só 2.997 pessoas (3,1%) compraram mais de uma vez.
- **O que significa:** a Olist gera um `customer_id` novo a cada pedido. A pessoa é o
  `customer_unique_id`.
- **Impacto no modelo:** a dimensão de cliente deve usar `customer_unique_id`. Usar
  `customer_id` contaria cada recompra como um cliente novo.

### A chave de `order_items` é composta
- **O que vi:** `order_id` se repete (112.650 linhas para 98.666 pedidos), mas a
  combinação `(order_id, order_item_id)` é única.
- **O que significa:** cada linha é um item dentro de um pedido; `order_item_id` é o
  número sequencial do item (1, 2, 3...).
- **Impacto no modelo:** o grão natural da fato de vendas é **um item de pedido**, com
  chave `(order_id, order_item_id)`.

### 775 pedidos sem nenhum item
- **O que vi:** `orders` tem 99.441 pedidos, mas só 98.666 aparecem em `order_items`.
  Status desses pedidos: `unavailable` (603), `canceled` (164), `created` (5),
  `invoiced` (2) e `shipped` (1).
- **O que significa:** 767 (99%) são pedidos que não se concretizaram: produto
  indisponível ou cancelamento. Os 3 restantes (`invoiced` e `shipped` sem itens) são
  inconsistência de dados.
- **Impacto no modelo:** os pedidos ficam na `fct_orders` com `items_qty = 0` e valores
  zerados, para que as taxas de cancelamento e de indisponibilidade possam ser calculadas.
  Não aparecem na `fct_order_items`, que só tem itens reais.

### Um pedido pode ter vários pagamentos
- **O que vi:** 103.886 pagamentos para 99.440 pedidos; a chave é
  `(order_id, payment_sequential)`.
- **O que significa:** o cliente pode dividir o pagamento em mais de uma forma
  (ex.: cartão + voucher).
- **Impacto no modelo:** pagamento tem grão próprio. Não dá para colocar o valor pago
  na fato de itens sem duplicar ou ratear, então pagamentos ganham uma fato separada.

### 1 pedido sem pagamento
- **O que vi:** o pedido `bfbd0f9bdef84302105ad712db648a6c` (set/2016) tem 3 itens
  (R$ 143,46 com frete) e status `delivered`, mas nenhum pagamento. O cliente deu nota 1
  e escreveu que não recebeu o produto.
- **O que significa:** o status contradiz a avaliação do cliente, e o pagamento pode não
  ter sido registrado. É do início da operação (2016), quando os dados eram menos
  consistentes.
- **Impacto no modelo:** o pedido é mantido. Na `fct_orders`, `payment_value` fica
  **nulo** (desconhecido), não zero, para não distorcer o ticket médio. Caso listado nas
  perguntas ao negócio.

### Avaliações e pedidos têm relação N:N
- **O que vi:** `review_id` não é único (98.410 distintos em 99.224 linhas) e `order_id`
  também não (98.673 distintos). A chave é `(review_id, order_id)`. 768 pedidos nunca
  foram avaliados.
- **O que significa:**
  - Um mesmo `review_id` em vários pedidos é **uma avaliação só**, do mesmo cliente
    (mesmo `customer_unique_id`, nota, comentário e data), replicada para pedidos feitos
    juntos.
  - Um pedido com vários `review_id` são **avaliações diferentes** em datas diferentes,
    e a nota pode mudar (ex.: 5 e depois 4).
- **Impacto no modelo:** na fato de pedidos, `review_score` = avaliação **mais recente**
  (maior `review_answer_timestamp`), por representar a opinião final do cliente. Pedidos
  sem avaliação ficam com nota nula, não zero.

### Colunas com grafia errada na origem
- **O que vi:** `products` tem `product_name_lenght` e `product_description_lenght`
  ("lenght" em vez de "length").
- **Impacto no modelo:** renomear para `name_length` e `description_length` na camada de
  staging. A origem não é alterada.

### CEP é texto, não número
- **O que vi:** os prefixos de CEP têm zeros à esquerda (ex.: `01001`). O DuckDB lê como
  texto porque o CSV traz os valores entre aspas; pandas e Excel leriam como número e
  perderiam o zero.
- **Impacto no modelo:** CEP é sempre `varchar` de 5 caracteres. Nenhum cálculo é feito
  com CEP, então não há motivo para ser numérico.

### `geolocation` não tem chave e tem dados sujos
- **O que vi:** 1.000.163 linhas para 19.015 CEPs (~53 pontos por CEP). 8.556 CEPs têm
  mais de uma grafia de cidade (ex.: `sao paulo`, `são paulo`, `sp` e `sa£o paulo`, este
  último um erro de codificação). 42 pontos estão fora do território brasileiro.
- **O que significa:** cada linha é um ponto de coordenada dentro da área de um prefixo de
  CEP. Os pontos de um mesmo CEP são próximos (ex.: CEP 01001 varia ~200 m).
- **Impacto no modelo:** `dim_geography` com uma linha por CEP: descartar pontos fora do
  Brasil, usar a mediana de lat/lng e padronizar a cidade (minúsculas, sem acento) antes
  de escolher a grafia mais frequente.

### Domínios de `order_status` e `payment_type`
- **O que vi:** `order_status` tem 8 valores: `delivered` (96.478), `shipped` (1.107),
  `canceled` (625), `unavailable` (609), `invoiced` (314), `processing` (301),
  `created` (5) e `approved` (2). `payment_type` tem 4 formas reais (cartão de crédito
  com ~78% do valor, boleto, voucher, débito) e `not_defined` (3 pagamentos, R$ 0).
  461 pedidos cancelados têm itens em `order_items`.
- **O que significa:** os status são etapas de um ciclo de vida; `canceled` e
  `unavailable` são finais sem venda. `not_defined` é registro sem forma de pagamento.
- **Impacto no modelo:** receita = pedidos com status diferente de `canceled` e
  `unavailable` ("receita vendida"). `order_status` entra nas fatos como dimensão
  degenerada, para permitir o filtro. `not_defined` fica fora das análises por forma de
  pagamento.

### Status e data de entrega nem sempre concordam
- **O que vi:** 8 pedidos `delivered` não têm `order_delivered_customer_date` (7 foram
  enviados à transportadora; 1, de mai/2017, nem isso). 6 pedidos `canceled` têm data de
  entrega ao cliente.
- **O que significa:** nos 8, a confirmação de entrega provavelmente não foi registrada.
  Nos 6, o pedido foi cancelado depois de entregue (provável devolução), e o dataset não
  tem status próprio para isso.
- **Impacto no modelo:** métricas de prazo (`delivery_days`, `is_late`) só são calculadas
  para pedidos `delivered` com data de entrega; nos demais ficam nulas. Os dois casos
  entram nas perguntas ao negócio.
  
### 2 categorias sem tradução
- **O que vi:** `pc_gamer` (3 produtos) e `portateis_cozinha_e_preparadores_de_alimentos`
  (10 produtos) existem em `products`, mas não em `category_translation`.
- **O que significa:** a tabela de tradução está incompleta; a relação entre as duas não
  tem integridade referencial.
- **Impacto no modelo:** na `dim_product`, `category_name_en` usa a tradução quando
  existe e, se não existir, o nome em português.

## 4. Nulos

| Tabela | Coluna | Nulos | % | Esperado? |
| --- | --- | ---: | ---: | --- |
| orders | order_approved_at | 160 | 0,16 | Sim: pedido ainda não aprovado ou cancelado |
| orders | order_delivered_carrier_date | 1.783 | 1,79 | Sim: pedido ainda não enviado ou cancelado |
| orders | order_delivered_customer_date | 2.965 | 2,98 | Sim, exceto 8 pedidos `delivered` (ver P8) |
| products | category, name_lenght, description_lenght, photos_qty | 610 | 1,85 | Não: os mesmos 610 produtos sem dados de catálogo |
| products | weight_g, length_cm, height_cm, width_cm | 2 | 0,01 | Não: produtos sem medidas |
| reviews | review_comment_title | 87.656 | 88,3 | Sim: campo opcional |
| reviews | review_comment_message | 58.247 | 58,7 | Sim: campo opcional |

`order_items`, `payments`, `customers` e `sellers` não têm nulos.

**Leitura:** os nulos de `orders` crescem ao longo do ciclo de vida (aprovação → envio →
entrega), porque cada data só é preenchida quando o pedido chega àquela etapa. Na
`dim_product`, categoria nula vira `'sem_categoria'`, para aparecer como grupo próprio
nas análises.