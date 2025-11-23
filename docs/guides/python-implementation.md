# Python Implementation Guide

Complete guide for creating RSR-compliant Python projects.

## Prerequisites

- Python 3.11+ (`pyenv install 3.11`)
- pip 23+ or uv (comes with Python)
- Optional: `mypy`, `ruff`, `pytest`, `coverage`

## Quick Start

```bash
# Create new Python project
mkdir my-rsr-project
cd my-rsr-project

# Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Create project structure
mkdir -p src/my_rsr_project tests

# Initialize pyproject.toml
cat > pyproject.toml << 'EOF'
[project]
name = "my-rsr-project"
version = "0.1.0"
description = "RSR-compliant Python project"
requires-python = ">=3.11"
license = {text = "MIT OR Palimpsest-0.8"}
EOF

# Copy RSR template files
cp /path/to/zoterho-template/{README.md,LICENSE.txt,SECURITY.md,etc.} .
cp -r /path/to/zoterho-template/.well-known .

# Initialize RSR structure
just init  # if using justfile
```

## Project Structure

```
my-rsr-project/
├── src/
│   └── my_rsr_project/
│       ├── __init__.py      # Package initialization
│       ├── main.py          # Entry point
│       ├── types.py         # Type definitions
│       ├── errors.py        # Error types
│       └── utils.py         # Utility functions
├── tests/
│   ├── __init__.py
│   ├── unit/
│   │   └── test_main.py
│   └── integration/
│       └── test_integration.py
├── pyproject.toml           # Project configuration
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
├── mypy.ini                 # mypy configuration
├── ruff.toml                # ruff configuration
├── .python-version          # Python version (pyenv)
├── README.md                # RSR-compliant README
├── LICENSE.txt              # Dual MIT + Palimpsest
├── SECURITY.md              # Security policy
└── .well-known/             # RFC 9116 compliance
```

## Pyproject.toml Configuration

```toml
[project]
name = "my-rsr-project"
version = "0.1.0"
description = "RSR-compliant Python project"
readme = "README.md"
requires-python = ">=3.11"
license = {text = "MIT OR Palimpsest-0.8"}
authors = [
    {name = "Your Name", email = "email@example.com"}
]
keywords = ["rsr", "rhodium"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Typing :: Typed",
]

[project.urls]
Homepage = "https://github.com/username/my-rsr-project"
Repository = "https://github.com/username/my-rsr-project"
Issues = "https://github.com/username/my-rsr-project/issues"

# Zero dependencies for Bronze level
[project.dependencies]
# Prefer stdlib only

[project.optional-dependencies]
dev = [
    "mypy>=1.7",
    "ruff>=0.1.0",
    "pytest>=7.4",
    "pytest-cov>=4.1",
    "coverage[toml]>=7.3",
]

[build-system]
requires = ["setuptools>=68.0", "wheel"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
where = ["src"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
disallow_subclassing_any = true
disallow_untyped_calls = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true
strict_concatenate = true

[tool.ruff]
line-length = 100
target-version = "py311"
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "N",      # pep8-naming
    "UP",     # pyupgrade
    "ANN",    # flake8-annotations
    "B",      # flake8-bugbear
    "A",      # flake8-builtins
    "C4",     # flake8-comprehensions
    "DTZ",    # flake8-datetimez
    "T10",    # flake8-debugger
    "EM",     # flake8-errmsg
    "ISC",    # flake8-implicit-str-concat
    "ICN",    # flake8-import-conventions
    "PIE",    # flake8-pie
    "PT",     # flake8-pytest-style
    "Q",      # flake8-quotes
    "RSE",    # flake8-raise
    "RET",    # flake8-return
    "SIM",    # flake8-simplify
    "TID",    # flake8-tidy-imports
    "PTH",    # flake8-use-pathlib
    "ERA",    # eradicate
    "PL",     # pylint
    "RUF",    # ruff-specific rules
]
ignore = [
    "ANN101",  # Missing type annotation for self
    "ANN102",  # Missing type annotation for cls
]

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["ANN201", "ANN001", "PLR2004"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--verbose",
    "--strict-markers",
    "--cov=src/my_rsr_project",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=80",
]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", ".venv/*"]

[tool.coverage.report]
precision = 2
show_missing = true
skip_covered = false
```

## RSR Compliance Checklist

### 1. Type Safety ✅

**Python 3.11+ with mypy strict mode provides comprehensive type safety.**

Best practices:
- Use type hints for all functions and methods
- Enable mypy strict mode
- Use NewType for domain-specific values
- Leverage Protocol and TypedDict
- Use Literal types for constants

