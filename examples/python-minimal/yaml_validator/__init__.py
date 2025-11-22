"""
RSR-Compliant Python Example: Simple YAML Parser

Demonstrates RSR principles:
- Type safety (Python 3.11+ type hints with mypy strict mode)
- Memory safety (automatic via Python runtime)
- Offline-first (no network calls)
- Zero pip dependencies (standard library only)
- Comprehensive error handling and testing
"""

__version__ = "0.1.0"
__all__ = ["parse_yaml", "YAMLParseError", "main"]

from .parser import YAMLParseError, parse_yaml
from .cli import main
