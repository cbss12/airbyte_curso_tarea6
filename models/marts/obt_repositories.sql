-- obt_repositories.sql
-- Mart (OBT): tabla final para análisis y dashboard de repositorios GitHub.
-- Incluye todas las clasificaciones del modelo intermediate.

with classified as (

    select * from {{ ref('int_repositories_classified') }}

),

final as (

    select
        -- Identificación
        repository_id,
        repository_name,

        -- Estado y clasificación
        repo_status,
        repo_type,
        is_archived,

        -- Actividad
        activity_label,
        days_since_update,
        last_updated_at,

        -- URLs de referencia
        clone_url,

        -- Auditoría
        extracted_at

    from classified
    order by repo_status, activity_label, repository_name

)

select * from final
