"""
Loads the Amazon e-commerce CSV into Postgres as `amazon_sales`.

Setup:
    pip install pandas sqlalchemy psycopg2-binary

Usage:
    python load_to_postgres.py

Real columns (confirmed from pgAdmin, see ../sql/sql_queries.sql):
    seller_id, seller_rating, final_price, is_returned, category, device,
    payment_method, shipping_time_days, rating, discount, purchase_date
"""

import pandas as pd
from sqlalchemy import create_engine

# --- config -----------------------------------------------------------
RAW_CSV_PATH = "../data/raw/amazon_sales.csv"
PG_CONN = "postgresql://postgres:postgres@localhost:5432/amazon_ecommerce"
TARGET_TABLE = "amazon_sales"

# --- load ---------------------------------------------------------------
df = pd.read_csv(RAW_CSV_PATH)
print(f"Loaded {len(df):,} rows, {len(df.columns)} columns")

# --- clean ---------------------------------------------------------------
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")

before = len(df)
df = df.drop_duplicates()
print(f"Dropped {before - len(df):,} duplicate rows")

df["purchase_date"] = pd.to_datetime(df["purchase_date"], errors="coerce")
df["final_price"] = pd.to_numeric(df["final_price"], errors="coerce")
df["discount"] = pd.to_numeric(df["discount"], errors="coerce")
df["rating"] = pd.to_numeric(df["rating"], errors="coerce")
df["seller_rating"] = pd.to_numeric(df["seller_rating"], errors="coerce")
df["shipping_time_days"] = pd.to_numeric(df["shipping_time_days"], errors="coerce")
df["is_returned"] = df["is_returned"].astype(bool)

df = df.dropna(subset=["purchase_date", "final_price"])

# --- load to postgres -----------------------------------------------------
engine = create_engine(PG_CONN)
df.to_sql(TARGET_TABLE, engine, if_exists="replace", index=False, chunksize=10000)
print(f"Loaded {len(df):,} rows into {TARGET_TABLE}")