```python
# ❌ No type hints
def process_user(user_id, name):
    return {"id": user_id, "name": name}

# ✅ Full type annotations
from typing import TypedDict, NewType

UserId = NewType('UserId', int)
Email = NewType('Email', str)

class UserData(TypedDict):
    id: UserId
    name: str
    email: Email

def process_user(user_id: UserId, name: str, email: Email) -> UserData:
    return {"id": user_id, "name": name, "email": email}

# ✅ Branded types for validation
def create_email(email: str) -> Email | ValueError:
    if '@' not in email:
        return ValueError('Invalid email format')
    return Email(email)

# ✅ Protocol for structural typing
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

def render(item: Drawable) -> None:
    item.draw()
```

### 2. Memory Safety ✅

**Python has automatic memory management with reference counting and GC.**

Best practices:
- Use context managers for resource cleanup
- Avoid circular references
- Use `weakref` for caching
- Close resources explicitly
- Avoid global mutable state

```python
# ❌ Resource leak
def read_data(filename: str) -> str:
    file = open(filename)
    return file.read()

# ✅ Proper resource management
from pathlib import Path
from typing import Final

def read_data(filename: Path) -> str:
    with open(filename) as file:
        return file.read()

# ✅ Custom context manager
from typing import Self
from collections.abc import Iterator

class DatabaseConnection:
    def __enter__(self) -> Self:
        self.connect()
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: object,
    ) -> None:
        self.close()

    def connect(self) -> None:
        pass

    def close(self) -> None:
        pass

# ✅ Use weakref for caching
import weakref
from typing import Any

cache: weakref.WeakValueDictionary[str, Any] = weakref.WeakValueDictionary()

def memoize(key: str, obj: Any) -> Any:
    if key in cache:
        return cache[key]
    cache[key] = obj
    return obj
```

### 3. Offline-First ✅

**Zero network dependencies for Bronze level.**

```toml
[project.dependencies]
# ❌ No network dependencies
# "requests" = "^2.31.0"
# "httpx" = "^0.25.0"
# "aiohttp" = "^3.9.0"

# ✅ Offline-friendly only
# Standard library only for Bronze level
```

Verification:
```bash
# Check dependencies
pip list

# Ensure no network-related packages
pip freeze | grep -E 'requests|urllib3|httpx|aiohttp'
# Should return nothing
```

### 4. Zero Dependencies (Ideal)

**For Bronze level, use only Python standard library.**

```python
# ✅ Using only standard library
import json
import pathlib
import hashlib
import dataclasses
from typing import Any
from collections.abc import Mapping

@dataclasses.dataclass(frozen=True)
class Config:
    app_name: str
    version: str
    debug: bool = False

def load_config(path: pathlib.Path) -> Config:
    with open(path) as file:
        data: dict[str, Any] = json.load(file)
    return Config(**data)
```

### 5. Comprehensive Testing

**100% test pass rate required.**

Using pytest:
```python
# tests/unit/test_main.py
import pytest
from my_rsr_project.main import process_user, create_email
from my_rsr_project.types import UserId, Email

class TestProcessUser:
    def test_valid_user_data(self) -> None:
        """Test processing valid user data."""
        user_id = UserId(1)
        email = Email('alice@example.com')
        result = process_user(user_id, 'Alice', email)

        assert result['id'] == user_id
        assert result['name'] == 'Alice'
        assert result['email'] == email

    def test_empty_name(self) -> None:
        """Test processing user with empty name."""
        user_id = UserId(1)
        email = Email('alice@example.com')
        result = process_user(user_id, '', email)

        assert result['name'] == ''

class TestCreateEmail:
    def test_valid_email(self) -> None:
        """Test creating valid email."""
        result = create_email('valid@example.com')
        assert isinstance(result, str)
        assert result == 'valid@example.com'

    def test_invalid_email(self) -> None:
        """Test creating invalid email."""
        result = create_email('invalid')
        assert isinstance(result, ValueError)

    @pytest.mark.parametrize('email,expected', [
        ('user@example.com', True),
        ('invalid', False),
        ('', False),
    ])
    def test_email_validation(self, email: str, expected: bool) -> None:
        """Test email validation with multiple inputs."""
        result = create_email(email)
        assert isinstance(result, str) == expected
```

Run tests:
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src/my_rsr_project --cov-report=term-missing

# Run specific test
pytest tests/unit/test_main.py::TestProcessUser::test_valid_user_data

# Run with verbose output
pytest -v

# Generate HTML coverage report
pytest --cov=src/my_rsr_project --cov-report=html
```

### 6. Error Handling

**Use custom exception classes with proper typing.**

```python
# src/my_rsr_project/errors.py
from typing import Any, Final

