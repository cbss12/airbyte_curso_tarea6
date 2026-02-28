-- obt_plc_tags.sql
-- Mart (OBT): tabla final desnormalizada para dashboards de monitoreo PLC.
-- Consolida toda la información necesaria en una sola tabla sin JOINs.
-- Materializada como TABLE para performance en herramientas BI.

with enriched as (

    select * from {{ ref('int_plc_tags_enriched') }}

),

final as (

    select
        -- Identificación del tag
        tag_name,
        logical_address,

        -- Zona del PLC
        address_prefix,
        zone_label,
        zone_description,

        -- Descomposición de la dirección
        address_byte,
        address_bit,

        -- Tipo de dato
        data_type,

        -- Configuración HMI
        is_hmi_visible,
        is_hmi_accessible,
        hmi_access_label,

        -- Metadata descriptiva
        path_description,
        tag_comment,

        -- Auditoría
        extracted_at

    from enriched
    order by zone_label, address_byte, address_bit

)

select * from final
