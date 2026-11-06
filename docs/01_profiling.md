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

## 4. Pendências
- [ ] Status dos 775 pedidos sem itens
- [ ] P2: chaves de payments, order_reviews, products, sellers, geolocation
- [ ] P3: quantas pessoas compraram mais de uma vez
- [ ] P4 a P8