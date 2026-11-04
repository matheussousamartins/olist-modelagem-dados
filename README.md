# olist-modelagem-dados

Projeto de modelagem de dados com o dataset público de e-commerce brasileiro da Olist.

## Estrutura

```
olist-modelagem-dados/
├── data/raw/        ← CSVs (fora do Git)
├── docs/            ← documentação
├── model/           ← diagramas e modelos de dados
├── sql/             ← scripts SQL
├── scripts/         ← scripts Python
├── .gitignore
├── requirements.txt
└── README.md
```

## Dados

Baixe o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) e coloque os CSVs em `data/raw/`.

## Setup

```bash
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -r requirements.txt
```
