# Monitoramento de Leads e Performance de Tráfego Pago (Bitrix24 + BI)

Este projeto reúne **dois dashboards construídos no BI do Bitrix24** a partir de um **modelo único de dados em SQL**:

1. **Acompanhamento diário de leads** (Campanhas / Tráfego Pago)
2. **Performance de campanhas / tráfego pago** (funil, tempo de ciclo e faturamento)

O objetivo é dar visibilidade para o time comercial e de marketing sobre:
- Quantos leads entram por dia em cada origem;
- Quantos se tornam negócios ganhos ou perdidos;
- Taxa de conversão geral e por colaborador;
- Tempo médio de fechamento;
- Faturamento diário gerado pelas campanhas.

---

## 1. Arquitetura do projeto

```text
BI-TRAFEGO-PAGO--CAMPANHAS/
├── dashboards/             # Prints dos dashboards
├── docs/                   # Documentação detalhada de KPIs e parâmetros
├── sql/
│   └── base_modelo_campanha_trafego_pago.sql
└── README.md
```

Fonte de dados

Todos os dados vêm do CRM Bitrix24, usando o BI nativo com consulta SQL em cima das tabelas:

    crm_deal – negócios (deals)
    crm_deal_product_row – produtos vinculados ao negócio
    crm_deal_uf – campos personalizados

O modelo de dados está em:
sql/base_modelo_campanha_trafego_pago.sql

Obs.: não utilizo SELECT * na tabela crm_deal porque o BI do Bitrix24 não exibe corretamente os campos nesse caso.
Em vez disso, especifiquei coluna a coluna, o que melhora a performance e a clareza do modelo.

2. Modelo de dados (base SQL)

O modelo traz três blocos principais de informação:

 2.1. Dados do negócio (crm_deal)

  Alguns campos utilizados:

  ```textid``` – identificador do negócio
  
  ```textdate_create, date_modify``` – datas de criação e modificação
  
  ```textbegindate, closedate``` – data de entrada no funil e data de fechamento
  
  ```textassigned_by_id, assigned_by_name, assigned_by_department``` – responsável e equipe
  
  ```text company_id, company_name, contact_id, contact_name```– empresa e contato
  
  ```text category_id, category_name``` – funil / pipeline
  
  ```text stage_id, stage_name, stage_semantic_id, stage_semantic ```– etapa do funil e semântica (aberto/ganho/perdido)
  
  ```textopportunity, opportunity_account``` – valor do negócio e moeda
  
  ```textsource_id, source_name, source_description``` – origem do lead
  
  ```textutm_source, utm_medium, utm_campaign, utm_content, utm_term``` – parâmetros de marketing

 2.2. Dados de produto (crm_deal_product_row)

   ```textproduct_id, product_name```

   ```textprice``` (preço unitário)

   ```textquantity``` (quantidade)

   ```textprice_brutto``` (preço total)

   ```textmeasure_name``` (unidade de medida)

 2.3. Campos personalizados (crm_deal_uf)

   ```textUF_CRM_1711127061``` – campanhas_trafego-pago (para idenitificarmos de qual campanhas veio o lead)

   ```textUF_CRM_1712601645``` como total_dias_funil – total de dias que o negócio permaneceu no funil

Esse modelo único alimenta tanto o dashboard de acompanhamento diário quanto o dashboard de performance de campanhas / tráfego pago, garantindo que todos os relatórios conversem entre si.

3. Dashboard 1 – Acompanhamento diário de leads (Campanhas / Tráfego Pago)

  Painel focado em monitoramento operacional diário.

 3.1. Objetivo

 Acompanhar quantos leads entram por dia em campanhas e tráfego pago;

 Ver quantos negócios são ganhos por dia;

  Medir a taxa de conversão e o ticket médio por colaborador;

  Apoiar o gestor em decisões rápidas de operação (exa.: aumento de leads, queda de conversão, etc.).

 3.2. Principais KPIs

  Total de leads
  Número de negócios que entraram no período.

  COUNT(DISTINCT negocio_id) filtrando por data de início (begindate) e origem (campanhas / tráfego pago).

  Ganhos
  Negócios com status de ganho no período.

  ```textCOUNT(DISTINCT negocio_id)
    WHERE stage_name = 'Negócio ganho'
```

  Não ganho
  Negócios classificados como perdidos.

   ```textCOUNT(DISTINCT negocio_id)
  WHERE stage_semantic = 'F' (perdido).
```
  Conversão (%)

  ganhos / total_de_leads * 100

  Ticket médio por colaborador (aba “Geral”)

   ```textSUM(valor_negocio) / COUNT(DISTINCT negocio_id_ganho)```
  agrupado por responsavel_nome.

 3.3. Visualizações

  Cards superiores

  Total de leads

  Ganhos

  Não ganhos

  Conversão (%)

  Gráfico de barras – Ganhos por dia
  Quantidade de negócios ganhos por data.

  Gráfico de barras – Quantidade de leads por dia
  Volume de negócios que entraram no funil em cada dia.

  Tabela / gráfico – Vendas por colaborador
  Ticket médio e valor vendido por cada responsável.

  Gráfico – Conversão por colaborador
  Taxa de conversão individual (% de negócios ganhos sobre leads atendidos).

  As imagens de referência estão na pasta dashboards/.