class AppError(Exception):
    """Base class for application errors."""

    code: str = "APP_ERROR"

    def __init__(self, message: str) -> None:
        self.message: Final = message
        super().__init__(message)

class ValidationError(AppError):
    """Raised when validation fails."""

    code: str = "VALIDATION_ERROR"

    def __init__(self, message: str, field: str | None = None) -> None:
        super().__init__(message)
        self.field: Final = field

class NotFoundError(AppError):
    """Raised when a resource is not found."""

    code: str = "NOT_FOUND"

    def __init__(self, message: str, resource: str | None = None) -> None:
        super().__init__(message)
        self.resource: Final = resource

class ParseError(AppError):
    """Raised when parsing fails."""

    code: str = "PARSE_ERROR"

    def __init__(self, message: str, input_data: str | None = None) -> None:
        super().__init__(message)
        self.input_data: Final = input_data

# Result type for safer error handling
from typing import TypeVar, Generic
from dataclasses import dataclass

T = TypeVar('T')
E = TypeVar('E', bound=Exception)

@dataclass(frozen=True)
class Ok(Generic[T]):
    """Successful result."""
    value: T

@dataclass(frozen=True)
class Err(Generic[E]):
    """Error result."""
    error: E

Result = Ok[T] | Err[E]

# Helper functions
def ok(value: T) -> Ok[T]:
    """Create a successful result."""
    return Ok(value)

def err(error: E) -> Err[E]:
    """Create an error result."""
    return Err(error)

# Usage example
import json
from typing import Any

def parse_user_input(input_data: str) -> Result[dict[str, Any], ValidationError]:
    """Parse user input as JSON."""
    if not input_data:
        return err(ValidationError('Input cannot be empty'))

    try:
        data: dict[str, Any] = json.loads(input_data)
        return ok(data)
    except json.JSONDecodeError as e:
        return err(ValidationError(f'Invalid JSON format: {e}'))

# Pattern matching (Python 3.10+)
def process_result(result: Result[dict[str, Any], ValidationError]) -> None:
    """Process a result using pattern matching."""
    match result:
        case Ok(value):
            print(f"Success: {value}")
        case Err(error):
            print(f"Error: {error.message}")
```

### 7. Code Quality Tools

**ruff for linting and formatting:**

```bash
# Install ruff
pip install ruff

# Lint code
ruff check .

# Fix auto-fixable issues
ruff check --fix .

# Format code
ruff format .

# Check formatting
ruff format --check .
```

**mypy for type checking:**

```bash
# Install mypy
pip install mypy

# Type check
mypy src/

# Strict mode (recommended)
mypy --strict src/

# Generate coverage report
mypy --html-report mypy-report src/
```

**Run all quality checks:**

```bash
# Format
ruff format .

# Lint
ruff check .

# Type check
mypy src/

# Test
pytest
```

## Build Automation

**justfile recipes:**

```just
# Python binary
python := "python3.11"

# Activate virtual environment
venv:
    {{python}} -m venv .venv
    .venv/bin/pip install -e ".[dev]"

# Run all tests
test:
    pytest

# Type check
type-check:
    mypy src/

# Lint code
lint:
    ruff check .

# Format code
format:
    ruff format .

# Check formatting
format-check:
    ruff format --check .

# Security check
security-check:
    pip-audit

# Full CI pipeline
ci: format-check lint type-check test

# Pre-commit checks
pre-commit: format lint type-check test

# Clean build artifacts
clean:
    rm -rf build/ dist/ *.egg-info
    find . -type d -name __pycache__ -exec rm -rf {} +
    find . -type f -name "*.pyc" -delete
    rm -rf .mypy_cache .pytest_cache .ruff_cache
