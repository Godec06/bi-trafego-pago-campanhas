SELECT
  -- Campos do negócio (crm_deal)
  d.id AS negocio_id,
  d.date_create AS criado_em,
  d.date_modify AS modificado_em,
  d.assigned_by_id AS responsavel_id,
  d.assigned_by_name AS responsavel_nome,
  d.contact_id AS contato_id,
  d.contact_name AS contato_nome,
  d.title AS titulo_negocio,
  d.crm_product_id AS produto_id_crm,
  d.crm_product AS produto_nome_crm,
  d.crm_product_count AS quantidade_produtos_crm,
  d.category_id AS categoria_id,
  d.category_name AS categoria_nome,
  d.stage_id AS etapa_id,
  d.stage_name AS etapa_nome,
  d.stage_semantic_id AS etapa_semantica_id,
  d.stage_semantic AS etapa_semantica,
  d.closed AS fechado,
  d.type_id AS tipo_negocio,
  d.opportunity AS valor_negocio,
  d.comments AS observacoes,
  d.begindate AS data_inicio,
  d.closedate AS data_fechamento,
  d.source_id AS origem_id,
  d.source_name AS origem_nome,
  d.utm_source AS utm_source,
  d.utm_medium AS utm_medium,
  d.utm_campaign AS utm_campaign,
  d.utm_content AS utm_content,
  d.utm_term AS utm_term,

  p.id AS item_id,
  p.product_id AS produto_id,
  p.product_name AS produto_nome,
  p.price AS preco_unitario,
  p.quantity AS quantidade,
  p.price_brutto AS preco_total,
  p.discount_type_name AS tipo_desconto,
  p.measure_name AS unidade_medida,

  uf.UF_CRM_1711127061 AS campanhas_trafego-pago,
  uf.UF_CRM_1712601645 AS total_dias_funil

FROM crm_deal d
LEFT JOIN crm_deal_product_row p ON d.id = p.deal_id
LEFT JOIN crm_deal_uf uf ON d.id = uf.deal_id;