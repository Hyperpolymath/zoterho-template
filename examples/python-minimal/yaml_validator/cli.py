"""Command-line interface for YAML validator."""

import json
import sys
from pathlib import Path
from typing import NoReturn

from .parser import YAMLParseError, parse_yaml


def main() -> None:
    """Main CLI entry point."""
    if len(sys.argv) < 2:
        print("Usage: python -m yaml_validator <file.yaml>", file=sys.stderr)
        print("\nRSR-Compliant YAML Parser", file=sys.stderr)
        print("Parses simple YAML files using only Python stdlib", file=sys.stderr)
        sys.exit(1)

    filename = sys.argv[1]
    file_path = Path(filename)

    try:
        if not file_path.exists():
            _error(f"File not found: {filename}")

        content = file_path.read_text(encoding="utf-8")
        data = parse_yaml(content)

        print("✅ YAML parsed successfully!")
        print(f"\nParsed {len(data)} top-level keys:")
        print(json.dumps(data, indent=2))

    except YAMLParseError as e:
        _error(f"Parse error: {e}")
    except Exception as e:
        _error(f"Error: {e}")


def _error(message: str) -> NoReturn:
    """Print error and exit."""
    print(f"❌ {message}", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
