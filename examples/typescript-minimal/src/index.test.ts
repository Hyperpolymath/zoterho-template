/**
 * Tests for JSON Schema Validator
 * Using Node.js built-in test runner (no external dependencies)
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validate, ValidationError, getType, isObject, type Schema } from './index.js';

test('getType returns correct types', () => {
  assert.equal(getType(null), 'null');
  assert.equal(getType([]), 'array');
  assert.equal(getType({}), 'object');
  assert.equal(getType(''), 'string');
  assert.equal(getType(42), 'number');
  assert.equal(getType(true), 'boolean');
});

test('isObject type guard works correctly', () => {
  assert.equal(isObject({}), true);
  assert.equal(isObject({ key: 'value' }), true);
  assert.equal(isObject([]), false);
  assert.equal(isObject(null), false);
  assert.equal(isObject('string'), false);
});

test('validate accepts correct types', () => {
  const schema: Schema = { type: 'string' };
  assert.doesNotThrow(() => validate('hello', schema));
});

test('validate rejects incorrect types', () => {
  const schema: Schema = { type: 'string' };
  assert.throws(
    () => validate(42, schema),
    (error: unknown) => {
      return (
        error instanceof ValidationError &&
        error.message.includes('Expected string, got number')
      );
    },
  );
});

test('validate checks required properties', () => {
  const schema: Schema = {
    type: 'object',
    required: ['name', 'version'],
    properties: {
      name: { type: 'string' },
      version: { type: 'string' },
    },
  };

  // Valid object
  assert.doesNotThrow(() =>
    validate({ name: 'test', version: '1.0' }, schema),
  );

  // Missing required property
  assert.throws(
    () => validate({ name: 'test' }, schema),
    (error: unknown) => {
      return (
        error instanceof ValidationError &&
        error.message.includes('Missing required property: version')
      );
    },
  );
});

test('validate checks property types', () => {
  const schema: Schema = {
    type: 'object',
    properties: {
      count: { type: 'number' },
      active: { type: 'boolean' },
    },
  };

  // Valid
  assert.doesNotThrow(() =>
    validate({ count: 42, active: true }, schema),
  );

  // Invalid property type
  assert.throws(
    () => validate({ count: 'not a number' }, schema),
    ValidationError,
  );
});

test('validate checks array items', () => {
  const schema: Schema = {
    type: 'array',
    items: { type: 'string' },
  };

  // Valid
  assert.doesNotThrow(() => validate(['a', 'b', 'c'], schema));

  // Invalid item type
  assert.throws(
    () => validate(['a', 42, 'c'], schema),
    (error: unknown) => {
      return (
        error instanceof ValidationError &&
        error.message.includes('root[1]')
      );
    },
  );
});

test('validate provides helpful error paths', () => {
  const schema: Schema = {
    type: 'object',
    properties: {
      user: {
        type: 'object',
        properties: {
          name: { type: 'string' },
        },
      },
    },
  };

  assert.throws(
    () => validate({ user: { name: 123 } }, schema),
    (error: unknown) => {
      return (
        error instanceof ValidationError &&
        error.path === 'root.user.name'
      );
    },
  );
});
