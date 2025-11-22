/**
 * RSR-Compliant TypeScript Example: JSON Schema Validator
 *
 * Demonstrates RSR principles:
 * - Type safety (TypeScript strict mode)
 * - Memory safety (automatic via JS/TS)
 * - Offline-first (no network calls)
 * - Zero npm dependencies (Node.js built-ins only)
 * - Comprehensive error handling
 */

import { readFileSync } from 'node:fs';
import { exit } from 'node:process';

/** JSON Schema type definition */
interface Schema {
  type: 'object' | 'array' | 'string' | 'number' | 'boolean' | 'null';
  required?: string[];
  properties?: Record<string, Schema>;
  items?: Schema;
}

/** Validation error */
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly path: string,
  ) {
    super(`${path}: ${message}`);
    this.name = 'ValidationError';
  }
}

/** Validate a value against a schema */
function validate(value: unknown, schema: Schema, path = 'root'): void {
  // Type checking
  const actualType = getType(value);

  if (actualType !== schema.type) {
    throw new ValidationError(
      `Expected ${schema.type}, got ${actualType}`,
      path,
    );
  }

  // Object validation
  if (schema.type === 'object' && isObject(value)) {
    // Check required properties
    if (schema.required) {
      for (const key of schema.required) {
        if (!(key in value)) {
          throw new ValidationError(`Missing required property: ${key}`, path);
        }
      }
    }

    // Validate properties
    if (schema.properties) {
      for (const [key, propSchema] of Object.entries(schema.properties)) {
        if (key in value) {
          validate(value[key], propSchema, `${path}.${key}`);
        }
      }
    }
  }

  // Array validation
  if (schema.type === 'array' && Array.isArray(value) && schema.items) {
    for (let i = 0; i < value.length; i++) {
      validate(value[i], schema.items, `${path}[${i}]`);
    }
  }
}

/** Get the JSON schema type of a value */
function getType(
  value: unknown,
): 'object' | 'array' | 'string' | 'number' | 'boolean' | 'null' {
  if (value === null) return 'null';
  if (Array.isArray(value)) return 'array';
  if (typeof value === 'object') return 'object';
  if (typeof value === 'string') return 'string';
  if (typeof value === 'number') return 'number';
  if (typeof value === 'boolean') return 'boolean';
  throw new Error(`Unknown type: ${typeof value}`);
}

/** Type guard for objects */
function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

/** Parse JSON with better error messages */
function parseJSON(content: string, filename: string): unknown {
  try {
    return JSON.parse(content);
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error(`Invalid JSON in ${filename}: ${error.message}`);
    }
    throw error;
  }
}

/** Main CLI function */
function main(): void {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.error('Usage: node dist/index.js <schema.json> <data.json>');
    console.error('\nRSR-Compliant JSON Schema Validator');
    console.error('Validates JSON data against a simple schema');
    exit(1);
  }

  const [schemaFile, dataFile] = args;

  try {
    // Read and parse files (Node.js built-ins only)
    const schemaContent = readFileSync(schemaFile, 'utf-8');
    const dataContent = readFileSync(dataFile, 'utf-8');

    const schema = parseJSON(schemaContent, schemaFile) as Schema;
    const data = parseJSON(dataContent, dataFile);

    // Validate
    validate(data, schema);

    console.log('✅ Validation successful!');
    console.log(`\nData conforms to schema from ${schemaFile}`);
  } catch (error) {
    if (error instanceof ValidationError) {
      console.error(`❌ Validation failed: ${error.message}`);
      exit(1);
    } else if (error instanceof Error) {
      console.error(`❌ Error: ${error.message}`);
      exit(1);
    }
    throw error;
  }
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

// Export for testing
export { validate, ValidationError, Schema, getType, isObject };
