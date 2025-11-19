# Relatório 1 – Acompanhamento de Leads (Campanhas / Tráfego Pago)

Este documento descreve os parâmetros e KPIs do relatório de **acompanhamento de leads**, que possui três abas:

- **Leads campanhas**
- **Leads tráfego pago**
- **Geral** (ticket médio e conversão por colaborador)

Todos os visuais usam o mesmo modelo SQL:  
`sql/base_modelo_campanha_trafego_pago.sql`

---

## 1. Filtros globais

### 1.1. Período

- Leads são contados com base em: **`data_inicio`** (`begindate` do negócio).
- Ganhos/Não ganhos podem considerar também `data_fechamento` em alguns visuais, dependendo do filtro do BI.

### 1.2. Separação Campanhas x Tráfego Pago

É feita pelo campo customizado:

- **Campo:** `campanha_trafego_pago` (`UF_CRM_1711127061`)

Regras:

- **Leads campanhas** → `campanha_trafego_pago LIKE '%CAMPANHA%'`
- **Leads tráfego pago** → `campanha_trafego_pago = 'TRÁFEGO PAGO'`
- **Geral** → pode incluir ambos, ou apenas somar tudo (sem filtro), de acordo com a configuração.

---

## 2. Aba “Leads campanhas”

### 2.1. Cards superiores

- **Total**  
  Quantidade total de leads de campanhas no período.  
  > `COUNT(DISTINCT negocio_id)`  
  > Filtros: `campanha_trafego_pago LIKE '%CAMPANHA%'` e `data_inicio` no período.

- **Ganhos**  
  Negócios de campanhas com status ganho.  
  > `COUNT(DISTINCT negocio_id)`  
  > Filtros:  
  > - `campanha_trafego_pago LIKE '%CAMPANHA%'`  
  > - `etapa_semantica = 'Sucesso'` (ou `stage_semantic_id = 'S'`)  

- **Não ganho**  
  Negócios de campanhas perdidos.  
  > `COUNT(DISTINCT negocio_id)`  
  > Filtros:  
  > - `campanha_trafego_pago LIKE '%CAMPANHA%'`  
  > - `etapa_semantica = 'Perdido'`

- **Conversão (%)**  
  > `ganhos / total * 100`

### 2.2. Gráfico “Ganhos” (barras por dia)

- **Eixo X:** `data_fechamento` (dia).
- **Medida:** `COUNT(DISTINCT negocio_id)` com `etapa_semantica = 'Sucesso'`.
- **Filtro origem:** `campanha_trafego_pago LIKE '%CAMPANHA%'`.

### 2.3. Gráfico “Total de leads” (barras por dia)

- **Eixo X:** `data_inicio`.
- **Medida:** `COUNT(DISTINCT negocio_id)`.
- **Filtro:** `campanha_trafego_pago LIKE '%CAMPANHA%'`.

---

## 3. Aba “Leads tráfego pago”

A lógica é a mesma da aba “Leads campanhas”, mudando apenas o filtro de origem.

### 3.1. Filtros

- **Origem:** `campanha_trafego_pago = 'TRÁFEGO PAGO'`
- **Período:** baseado em `data_inicio` (leads) e `data_fechamento` (ganhos).

### 3.2. Cards

- **Total**  
  `COUNT(DISTINCT negocio_id)` com `campanha_trafego_pago = 'TRÁFEGO PAGO'`.

- **Ganhos**  
  `COUNT(DISTINCT negocio_id)` com
  - `campanha_trafego_pago = 'TRÁFEGO PAGO'`
  - `etapa_semantica = 'Sucesso'`.

- **Não ganho**  
  `COUNT(DISTINCT negocio_id)` com
  - `campanha_trafego_pago = 'TRÁFEGO PAGO'`
  - `etapa_semantica = 'Perdido'`.

- **Conversão (%)**  
  `ganhos / total * 100`.

### 3.3. Gráficos

- **Ganhos por dia** → `data_fechamento` x `COUNT(DISTINCT negocio_id)`.
- **Quantidade de leads por dia** → `data_inicio` x `COUNT(DISTINCT negocio_id)`.

---

## 4. Aba “Geral” – Ticket médio e Conversão por colaborador

### 4.1. Vendas por Colaborador

**Campos:**

- Agrupamento: `responsavel_nome`.
- Medidas:
  - **Ticket Médio** → `SUM(valor_negocio_ganho) / COUNT(DISTINCT negocio_id_ganho)`
  - **Vendido** → `SUM(valor_negocio_ganho)`.

**Filtros:**

- Apenas negócios ganhos (`etapa_semantica = 'Sucesso'`).
- Origem: pode considerar **todas** (campanhas + tráfego pago) ou apenas campanhas, conforme definição com o cliente.

### 4.2. Conversão por colaborador

**Campos:**

- Agrupamento: `responsavel_nome`.
- Medidas:
  - **Leads atendidos** → `COUNT(DISTINCT negocio_id)` por responsável.
  - **Ganhos** → `COUNT(DISTINCT negocio_id)` com `etapa_semantica = 'Sucesso'`.

**Fórmula da conversão:**

```text
Conversão (%) = negócios ganhos / total de leads do responsável * 100
```

5. Resumo conceitual

Este relatório responde:

Como está o volume diário de leads de campanhas e de tráfego pago;

Quantos viram negócios ganhos;

Qual a taxa de conversão e ticket médio por colaborador.

A separação Campanhas x Tráfego Pago é sempre feita pelo campo campanha_trafego_pago, usando:

LIKE '%CAMPANHA%' para campanhas;

= 'TRÁFEGO PAGO' para tráfego pago.