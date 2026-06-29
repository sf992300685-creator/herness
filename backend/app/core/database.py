from __future__ import annotations

import sqlite3
from pathlib import Path

from app.core.config import settings

ITEMS_SCHEMA = """
CREATE TABLE IF NOT EXISTS items (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    ts INTEGER NOT NULL,
    value REAL NOT NULL,
    PRIMARY KEY (id, ts)
);
"""


def get_connection(path: str | None = None) -> sqlite3.Connection:
    db_path = path if path is not None else settings.database_path
    if db_path != ":memory:":
        Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    return sqlite3.connect(db_path)


def init_db(conn: sqlite3.Connection) -> None:
    conn.executescript(ITEMS_SCHEMA)
    conn.commit()
