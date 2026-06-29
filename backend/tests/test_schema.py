from __future__ import annotations

import sqlite3

import pytest

from app.core.database import init_db
from app.models.item import Item


def _connect() -> sqlite3.Connection:
    return sqlite3.connect(":memory:")


def test_init_db_creates_items_table() -> None:
    conn = _connect()
    init_db(conn)
    rows = conn.execute("PRAGMA table_info(items)").fetchall()
    cols = {row[1] for row in rows}
    assert cols == {"id", "name", "ts", "value"}


def test_init_db_is_idempotent() -> None:
    conn = _connect()
    init_db(conn)
    init_db(conn)
    row = conn.execute("SELECT COUNT(*) FROM items").fetchone()
    assert row is not None
    assert row[0] == 0


def test_item_round_trip() -> None:
    conn = _connect()
    init_db(conn)
    item = Item(
        id="item-123",
        name="test_item",
        ts=1,
        value=1.5,
    )
    conn.execute(
        "INSERT INTO items (id, name, ts, value) VALUES (?, ?, ?, ?)",
        (item.id, item.name, item.ts, item.value),
    )
    conn.commit()
    row = conn.execute("SELECT id, name, ts, value FROM items").fetchone()
    assert row is not None
    assert row == ("item-123", "test_item", 1, 1.5)


def test_items_primary_key_rejects_duplicates() -> None:
    conn = _connect()
    init_db(conn)
    conn.execute(
        "INSERT INTO items (id, name, ts, value) VALUES (?, ?, ?, ?)",
        ("item-123", "test_item", 1, 1.5),
    )
    with pytest.raises(sqlite3.IntegrityError):
        conn.execute(
            "INSERT INTO items (id, name, ts, value) VALUES (?, ?, ?, ?)",
            ("item-123", "other_item", 1, 9.0),
        )
