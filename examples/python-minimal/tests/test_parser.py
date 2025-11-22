"""Tests for YAML parser."""

import pytest

from yaml_validator.parser import YAMLParseError, parse_yaml


def test_parse_simple_key_value() -> None:
    """Test parsing simple key-value pairs."""
    yaml_content = """
name: TestApp
version: 1.0.0
author: John Doe
"""
    result = parse_yaml(yaml_content)
    assert result["name"] == "TestApp"
    assert result["version"] == "1.0.0"
    assert result["author"] == "John Doe"


def test_parse_with_comments() -> None:
    """Test that comments are ignored."""
    yaml_content = """
# This is a comment
name: TestApp  # inline comment not supported yet
# Another comment
version: 1.0.0
"""
    result = parse_yaml(yaml_content)
    assert result["name"] == "TestApp  # inline comment not supported yet"
    assert result["version"] == "1.0.0"


def test_parse_boolean_values() -> None:
    """Test parsing boolean values."""
    yaml_content = """
active: true
debug: false
enabled: yes
disabled: no
"""
    result = parse_yaml(yaml_content)
    assert result["active"] is True
    assert result["debug"] is False
    assert result["enabled"] is True
    assert result["disabled"] is False


def test_parse_null_values() -> None:
    """Test parsing null values."""
    yaml_content = """
value1: null
value2: ~
"""
    result = parse_yaml(yaml_content)
    assert result["value1"] is None
    assert result["value2"] is None


def test_parse_numbers() -> None:
    """Test parsing integer and float values."""
    yaml_content = """
count: 42
price: 19.99
negative: -10
"""
    result = parse_yaml(yaml_content)
    assert result["count"] == 42
    assert result["price"] == 19.99
    assert result["negative"] == -10


def test_parse_quoted_strings() -> None:
    """Test parsing quoted strings."""
    yaml_content = """
name: "John Doe"
city: 'New York'
"""
    result = parse_yaml(yaml_content)
    assert result["name"] == "John Doe"
    assert result["city"] == "New York"


def test_parse_list() -> None:
    """Test parsing lists."""
    yaml_content = """
features:
- type-safe
- memory-safe
- offline-first
"""
    result = parse_yaml(yaml_content)
    assert result["features"] == ["type-safe", "memory-safe", "offline-first"]


def test_parse_mixed_list() -> None:
    """Test parsing lists with mixed types."""
    yaml_content = """
items:
- 42
- true
- test
- null
"""
    result = parse_yaml(yaml_content)
    assert result["items"] == [42, True, "test", None]


def test_parse_invalid_format() -> None:
    """Test error on invalid format."""
    yaml_content = "invalid line without colon"
    with pytest.raises(YAMLParseError) as exc_info:
        parse_yaml(yaml_content)
    assert "Line 1" in str(exc_info.value)


def test_parse_empty_key() -> None:
    """Test error on empty key."""
    yaml_content = ": value"
    with pytest.raises(YAMLParseError) as exc_info:
        parse_yaml(yaml_content)
    assert "Empty key" in str(exc_info.value)


def test_parse_list_without_key() -> None:
    """Test error on list item without key."""
    yaml_content = "- orphan item"
    with pytest.raises(YAMLParseError) as exc_info:
        parse_yaml(yaml_content)
    assert "List item without a key" in str(exc_info.value)


def test_parse_empty_content() -> None:
    """Test parsing empty content."""
    result = parse_yaml("")
    assert result == {}


def test_parse_only_comments() -> None:
    """Test parsing content with only comments."""
    yaml_content = """
# Comment 1
# Comment 2
"""
    result = parse_yaml(yaml_content)
    assert result == {}
