-- int_repositories_classified.sql
-- Intermediate model: clasifica los repositorios según su estado,
-- tipo inferido desde el nombre, y antigüedad desde la última actualización.

with repos as (

    select * from {{ ref('stg_airbyte__repositories') }}

),

classified as (

    select
        repository_id,
        repository_name,
        is_archived,
        clone_url,
        last_updated_at,
        extracted_at,

        -- Clasificación por estado operativo
        case
            when is_archived then 'Archivado'
            else 'Activo'
        end                                             as repo_status,

        -- Inferir tipo de repositorio desde el nombre
        case
            when repository_name ilike '%connector%'    then 'Connector'
            when repository_name ilike '%tap-%'         then 'Singer Tap'
            when repository_name ilike '%target-%'      then 'Singer Target'
            when repository_name ilike '%sdk%'          then 'SDK'
            when repository_name ilike '%demo%'         then 'Demo / Ejemplo'
            when repository_name ilike '%docs%'         then 'Documentación'
            when repository_name ilike '%workshop%'     then 'Workshop'
            else 'General'
        end                                             as repo_type,

        -- Días desde la última actualización (relativo a la extracción)
        datediff(
            'day',
            last_updated_at,
            extracted_at
        )                                               as days_since_update,

        -- Clasificación de actividad reciente
        case
            when datediff('day', last_updated_at, extracted_at) <= 30
                then 'Muy activo'
            when datediff('day', last_updated_at, extracted_at) <= 180
                then 'Activo'
            when datediff('day', last_updated_at, extracted_at) <= 365
                then 'Poco activo'
            else 'Inactivo'
        end                                             as activity_label

    from repos

)

select * from classified
