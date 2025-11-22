"""Simple YAML parser using only Python standard library."""

import re
from typing import Any


class YAMLParseError(Exception):
    """YAML parsing error with line number."""

    def __init__(self, message: str, line_num: int) -> None:
        super().__init__(f"Line {line_num}: {message}")
        self.line_num = line_num


def parse_yaml(content: str) -> dict[str, Any]:
    """
    Parse simple YAML content (key: value format only).

    Supports:
    - Simple key: value pairs
    - Comments (# prefix)
    - Strings, numbers, booleans, null
    - Basic lists (- item)

    Args:
        content: YAML content as string

    Returns:
        Parsed data as dictionary

    Raises:
        YAMLParseError: If parsing fails
    """
    result: dict[str, Any] = {}
    current_key: str | None = None
    current_list: list[Any] = []

    for line_num, line in enumerate(content.splitlines(), start=1):
        stripped = line.strip()

        # Skip empty lines and comments
        if not stripped or stripped.startswith("#"):
            continue

        # List item
        if stripped.startswith("- "):
            if current_key is None:
                raise YAMLParseError("List item without a key", line_num)

            item_value = stripped[2:].strip()
            parsed_value = _parse_value(item_value, line_num)
            current_list.append(parsed_value)
            continue

        # Key-value pair
        if ": " in stripped or stripped.endswith(":"):
            # Save previous list if any
            if current_key is not None and current_list:
                result[current_key] = current_list
                current_list = []

            parts = stripped.split(": ", 1)
            if len(parts) != 2:
                if stripped.endswith(":"):
                    # Key for a list
                    current_key = stripped[:-1].strip()
                    continue
                raise YAMLParseError(
                    "Invalid key-value format (expected 'key: value')",
                    line_num,
                )

            key = parts[0].strip()
            value_str = parts[1].strip()

            if not key:
                raise YAMLParseError("Empty key not allowed", line_num)

            # Check if this starts a list
            if not value_str:
                current_key = key
                continue

            value = _parse_value(value_str, line_num)
            result[key] = value
            current_key = None
            continue

        raise YAMLParseError(f"Invalid line format: {stripped}", line_num)

    # Save final list if any
    if current_key is not None and current_list:
        result[current_key] = current_list

    return result


def _parse_value(value_str: str, line_num: int) -> Any:
    """Parse a YAML value (string, number, boolean, null)."""
    # Boolean
    if value_str.lower() in ("true", "yes"):
        return True
    if value_str.lower() in ("false", "no"):
        return False

    # Null
    if value_str.lower() in ("null", "~"):
        return None

    # Number (integer)
    if re.match(r"^-?\d+$", value_str):
        return int(value_str)

    # Number (float)
    if re.match(r"^-?\d+\.\d+$", value_str):
        return float(value_str)

    # String (quoted or unquoted)
    if (value_str.startswith('"') and value_str.endswith('"')) or (
        value_str.startswith("'") and value_str.endswith("'")
    ):
        return value_str[1:-1]

    # Unquoted string
    return value_str
