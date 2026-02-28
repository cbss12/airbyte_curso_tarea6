-- int_plc_tags_enriched.sql
-- Intermediate model: enriquece los tags del PLC con etiquetas de zona
-- y clasifica cada variable según su función en el sistema de control.

with plc_tags as (

    select * from {{ ref('stg_airbyte__plc_tags') }}

),

enriched as (

    select
        tag_name,
        logical_address,
        address_prefix,
        data_type,
        is_hmi_visible,
        is_hmi_accessible,
        path_description,
        tag_comment,
        extracted_at,

        -- Etiqueta de zona según prefijo de dirección lógica
        case address_prefix
            when 'I' then 'Entrada'
            when 'Q' then 'Salida'
            when 'M' then 'Marca'
            else 'Desconocida'
        end                                         as zone_label,

        -- Descripción extendida de la zona
        case address_prefix
            when 'I' then 'Entrada digital — señal proveniente de sensor o botón'
            when 'Q' then 'Salida digital — señal hacia actuador o indicador'
            when 'M' then 'Marca interna — variable de memoria del PLC'
            else 'Zona no identificada'
        end                                         as zone_description,

        -- Clasificación de visibilidad en HMI
        case
            when is_hmi_visible and is_hmi_accessible then 'Lectura y Escritura'
            when is_hmi_visible and not is_hmi_accessible then 'Solo Lectura'
            when not is_hmi_visible then 'No visible en HMI'
        end                                         as hmi_access_label,

        -- Número de byte extraído de la dirección lógica (ej: %Q0.4 → 0)
        try_cast(
            regexp_extract(logical_address, '%[A-Z](\d+)\.', 1)
        as integer)                                 as address_byte,

        -- Número de bit extraído de la dirección lógica (ej: %Q0.4 → 4)
        try_cast(
            regexp_extract(logical_address, '%[A-Z]\d+\.(\d+)', 1)
        as integer)                                 as address_bit

    from plc_tags

)

select * from enriched
