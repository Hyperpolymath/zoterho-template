# TypeScript Implementation Guide

Complete guide for creating RSR-compliant TypeScript projects.

## Prerequisites

- Node.js 18+ LTS (`nvm install --lts`)
- npm 9+ or pnpm 8+ (comes with Node.js)
- TypeScript 5.0+ (`npm install -g typescript`)
- Optional: `tsx`, `ts-node` for running TypeScript directly

## Quick Start

```bash
# Create new TypeScript project
mkdir my-rsr-project
cd my-rsr-project
npm init -y

# Install TypeScript and essential tools
npm install --save-dev typescript @types/node
npm install --save-dev eslint prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Initialize TypeScript
npx tsc --init

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
│   ├── index.ts          # Entry point
│   ├── types.ts          # Type definitions
│   ├── errors.ts         # Error types
│   └── utils.ts          # Utility functions
├── tests/
│   ├── unit/
│   │   └── index.test.ts
│   └── integration/
│       └── integration.test.ts
├── dist/                 # Compiled output
├── package.json          # Project manifest
├── package-lock.json     # Dependency lock file
├── tsconfig.json         # TypeScript configuration
├── .eslintrc.json        # ESLint configuration
├── .prettierrc           # Prettier configuration
├── README.md             # RSR-compliant README
├── LICENSE.txt           # Dual MIT + Palimpsest
├── SECURITY.md           # Security policy
└── .well-known/          # RFC 9116 compliance
```

## TypeScript Configuration (tsconfig.json)

```json
{
  "compilerOptions": {
    /* Language and Environment */
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",

    /* Type Checking - STRICT MODE (RSR Requirement) */
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,

    /* Additional Safety */
    "exactOptionalPropertyTypes": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,

    /* Emit */
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "removeComments": true,
    "noEmitOnError": true,

    /* Interop Constraints */
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

## Package.json Configuration

```json
{
  "name": "my-rsr-project",
  "version": "0.1.0",
  "description": "RSR-compliant TypeScript project",
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "scripts": {
    "build": "tsc",
    "test": "node --test --experimental-test-coverage",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write \"src/**/*.ts\"",
    "format:check": "prettier --check \"src/**/*.ts\"",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist",
    "prepublishOnly": "npm run clean && npm run build && npm test"
  },
  "keywords": ["rsr", "rhodium", "typescript"],
  "author": "Your Name <email@example.com>",
  "license": "MIT OR Palimpsest-0.8",
  "repository": {
    "type": "git",
    "url": "https://github.com/username/my-rsr-project"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.50.0",
    "prettier": "^3.0.0",
    "typescript": "^5.2.0"
  },
  "dependencies": {}
}
```

## RSR Compliance Checklist

### 1. Type Safety ✅

**TypeScript provides compile-time type safety with strict mode enabled.**

Best practices:
- Enable ALL strict compiler options
- Use branded types for domain-specific values
- Avoid `any` type (use `unknown` if needed)
- Use discriminated unions for variants
- Leverage type guards and narrowing

```typescript
// ❌ Using 'any' loses type safety
function processData(data: any) {
  return data.value;
}

// ✅ Use proper types
interface UserData {
  readonly id: number;
  readonly name: string;
  readonly email: string;
}

function processData(data: UserData): string {
  return data.name;
}

// ✅ Branded types for domain values
type UserId = number & { readonly __brand: 'UserId' };
type Email = string & { readonly __brand: 'Email' };

function createUserId(id: number): UserId {
  return id as UserId;
}

function createEmail(email: string): Email | Error {
  if (!email.includes('@')) {
    return new Error('Invalid email format');
  }
  return email as Email;
}
```

### 2. Memory Safety ✅

**TypeScript runs on V8 with automatic garbage collection.**

Best practices:
- Avoid memory leaks from closures and event listeners
- Use `WeakMap` and `WeakSet` for caching
- Clean up resources explicitly
- Avoid global state mutation

```typescript
// ❌ Memory leak - event listener not cleaned
class Component {
  constructor() {
    window.addEventListener('resize', () => {
      this.handleResize();
    });
  }

  handleResize() { /* ... */ }
}

// ✅ Proper cleanup
class Component {
  private resizeHandler = () => this.handleResize();

  constructor() {
    window.addEventListener('resize', this.resizeHandler);
  }