4. Dashboard 2 – Performance de campanhas / tráfego pago (funil + faturamento)

 Painel mais analítico, focado em qualidade do funil, tempo de ciclo e faturamento.

 4.1. Objetivo

  Avaliar se as campanhas de tráfego pago estão gerando leads qualificados;

  Entender em quanto tempo os negócios são fechados (ganhos e perdidos);

  Identificar etapas do funil com maior concentração de negócios;

  Acompanhar o faturamento por dia.

 4.2. KPIs principais

  Quantidade de ganhos (TRÁFEGO PAGO / CAMPANHAS)

   ```text COUNT(DISTINCT negocio_id)
  com filtro de origem (UTM ou source_name) e stage_semantic = 'S'.
```
  Tempo para negócio ganho – dias

  ```textAVG(DATEDIFF('day', data_inicio, data_fechamento))
  ou AVG(total_dias_funil) dependendo da implementação do cliente.
```
  Total de leads

   ```textCOUNT(DISTINCT negocio_id) filtrado por origem.```
  Tempo para negócios perdidos – dias

   ```textAVG(DATEDIFF('day', data_inicio, data_fechamento))
  com stage_semantic = 'F'.
```
  Quantidade de perdidos

  ```text COUNT(DISTINCT negocio_id) com stage_semantic = 'F'. ```
  
  Faturamento por dia

   ```textSUM(valor_negocio) por data_fechamento ```
   
  considerando apenas negócios ganhos.

  Entradas diárias

   ```text COUNT(DISTINCT negocio_id) por data_inicio. ```

 4.3. Visualizações

  Tabelas de ganhos e perdidos
  Listas de negócios com:

  Nome/ID do negócio

  Data de fechamento

  Dias em funil (total_dias_funil)

  Gráfico de etapas do funil
  Barra por stage_name, mostrando em que etapas os negócios estão concentrados.

  Entradas diárias de leads
  Gráfico de linha ou colunas por data de entrada.

  Faturamento por dia
  Gráfico de linha com o valor faturado por dia, permitindo enxergar picos de vendas.

  As versões para TRÁFEGO PAGO e CAMPANHAS são geradas a partir do mesmo modelo de dados, mudando apenas os filtros de origem.

5. Documentação de KPIs e parâmetros

 A documentação detalhada de cada métrica (filtros, fórmulas, semântica de etapas etc.) está sendo estruturada na pasta:

```text docs/ ```


 Arquivos sugeridos:

 ```textdocs/kpis_trafego_pago.md```

 ```textdocs/kpis_campanhas.md```

 Neles são descritos:

 ampos utilizados (do modelo SQL);

 Filtros aplicados (ex.: apenas categoria X, origem Y, intervalo de datas, etc.);

 Fórmulas exatas de cada KPI;

 Interpretação do indicador (como o gestor deve usar).

6. Tecnologias utilizadas

 Bitrix24 CRM – fonte de dados (tabelas de negócios e produtos)

 BI do Bitrix24 (SQL personalizado) – engine de consulta e criação de gráficos

 SQL (Trino/Presto) – linguagem utilizada no base_modelo_campanha_trafego_pago.sql

7. Possíveis evoluções

 Incluir custo de mídia por campanha para medir ROI e CAC;

 Criar alertas automáticos para queda brusca de conversão ou aumento de tempo médio no funil;

 Segmentar resultados por dispositivo, criativo ou grupo de anúncios (via UTMs).

Autor: 
Projeto desenvolvido por Pedro Rodrigues Godec

Estudante de Ciência de Dados e IA e estagiário na área de implantação de CRM/automação.
