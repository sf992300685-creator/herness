from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "herness 通用智能体驾驭系统"
    app_version: str = "0.0.0"
    api_v1_prefix: str = "/api"
    debug: bool = False
    database_path: str = "data/herness.db"


settings = Settings()