  destroy() {
    window.removeEventListener('resize', this.resizeHandler);
  }

  private handleResize() { /* ... */ }
}

// ✅ Use WeakMap for caching
const cache = new WeakMap<object, string>();

function memoize(obj: object): string {
  if (cache.has(obj)) {
    return cache.get(obj)!;
  }
  const result = expensiveOperation(obj);
  cache.set(obj, result);
  return result;
}
```

### 3. Offline-First ✅

**Zero network dependencies for Bronze level.**

```json
{
  "dependencies": {
    // ❌ No network dependencies
    // "axios": "^1.0.0",
    // "node-fetch": "^3.0.0",

    // ✅ Offline-friendly only
    // Local utilities, pure functions, data structures
  }
}
```

Verification:
```bash
# Check dependencies
npm list --all

# Audit for network-related packages
npm audit
```

### 4. Zero Dependencies (Ideal)

**For Bronze level, use only Node.js built-ins.**

```typescript
// ✅ Using only Node.js standard library
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// Pure TypeScript with no runtime dependencies
class DataStore {
  private data = new Map<string, unknown>();

  set(key: string, value: unknown): void {
    this.data.set(key, value);
  }

  get<T>(key: string): T | undefined {
    return this.data.get(key) as T | undefined;
  }
}
```

### 5. Comprehensive Testing

**100% test pass rate required.**

Using Node.js built-in test runner (Node 18+):
```typescript
// tests/unit/index.test.ts
import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { processData, createEmail } from '../../src/index.js';

describe('processData', () => {
  test('should process valid user data', () => {
    const data = { id: 1, name: 'Alice', email: 'alice@example.com' };
    const result = processData(data);
    assert.equal(result, 'Alice');
  });

  test('should handle missing data', () => {
    const data = { id: 1, name: '', email: 'alice@example.com' };
    const result = processData(data);
    assert.equal(result, '');
  });
});

describe('createEmail', () => {
  test('should validate email format', () => {
    const result = createEmail('invalid');
    assert.ok(result instanceof Error);
  });

  test('should accept valid email', () => {
    const result = createEmail('valid@example.com');
    assert.equal(typeof result, 'string');
  });
});
```

Run tests:
```bash
# Run all tests
npm test

# Run with coverage
node --test --experimental-test-coverage

# Run specific test file
node --test tests/unit/index.test.ts
```

### 6. Error Handling

**Use custom error classes with proper typing.**

```typescript
// src/errors.ts
export abstract class AppError extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  readonly code = 'VALIDATION_ERROR';

  constructor(message: string, public readonly field?: string) {
    super(message);
  }
}

export class NotFoundError extends AppError {
  readonly code = 'NOT_FOUND';

  constructor(message: string, public readonly resource?: string) {
    super(message);
  }
}

export class ParseError extends AppError {
  readonly code = 'PARSE_ERROR';

  constructor(message: string, public readonly input?: string) {
    super(message);
  }
}

// Result type for safer error handling
export type Result<T, E = Error> =
  | { success: true; value: T }
  | { success: false; error: E };

// Helper functions
export function ok<T>(value: T): Result<T, never> {
  return { success: true, value };
}

export function err<E>(error: E): Result<never, E> {
  return { success: false, error };
}

// Usage example
function parseUserInput(input: string): Result<UserData, ValidationError> {
  if (!input) {
    return err(new ValidationError('Input cannot be empty'));
  }

  try {
    const data = JSON.parse(input);
    return ok(data);
  } catch (e) {
    return err(new ValidationError('Invalid JSON format'));
  }
}
```

### 7. Code Quality Tools

**ESLint Configuration (.eslintrc.json):**

```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking",
    "plugin:@typescript-eslint/strict"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": ["error", {
      "argsIgnorePattern": "^_",
      "varsIgnorePattern": "^_"
    }],
    "@typescript-eslint/explicit-function-return-type": "error",
    "@typescript-eslint/no-non-null-assertion": "error",
    "@typescript-eslint/strict-boolean-expressions": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "prefer-const": "error",
    "no-var": "error"
  }
}
```

**Prettier Configuration (.prettierrc):**

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

Run quality checks:
```bash
# Lint code
npm run lint

# Fix auto-fixable issues
npm run lint -- --fix

