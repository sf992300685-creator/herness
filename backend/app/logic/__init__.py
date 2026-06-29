"""业务核心逻辑层：纯计算，零 IO。输入行情数据 + 参数，输出交易信号。

约束：本层禁止 import app.services / app.api / app.validators / app.core，
禁止任何网络/DB 调用。由 import-linter 的 backend-layering contract 机械强制。
策略必须是纯函数式单元，保证回测可复现。
"""
