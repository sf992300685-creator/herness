from __future__ import annotations

from pydantic import BaseModel


class Item(BaseModel):
    """通用数据模型示例"""

    id: str
    name: str
    ts: int
    value: float