# Format code
npm run format

# Check formatting
npm run format:check

# Type check without emitting
npm run type-check
```

## Build Automation

**justfile recipes:**

```just
# Run all tests
test:
    npm test

# Build project
build:
    npm run clean
    npm run build

# Run linter
lint:
    npm run lint

# Format code
format:
    npm run format

# Type check
type-check:
    npm run type-check

# Full CI pipeline
ci: type-check lint test build

# Pre-commit checks
pre-commit: format lint type-check test
```

## Security Best Practices

1. **Dependency Auditing**
   ```bash
   # Check for vulnerabilities
   npm audit

   # Fix vulnerabilities
   npm audit fix

   # Check for outdated packages
   npm outdated
   ```

2. **Input Validation**
   ```typescript
   function validateInput(input: unknown): asserts input is string {
     if (typeof input !== 'string') {
       throw new ValidationError('Input must be a string');
     }
     if (input.length === 0) {
       throw new ValidationError('Input cannot be empty');
     }
     if (input.length > 1000) {
       throw new ValidationError('Input too long');
     }
   }

   // Usage
   function processInput(input: unknown): string {
     validateInput(input); // After this, TypeScript knows input is string
     return input.toUpperCase();
   }
   ```

3. **Avoid Prototype Pollution**
   ```typescript
   // ❌ Dangerous - prototype pollution
   function merge(target: any, source: any) {
     for (const key in source) {
       target[key] = source[key];
     }
   }

   // ✅ Safe merge with Object.create(null)
   function safeMerge<T extends Record<string, unknown>>(
     target: T,
     source: Partial<T>
   ): T {
     const safeTarget = Object.create(null) as T;
     const allowedKeys = Object.keys(target);

     for (const key of allowedKeys) {
       safeTarget[key] = key in source ? source[key]! : target[key];
     }

     return safeTarget;
   }
   ```

4. **Secure Defaults**
   ```typescript
   interface Config {
     readonly debug: boolean;
     readonly verbose: boolean;
     readonly maxRetries: number;
   }

   const DEFAULT_CONFIG: Readonly<Config> = {
     debug: false,      // Secure default
     verbose: false,    // Secure default
     maxRetries: 3,
   } as const;

   function createConfig(overrides?: Partial<Config>): Config {
     return { ...DEFAULT_CONFIG, ...overrides };
   }
   ```

## Documentation

**TSDoc comments:**

```typescript
/**
 * Parses a configuration file and returns typed configuration object.
 *
 * @param path - Path to the configuration file
 * @returns Parsed configuration object
 * @throws {ValidationError} If the file contains invalid data
 * @throws {NotFoundError} If the file doesn't exist
 *
 * @example
 * ```typescript
 * const config = parseConfig('./config.json');
 * console.log(config.appName);
 * ```
 *
 * @remarks
 * This function reads the file synchronously and should only be used
 * during application initialization.
 */
export function parseConfig(path: string): Config {
  // Implementation
}
```

Generate documentation:
```bash
# Using TypeDoc
npm install --save-dev typedoc
npx typedoc --out docs src
```

## Performance Tips

1. **Use const assertions for immutable data**
   ```typescript
   // ✅ Literal types, fully immutable
   const CONFIG = {
     maxUsers: 100,
     timeout: 5000,
     features: ['auth', 'api'],
   } as const;

   type Config = typeof CONFIG;
   ```

2. **Avoid unnecessary computations**
   ```typescript
   // ❌ Recomputes on every access
   class Calculator {
     get expensiveValue(): number {
       return this.data.reduce((sum, n) => sum + n ** 2, 0);
     }
   }

   // ✅ Memoize expensive computations
   class Calculator {
     private _cachedValue?: number;

     get expensiveValue(): number {
       if (this._cachedValue === undefined) {
         this._cachedValue = this.data.reduce((sum, n) => sum + n ** 2, 0);
       }
       return this._cachedValue;
     }
   }
   ```

3. **Use discriminated unions for performance**
   ```typescript
   // ✅ Fast type narrowing
   type Response =
     | { status: 'success'; data: UserData }
     | { status: 'error'; error: Error };

   function handleResponse(response: Response): void {
     if (response.status === 'success') {
       // TypeScript knows response.data exists
       console.log(response.data);
     } else {
       // TypeScript knows response.error exists
       console.error(response.error);
     }
   }
   ```

4. **Optimize imports**
   ```typescript
   // ❌ Imports entire module
   import * as fs from 'node:fs';

   // ✅ Import only what you need
   import { readFileSync } from 'node:fs';
   ```

## Common Patterns

### Factory Pattern
```typescript
interface User {
  readonly id: number;
  readonly name: string;
  readonly email: string;
}