```

## Security Best Practices

1. **Dependency Auditing**
   ```bash
   # Install pip-audit
   pip install pip-audit

   # Check for vulnerabilities
   pip-audit

   # Check for outdated packages
   pip list --outdated
   ```

2. **Input Validation**
   ```python
   from typing import TypeGuard

   def is_valid_string(value: object) -> TypeGuard[str]:
       """Type guard for string validation."""
       return isinstance(value, str) and len(value) > 0

   def validate_input(input_data: object) -> str:
       """Validate and return string input."""
       if not is_valid_string(input_data):
           raise ValidationError('Input must be a non-empty string')

       if len(input_data) > 1000:
           raise ValidationError('Input too long')

       return input_data
   ```

3. **Avoid Code Injection**
   ```python
   # ❌ Dangerous - code injection
   def execute_code(code: str) -> Any:
       return eval(code)

   # ✅ Safe - use literal_eval for data
   import ast

   def parse_literal(data: str) -> Any:
       """Parse literal values safely."""
       try:
           return ast.literal_eval(data)
       except (ValueError, SyntaxError) as e:
           raise ParseError(f'Invalid literal: {e}')
   ```

4. **Secure Defaults**
   ```python
   from dataclasses import dataclass, field
   from typing import Final

   @dataclass(frozen=True)
   class Config:
       """Application configuration with secure defaults."""
       debug: bool = False          # Secure default
       verbose: bool = False         # Secure default
       max_retries: int = 3
       timeout: float = 5.0

       def __post_init__(self) -> None:
           """Validate configuration."""
           if self.max_retries < 0:
               raise ValidationError('max_retries must be non-negative')
           if self.timeout <= 0:
               raise ValidationError('timeout must be positive')

   DEFAULT_CONFIG: Final[Config] = Config()
   ```

5. **Path Traversal Prevention**
   ```python
   from pathlib import Path

   def safe_path_join(base: Path, user_path: str) -> Path:
       """Safely join paths, preventing directory traversal."""
       # Resolve to absolute path
       full_path = (base / user_path).resolve()

       # Ensure result is within base directory
       if not str(full_path).startswith(str(base.resolve())):
           raise ValidationError('Path traversal detected')

       return full_path
   ```

## Documentation

**Docstrings using Google style:**

```python
from pathlib import Path
from typing import Any

def parse_config(path: Path) -> dict[str, Any]:
    """Parse a configuration file and return configuration dictionary.

    Args:
        path: Path to the configuration file.

    Returns:
        Parsed configuration as dictionary.

    Raises:
        ValidationError: If the file contains invalid data.
        NotFoundError: If the file doesn't exist.
        ParseError: If JSON parsing fails.

    Examples:
        >>> config = parse_config(Path('config.json'))
        >>> config['app_name']
        'MyApp'

    Note:
        This function reads the file synchronously and should only be used
        during application initialization.
    """
    if not path.exists():
        raise NotFoundError(f"Config file not found: {path}")

    try:
        with open(path) as file:
            data: dict[str, Any] = json.load(file)
        return data
    except json.JSONDecodeError as e:
        raise ParseError(f"Invalid JSON in config file: {e}")
```

Generate documentation:
```bash
# Using pdoc
pip install pdoc
pdoc --html --output-dir docs src/my_rsr_project

# Using sphinx
pip install sphinx
sphinx-quickstart docs
sphinx-build -b html docs docs/_build
```

## Performance Tips

1. **Use `__slots__` for memory efficiency**
   ```python
   # ✅ Memory efficient
   class Point:
       __slots__ = ('x', 'y')

       def __init__(self, x: float, y: float) -> None:
           self.x = x
           self.y = y

   # ✅ Frozen dataclass with slots
   from dataclasses import dataclass

   @dataclass(frozen=True, slots=True)
   class Point:
       x: float
       y: float
   ```

2. **Use generators for large datasets**
   ```python
   from typing import Iterator
   from pathlib import Path

   # ❌ Loads entire file into memory
   def read_lines(path: Path) -> list[str]:
       with open(path) as file:
           return file.readlines()

   # ✅ Memory efficient generator
   def read_lines(path: Path) -> Iterator[str]:
       with open(path) as file:
           for line in file:
               yield line.rstrip('\n')
   ```

3. **Use `functools.lru_cache` for memoization**
   ```python
   from functools import lru_cache

   @lru_cache(maxsize=128)
   def expensive_computation(n: int) -> int:
       """Memoized expensive computation."""
       if n <= 1:
           return n
       return expensive_computation(n - 1) + expensive_computation(n - 2)
   ```

4. **Use list comprehensions over loops**
   ```python
   # ✅ Fast, pythonic
   squares = [x ** 2 for x in range(100) if x % 2 == 0]

   # ✅ Generator for memory efficiency
   squares_gen = (x ** 2 for x in range(1000000) if x % 2 == 0)
   ```

5. **Profile before optimizing**
   ```bash
   # Profile with cProfile
   python -m cProfile -o profile.stats src/my_rsr_project/main.py

   # Analyze with snakeviz
   pip install snakeviz
   snakeviz profile.stats
   ```

## Common Patterns

### Singleton Pattern
```python
from typing import Self

class Singleton:
    """Thread-safe singleton using __new__."""
    _instance: Self | None = None

    def __new__(cls) -> Self:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

