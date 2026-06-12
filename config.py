import os
from sqlalchemy import URL

class Config:
    # Database Settings
    DB_SERVER = os.environ.get("DB_SERVER", r"localhost\SQLEXPRESS") 
    DB_NAME = os.environ.get("DB_NAME", "Olist_dw")
    DRIVER = os.environ.get("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    TRUSTED_CONNECTION = os.environ.get("TRUSTED_CONNECTION", "yes")
    TRUST_SERVER_CERTIFICATE = os.environ.get("TRUST_SERVER_CERTIFICATE", "yes")

    # AI Settings
    GPU_BATCH_SIZE = 16  # Lowered slightly to ensure 100% GPU stability

    @classmethod
    def create_connection_string(cls):
        return URL.create(
            "mssql+pyodbc",
            host=cls.DB_SERVER,
            database=cls.DB_NAME,
            query={
                "driver": cls.DRIVER,
                "Trusted_Connection": cls.TRUSTED_CONNECTION,
                "TrustServerCertificate": cls.TRUST_SERVER_CERTIFICATE
            }
        )