class UserFactory {
  private static nextId = 1;

  static create(name: string, email: string): Result<User, ValidationError> {
    if (!name) {
      return err(new ValidationError('Name is required', 'name'));
    }
    if (!email.includes('@')) {
      return err(new ValidationError('Invalid email', 'email'));
    }

    return ok({
      id: UserFactory.nextId++,
      name,
      email,
    });
  }
}
```

### Builder Pattern
```typescript
class QueryBuilder {
  private filters: Array<(item: unknown) => boolean> = [];
  private sortKey?: string;

  where(predicate: (item: unknown) => boolean): this {
    this.filters.push(predicate);
    return this;
  }

  orderBy(key: string): this {
    this.sortKey = key;
    return this;
  }

  execute<T>(data: T[]): T[] {
    let result = data.filter((item) =>
      this.filters.every((filter) => filter(item))
    );

    if (this.sortKey) {
      result = result.sort((a, b) => {
        const aVal = (a as any)[this.sortKey!];
        const bVal = (b as any)[this.sortKey!];
        return aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
      });
    }

    return result;
  }
}

// Usage
const results = new QueryBuilder()
  .where((user: any) => user.age > 18)
  .where((user: any) => user.active)
  .orderBy('name')
  .execute(users);
```

### Type Guard Pattern
```typescript
interface Cat {
  type: 'cat';
  meow(): void;
}

interface Dog {
  type: 'dog';
  bark(): void;
}

type Animal = Cat | Dog;

// Type guard
function isCat(animal: Animal): animal is Cat {
  return animal.type === 'cat';
}

function makeSound(animal: Animal): void {
  if (isCat(animal)) {
    animal.meow(); // TypeScript knows this is Cat
  } else {
    animal.bark(); // TypeScript knows this is Dog
  }
}
```

## Troubleshooting

### Issue: "Type 'X' is not assignable to type 'Y'"

**Solution:** Enable stricter type checking and use type assertions carefully
```typescript
// ❌ Unsafe type assertion
const value = input as SomeType;

// ✅ Validate before asserting
function isValidType(input: unknown): input is SomeType {
  return typeof input === 'object' && input !== null && 'property' in input;
}

if (isValidType(input)) {
  const value = input; // TypeScript knows it's SomeType
}
```

### Issue: "Object is possibly 'null' or 'undefined'"

**Solution:** Use optional chaining and nullish coalescing
```typescript
// ❌ Runtime error if user is null
const name = user.profile.name;

// ✅ Safe access
const name = user?.profile?.name ?? 'Unknown';

// ✅ Or validate explicitly
if (user?.profile?.name) {
  const name = user.profile.name; // TypeScript knows it exists
}
```

### Issue: Module resolution errors

**Solution:** Use proper module specifiers
```typescript
// ❌ Missing .js extension (required for ESM)
import { helper } from './helper';

// ✅ Include .js extension
import { helper } from './helper.js';

// In tsconfig.json
{
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

### Issue: Slow TypeScript compilation

**Solutions:**
1. Use project references for large codebases
2. Enable incremental compilation:
   ```json
   {
     "compilerOptions": {
       "incremental": true,
       "tsBuildInfoFile": "./dist/.tsbuildinfo"
     }
   }
   ```
3. Use `skipLibCheck: true` in tsconfig.json
4. Limit type checking during development:
   ```bash
   # Fast iteration
   npm run build -- --noCheck

   # Separate type checking
   npm run type-check
   ```

## Next Steps

- [Rust Implementation Guide](rust-implementation.md)
- [Python Implementation Guide](python-implementation.md)
- [Testing Best Practices](testing-best-practices.md)
- [Security Hardening](security-hardening.md)

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Type Challenges](https://github.com/type-challenges/type-challenges)
- [ESLint TypeScript](https://typescript-eslint.io/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Clean Code TypeScript](https://github.com/labs42io/clean-code-typescript)