### Factory Pattern
```python
from typing import Protocol
from abc import ABC, abstractmethod

class Shape(Protocol):
    """Shape protocol."""
    def area(self) -> float: ...

class Circle:
    """Circle implementation."""
    def __init__(self, radius: float) -> None:
        self.radius = radius

    def area(self) -> float:
        return 3.14159 * self.radius ** 2

class Square:
    """Square implementation."""
    def __init__(self, side: float) -> None:
        self.side = side

    def area(self) -> float:
        return self.side ** 2

class ShapeFactory:
    """Factory for creating shapes."""

    @staticmethod
    def create_circle(radius: float) -> Circle:
        if radius <= 0:
            raise ValidationError('Radius must be positive')
        return Circle(radius)

    @staticmethod
    def create_square(side: float) -> Square:
        if side <= 0:
            raise ValidationError('Side must be positive')
        return Square(side)
```

### Builder Pattern
```python
from dataclasses import dataclass, field
from typing import Self

@dataclass
class Query:
    """Immutable query object."""
    table: str
    filters: tuple[str, ...] = field(default_factory=tuple)
    order_by: str | None = None

class QueryBuilder:
    """Builder for constructing queries."""

    def __init__(self, table: str) -> None:
        self._table = table
        self._filters: list[str] = []
        self._order_by: str | None = None

    def where(self, condition: str) -> Self:
        """Add a filter condition."""
        self._filters.append(condition)
        return self

    def order_by(self, column: str) -> Self:
        """Set ordering column."""
        self._order_by = column
        return self

    def build(self) -> Query:
        """Build the final query."""
        return Query(
            table=self._table,
            filters=tuple(self._filters),
            order_by=self._order_by,
        )

# Usage
query = (QueryBuilder('users')
         .where('age > 18')
         .where('active = true')
         .order_by('name')
         .build())
```

### Context Manager Pattern
```python
from typing import Self
from pathlib import Path
import tempfile

class TempFile:
    """Context manager for temporary files."""

    def __init__(self, suffix: str = '.txt') -> None:
        self.suffix = suffix
        self.path: Path | None = None

    def __enter__(self) -> Path:
        fd, path = tempfile.mkstemp(suffix=self.suffix)
        self.path = Path(path)
        return self.path

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: object,
    ) -> None:
        if self.path and self.path.exists():
            self.path.unlink()

# Usage
with TempFile('.json') as temp_path:
    temp_path.write_text('{"key": "value"}')
    # File is automatically deleted after the block
```

## Troubleshooting

### Issue: Type errors from mypy

**Solution:** Use proper type annotations and type guards
```python
# ❌ mypy error: Incompatible types
def process(data: dict[str, Any]) -> str:
    return data['key']  # Returns Any, not str

# ✅ Use type narrowing
def process(data: dict[str, Any]) -> str:
    value = data.get('key')
    if not isinstance(value, str):
        raise ValidationError('Key must be a string')
    return value
```

### Issue: Import errors with relative imports

**Solution:** Use absolute imports or explicit relative imports
```python
# ❌ Ambiguous
from . import utils

# ✅ Explicit
from my_rsr_project.utils import helper_function

# ✅ Or explicit relative
from ..utils import helper_function
```

### Issue: Circular imports

**Solution:** Use forward references and TYPE_CHECKING
```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from my_rsr_project.other_module import OtherClass

class MyClass:
    def process(self, other: OtherClass) -> None:
        """Process with forward reference."""
        pass
```

### Issue: Slow test execution

**Solutions:**
1. Use pytest-xdist for parallel testing:
   ```bash
   pip install pytest-xdist
   pytest -n auto
   ```

2. Use pytest markers to skip slow tests:
   ```python
   import pytest

   @pytest.mark.slow
   def test_slow_operation() -> None:
       pass

   # Run without slow tests
   # pytest -m "not slow"
   ```

3. Use fixtures for shared setup:
   ```python
   @pytest.fixture
   def database():
       db = create_database()
       yield db
       db.close()
   ```

## Next Steps

- [Rust Implementation Guide](rust-implementation.md)
- [TypeScript Implementation Guide](typescript-implementation.md)
- [Testing Best Practices](testing-best-practices.md)
- [Security Hardening](security-hardening.md)

## Resources

- [Python Documentation](https://docs.python.org/3/)
- [mypy Documentation](https://mypy.readthedocs.io/)
- [ruff Documentation](https://docs.astral.sh/ruff/)
- [pytest Documentation](https://docs.pytest.org/)
- [Python Type Checking Guide](https://realpython.com/python-type-checking/)
- [Effective Python](https://effectivepython.com/)
- [Python Design Patterns](https://refactoring.guru/design-patterns/python)
