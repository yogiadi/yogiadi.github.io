---
title: "Introducing KeySense (PySpark) – Finding Your Dataset's True Grain"
date: 2025-08-10
author: "Aditya Yogi"
tags: [pyspark, data-quality, open-source, data-engineering, keysense]
---

## Why KeySense?

In the world of data engineering, one of the most overlooked problems is **determining a dataset's grain** — the unique combination of columns that defines each record.  
Most data quality frameworks assume you *already know* this grain, but in reality, it's rarely documented, often misunderstood, and prone to **grain drift** over time.

**Grain drift** happens when the real-world uniqueness of your data changes silently — duplicates creep in, KPIs break, joins explode, and trust in the data erodes.

KeySense is an **open-source, PySpark-compatible** way to detect and monitor that grain.

## Why existing tools fall short

Current data quality frameworks (like Great Expectations, Deequ, Soda) provide valuable checks — nulls, schema, freshness, valid values — but they **do not discover** the dataset's actual unique keys.  
They require you to specify the keys upfront, meaning:  
- If you don't know the grain, you can't run their key-based checks.  
- If the grain changes over time, you won't know unless you manually re-check.  
- They rarely handle combinations beyond 1–2 columns without explicit configuration.

In practice, datasets evolve, and the *identity definition* can drift without being noticed — something existing tools simply don’t track.

## Algorithms that can help

KeySense uses column-combination scanning, but its core idea can be extended with:
- **Combination generation** – Systematically enumerate up to `n`-column combos.  
- **Set-based uniqueness checks** – Using Spark’s `countDistinct` or `approx_count_distinct`.  
- **Stability analysis** – Group-by over a partition key (e.g., `event_date`) to detect drift.  
- **Null coverage tracking** – Count rows where any combo column is null.  
- **Scoring model** – Weighted combination of uniqueness, stability, and null coverage.  
- **Heuristic pruning** – Skip low-cardinality or high-null columns early to reduce search space.

## Advanced and research-based techniques

While KeySense will initially use practical Spark-based methods, there are several advanced approaches from academic research and niche data profiling tools that could be integrated later:

- **TANE (Huhtala et al., 1999)** – A classic functional dependency discovery algorithm that systematically finds minimal unique column sets.
- **HyFD (Papenbrock et al., 2015)** – A hybrid approach that uses sampling and partitioning to find functional dependencies efficiently.
- **FAIDA** – An incremental functional dependency discovery method designed for large, evolving datasets.
- **Metanome Framework algorithms** – Various pluggable algorithms for unique column combination discovery, including DFS-based and pruning-based strategies.
- **Inclusion Dependency Detection** – Used for foreign key discovery; could indirectly assist in detecting composite primary keys across datasets.
- **Column Sharding with Bloom Filters** – A probabilistic approach for checking uniqueness at scale with reduced memory usage.

These methods are less common in production-grade data engineering pipelines but could be adapted to work on Spark for enterprise-scale datasets.

## What is KeySense?

**KeySense** is a PySpark utility that:
- Scans all column combinations up to 4 columns.
- Calculates:
  - **Uniqueness ratio** – how unique the combo is.
  - **Drift stability** – is it stable over time (e.g., by day)?
  - **Null coverage** – how often any part of the combo is null.
- Returns a **Grain Score** that ranks the best candidate keys.

Think of it as **profiling your dataset’s identity**.

## Quick Example

```python
from pyspark.sql import SparkSession
from keysense import KeySense

spark = SparkSession.builder.appName("KeySenseDemo").getOrCreate()

data = [
    ("u1", "s1", "2025-08-01", "mobile"),
    ("u2", "s2", "2025-08-01", "desktop"),
    ("u1", "s1", "2025-08-02", "mobile"),
    ("u3", "s3", "2025-08-01", "mobile")
]
cols = ["user_id", "session_id", "event_date", "device_id"]
df = spark.createDataFrame(data, cols)

ks = KeySense(df, time_col="event_date", max_combo_len=3)
results = ks.evaluate()

for r in results[:5]:
    print(r)
```

**Sample Output:**
```text
{'combo': ('user_id', 'session_id', 'event_date'), 'uniqueness_ratio': 1.0, 'drift_stability': 0.98, 'null_ratio': 0.0, 'grain_score': 0.994}
...
```

## Strategy & Roadmap

The project will be developed in **phases**:

**Phase 1 – Foundations**
- Minimal PySpark package
- Column combo scanning (up to 4 columns)
- Stability checks across a time column
- Ranked Grain Score output

**Phase 2 – Performance & Ergonomics**
- Sampling for large datasets
- Heuristic-driven column prioritization
- Null & low-cardinality filtering
- Duplicate fingerprinting

**Phase 3 – Integrations & Developer Experience**
- CLI
- Metadata table export
- Example notebooks
- Integrations with Great Expectations / Soda

**Future Plans**
- Configurable scoring weights
- Approximate distinct counts
- Parallelized combo evaluation
- Delta Lake / Iceberg support
- Benchmarks and contributor guide

## Get Involved

KeySense is open-source and ready for experimentation.  
You can clone the repo and try it today:

```bash
git clone https://github.com/yogiadi/keysense-pyspark.git
cd keysense-pyspark
```

I welcome:
- **Feature ideas**
- **Bug reports**
- **Pull requests**
