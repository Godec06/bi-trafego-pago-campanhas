```markdown
# Relatório 2 – Performance de Campanhas e Tráfego Pago

Este relatório é dividido em **dois painéis**, ambos usando o mesmo modelo SQL:

- **Painel TRÁFEGO PAGO**
- **Painel CAMPANHAS**

A diferença entre os dois é apenas o **filtro aplicado no campo `campanha_trafego_pago`**.

---

## 1. Filtros por painel

### 1.1. Painel TRÁFEGO PAGO

- `campanha_trafego_pago = 'TRÁFEGO PAGO'`

### 1.2. Painel CAMPANHAS

- `campanha_trafego_pago LIKE '%CAMPANHA%'`

### 1.3. Período

- **Total de leads** → `data_inicio`
- **Ganhos/Perdidos, tempo de funil e faturamento** → `data_fechamento`  
- `total_dias_funil` já vem calculado pelo campo `UF_CRM_1712601645`.

---

## 2. Cards superiores

Para cada painel (TRÁFEGO PAGO e CAMPANHAS), os cards têm a mesma lógica:

### 2.1. Quantidade de ganhos

- **Medida:** `COUNT(DISTINCT negocio_id)`
- **Filtros:**
  - Origem (TRÁFEGO PAGO ou CAMPANHAS, conforme o painel)
  - `etapa_semantica = 'Sucesso'`
  - `data_fechamento` no período.

### 2.2. Tempo para negócio ganho – Dias

- **Medida:** média de dias para negócios ganhos.
- **Campos:**
  - Preferencialmente `total_dias_funil`.
  - Alternativa: `DATEDIFF('day', data_inicio, data_fechamento)`.

### 2.3. Total de leads

- **Medida:** `COUNT(DISTINCT negocio_id)`
- **Data base:** `data_inicio`.
- **Filtro:** apenas origem (TRÁFEGO PAGO ou CAMPANHAS).

### 2.4. Tempo para negócios perdidos – Dias

- **Medida:** média de dias até marcar o negócio como perdido.
- **Filtro:** `etapa_semantica = 'Perdido'`.
- **Campo de data:** `total_dias_funil` ou `DATEDIFF`.

### 2.5. Quantidade perdidos

- **Medida:** `COUNT(DISTINCT negocio_id)`
- **Filtro:** `etapa_semantica = 'Perdido'`
- **Data:** `data_fechamento`.

---

## 3. Tabelas de Ganhos e Perdidos

### 3.1. Ganhos

Colunas típicas:

- `titulo_negocio`
- `negocio_id`
- `data_fechamento`
- `total_dias_funil`
- `campanha_trafego_pago`
- `responsavel_nome`
- `valor_negocio`

Filtro: `etapa_semantica = 'Sucesso'` + origem do painel.

### 3.2. Perdidos

Colunas:

- `titulo_negocio`
- `negocio_id`
- `data_fechamento`
- `total_dias_funil`
- `campanha_trafego_pago`
- `responsavel_nome`
- Motivo da perda (se houver campo específico).

Filtro: `etapa_semantica = 'Perdido'` + origem do painel.

---

## 4. Gráfico “Etapa negócios”

Mostra a distribuição dos negócios por etapa do funil.

- **Eixo X:** `etapa_nome` (`stage_name`)
- **Medida:** `COUNT(DISTINCT negocio_id)`
- **Filtros globais:** origem do painel + período.

Ajuda a identificar onde os leads travam (ex.: muitos negócios em “Aguardando Pagamento”).

---

## 5. Entradas diárias

Gráfico de linha que mostra quantos leads entraram por dia.

- **Eixo X:** `data_inicio`
- **Medida:** `COUNT(DISTINCT negocio_id)`
- **Filtros:** origem do painel + período.

---

## 6. Faturamento por dia

Gráfico de linha para acompanhar o valor faturado diariamente.

- **Eixo X:** `data_fechamento`
- **Medida:** `SUM(valor_negocio)` apenas para negócios ganhos.
- **Filtros:** origem do painel + `etapa_semantica = 'Sucesso'`.

---

## 7. Resumo


- Quanto cada origem (TRÁFEGO PAGO x CAMPANHAS) está gerando de:
  - Leads
  - Negócios ganhos
  - Negócios perdidos
  - Faturamento
- Em quanto tempo os leads percorrem o funil (ganhos e perdidos);
- Em quais etapas há maior concentração de negócios.

A inteligência está em:

- Usar **um único modelo SQL**;
- Separar os painéis apenas pelo campo `campanha_trafego_pago`;
- Documentar todas as regras de filtro e cálculo para evitar divergências de leitura entre times de marketing e vendas.