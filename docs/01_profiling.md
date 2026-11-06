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

## 3. Descobertas

### `customer_id` não representa a pessoa
- **O que vi:** `customer_id` tem 99.441 valores distintos, o mesmo número de pedidos.
  `customer_unique_id` tem 96.096.
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
- **O que significa:** _(preencher depois de ver o `order_status` desses pedidos)_
- **Impacto no modelo:** _(preencher)_

### Um pedido pode ter vários pagamentos
- **O que vi:** 103.886 pagamentos para 99.440 pedidos; a chave é
  `(order_id, payment_sequential)`.
- **O que significa:** o cliente pode dividir o pagamento em mais de uma forma
  (ex.: cartão + voucher).
- **Impacto no modelo:** pagamento tem grão próprio. Não dá para colocar o valor pago
  na fato de itens sem duplicar ou ratear, então pagamentos ganham uma fato separada.

### 1 pedido sem pagamento
- **O que vi:** 99.441 pedidos, mas só 99.440 aparecem em `payments`.
- **O que significa:** _(preencher depois de investigar o pedido)_
- **Impacto no modelo:** _(preencher)_

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

## 4. Pendências
- [ ] Status dos 775 pedidos sem itens
- [ ] Investigar o pedido sem pagamento
- [ ] P2: chaves de products, sellers, geolocation
- [ ] P3: quantas pessoas compraram mais de uma vez
- [ ] P4 a P8