import pandas as pd
from sqlalchemy import create_engine, URL
from config import Config

def get_db_engine():
    """
    Creates and returns the SQLAlchemy engine for the Olist_dw database with connection pooling.
    """
    connection_string = Config.create_connection_string()
    try:
        engine = create_engine(connection_string, pool_size=10, max_overflow=20)
        return engine
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return None

def load_all_gold_tables():
    """
    Connects to the database and loads the Gold Layer Star Schema into a dictionary of pandas DataFrames.
    Handles connection and query errors.
    """
    engine = get_db_engine()
    if engine is None:
        raise Exception("Failed to connect to the database")

    tables = {
        "Fact_Orders": "SELECT * FROM df.Fact_Orders",
        "Fact_Payments": "SELECT * FROM df.Fact_Payments",
        "Fact_Reviews": "SELECT * FROM df.Fact_Reviews",
        "dim_customers": "SELECT * FROM df.dim_customers",
        "dim_sellers": "SELECT * FROM df.dim_sellers",
        "dim_geolocation": "SELECT * FROM df.dim_geolocation",
        "dim_products": "SELECT * FROM df.dim_products",
        "dim_date": "SELECT * FROM df.dim_date",
        "dim_reviews": "SELECT * FROM df.dim_reviews"
    }

    gold_data = {}
    for table_name, table_sql in tables.items():
        try:
            print(f"Loading {table_name}...")  # Helpful progress tracker
            gold_data[table_name] = pd.read_sql(table_sql, engine)
        except Exception as e:
            print(f"Error loading table {table_name}: {e}")
            raise  # Re-raise to stop execution if a table fails to load

    return gold_data