-- stg_airbyte__plc_tags.sql
-- Staging model: limpia y tipifica los datos crudos de plc_tags.
-- Renombra columnas a nombres de negocio y elimina campos internos de Airbyte.

with source as (

    select * from {{ source('airbyte_raw', 'plc_tags') }}

),

renamed as (

    select
        -- Identificador natural (usamos el nombre como clave ya que es único en el PLC)
        name                                        as tag_name,

        -- Atributos descriptivos
        path                                        as path_description,
        comment                                     as tag_comment,
        data_type,

        -- Configuración HMI (castear de TEXT a BOOLEAN)
        (hmi_visible    = 'True')::boolean          as is_hmi_visible,
        (hmi_accessible = 'True')::boolean          as is_hmi_accessible,

        -- Dirección lógica en el PLC
        logical_address,

        -- Extraer prefijo de zona desde la dirección lógica:
        --   %I → Entrada digital
        --   %Q → Salida digital
        --   %M → Marca/memoria interna
        regexp_extract(logical_address, '%([A-Z])', 1) as address_prefix,

        -- Metadatos de carga
        _airbyte_raw_id                             as airbyte_raw_id,
        _airbyte_extracted_at                       as extracted_at

    from source

)

select * from renamed
