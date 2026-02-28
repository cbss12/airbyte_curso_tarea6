-- stg_airbyte__repositories.sql
-- Staging model: limpia y tipifica los datos crudos de repositories.
-- Extrae el nombre del repo desde la clone_url y normaliza tipos.

with source as (

    select * from {{ source('airbyte_raw', 'repositories') }}

),

renamed as (

    select
        -- Identificador
        id                                              as repository_id,

        -- Extraer nombre del repo desde clone_url
        -- Ej: https://github.com/airbytehq/tap-appstore.git → tap-appstore
        regexp_extract(
            clone_url,
            'github\.com/[^/]+/([^/]+?)(?:\.git)?$',
            1
        )                                               as repository_name,

        -- Estado del repositorio
        (archived = 'true')::boolean                   as is_archived,

        -- URLs útiles
        clone_url,
        archive_url,
        commits_url,
        comments_url,
        collaborators_url,

        -- Fechas
        updated_at::timestamp                           as last_updated_at,

        -- Metadatos de carga
        _airbyte_raw_id                                 as airbyte_raw_id,
        _airbyte_extracted_at                           as extracted_at

    from source

)

select * from renamed
