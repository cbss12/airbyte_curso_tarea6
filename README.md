# airbyte_curso — Proyecto dbt

Proyecto dbt para transformación de datos del curso **Introducción a la Ingeniería de Datos** — MIA 03, Facultad Politécnica, UNA.

Transforma datos extraídos con **Airbyte** desde MotherDuck usando el modelo **One Big Table (OBT)**.

---

## 📁 Estructura del Proyecto

```
airbyte_curso_dbt/
├── models/
│   ├── staging/
│   │   ├── _sources.yml                  ← Definición de fuentes Airbyte
│   │   ├── _staging_models.yml           ← Docs y tests de staging
│   │   ├── stg_airbyte__plc_tags.sql     ← Staging: variables PLC
│   │   └── stg_airbyte__repositories.sql ← Staging: repositorios GitHub
│   ├── intermediate/
│   │   ├── _intermediate_models.yml
│   │   ├── int_plc_tags_enriched.sql     ← Enriquece variables PLC con zonas
│   │   └── int_repositories_classified.sql ← Clasifica repos por tipo
│   └── marts/
│       ├── _marts_models.yml
│       ├── obt_plc_tags.sql              ← OBT final del sistema PLC
│       └── obt_repositories.sql          ← OBT final de repositorios
├── dbt_project.yml
├── profiles.yml                          ← NO subir a git (credenciales)
└── .gitignore
```

### Linaje de datos (DAG)

```
source: airbyte_raw.plc_tags
    └── stg_airbyte__plc_tags
            └── int_plc_tags_enriched
                    └── obt_plc_tags  ✅

source: airbyte_raw.repositories
    └── stg_airbyte__repositories
            └── int_repositories_classified
                    └── obt_repositories  ✅
```

---

## ⚙️ Configuración

### 1. Requisitos

```bash
pip install dbt-core dbt-duckdb
```

### 2. Configurar credenciales de MotherDuck

Crear archivo `profiles.yml` en la raíz del proyecto (o en `~/.dbt/profiles.yml`):

```yaml
airbyte_curso:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'md:airbyte_curso'
      token: "{{ env_var('MOTHERDUCK_TOKEN') }}"
      schema: main
```


### 3. Instalar dependencias dbt

```bash
dbt deps
```

---

## 🚀 Uso

### Ejecutar todos los modelos

```bash
dbt run
```

### Ejecutar solo un modelo específico

```bash
dbt run --select stg_airbyte__plc_tags
dbt run --select obt_plc_tags
```

### Ejecutar por capa

```bash
dbt run --select staging.*
dbt run --select intermediate.*
dbt run --select marts.*
```

### Ejecutar un modelo y todos sus descendientes

```bash
dbt run --select stg_airbyte__plc_tags+
```

### Correr tests

```bash
dbt test
```

### Generar y ver documentación (DAG)

```bash
dbt docs generate
dbt docs serve
```

---

## 📊 Modelos

### Staging
| Modelo | Fuente | Registros | Descripción |
|--------|--------|-----------|-------------|
| `stg_airbyte__plc_tags` | `main.plc_tags` | 16 | Variables PLC limpias con booleanos y prefijo de zona |
| `stg_airbyte__repositories` | `main.repositories` | 93 | Repositorios GitHub con nombre y org extraídos |

### Intermediate
| Modelo | Upstream | Descripción |
|--------|----------|-------------|
| `int_plc_tags_enriched` | stg_airbyte__plc_tags | Añade zona, byte/bit de dirección y flags de control |
| `int_repositories_classified` | stg_airbyte__repositories | Clasifica repos por tipo y estado de actividad |

### Marts (OBT)
| Modelo | Materialización | Descripción |
|--------|-----------------|-------------|
| `obt_plc_tags` | table | OBT final del sistema PLC para dashboards |
| `obt_repositories` | table | OBT final del portafolio de repos GitHub |

---

## 🧪 Tests incluidos

- `not_null` en todas las columnas críticas
- `unique` en claves naturales
- `accepted_values` en zonas PLC, tipos de repo y estados de actividad

---

## 📚 Referencias

- [dbt Documentation](https://docs.getdbt.com)
- [dbt-duckdb adapter](https://github.com/duckdb/dbt-duckdb)
- [MotherDuck docs](https://motherduck.com/docs)
- The Data Warehouse Toolkit — Ralph Kimball (Clase 4)
- [The Rise of the One Big Table — dbt Labs](https://getdbt.com/blog/one-big-table)
