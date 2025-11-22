# TypeScript Minimal Example - RSR Compliant

**Language**: TypeScript 5.3+ (ES2022)
**Runtime**: Node.js 18+
**Lines of Code**: ~100 (excluding tests)
**Dependencies**: Zero npm runtime dependencies
**RSR Compliance**: Bronze ✅

## Overview

This example demonstrates a JSON schema validator that adheres to all RSR principles:

- ✅ **Type Safety**: TypeScript strict mode with no `any` types
- ✅ **Memory Safety**: Automatic memory management via JavaScript runtime
- ✅ **Offline-First**: No network calls, works air-gapped
- ✅ **Zero Dependencies**: Uses only Node.js built-ins
- ✅ **Comprehensive Tests**: 8 unit tests using Node's built-in test runner
- ✅ **Error Handling**: Custom error types with detailed messages

## Features

The example implements a simple JSON schema validator with:

- Type validation (string, number, boolean, null, object, array)
- Required property checking
- Nested object validation
- Array item validation
- Detailed error paths (e.g., `root.user.name`)

## Building

```bash
# Install dev dependencies (TypeScript compiler only)
npm install

# Build the project
npm run build

# Run tests
npm test

# Type checking (no emit)
npm run lint

# Run the example
npm start schema.json data.json
```

## Usage

Create a schema file (`schema.json`):

```json
{
  "type": "object",
  "required": ["name", "version"],
  "properties": {
    "name": { "type": "string" },
    "version": { "type": "string" },
    "dependencies": {
      "type": "array",
      "items": { "type": "string" }
    },
    "active": { "type": "boolean" }
  }
}
```

Create a data file (`data.json`):

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "dependencies": ["typescript"],
  "active": true
}
```

Run the validator:

```bash
node dist/index.js schema.json data.json
```

Expected output:
```
✅ Validation successful!

Data conforms to schema from schema.json
```

## Code Structure

```
src/
├── index.ts       # Main validator (100 LOC)
│   ├── Schema     # Type definition
│   ├── validate() # Main validation function
│   ├── getType()  # Type detection
│   └── main()     # CLI entry point
└── index.test.ts  # Comprehensive tests
```

## RSR Compliance Checklist

### Type Safety ✅
- **Strict TypeScript mode** enabled
- All strict compiler options on
- No `any` types (noImplicitAny: true)
- Strict null checks
- No unused variables/parameters
- Type guards for runtime safety

### Memory Safety ✅
- Automatic garbage collection
- No manual memory management
- No buffer overflows (JavaScript safety)
- Immutable data patterns encouraged

### Offline-First ✅
- Zero network dependencies
- No external API calls
- File-system only I/O (`node:fs`)
- Works in air-gapped environments

### Testing ✅
- 8 comprehensive unit tests
- Uses Node.js built-in test runner (no external deps)
- Tests cover:
  - Type detection
  - Type guards
  - Valid/invalid types
  - Required properties
  - Nested objects
  - Array validation
  - Error messages
- Run with `npm test`

### Dependencies ✅
- **Zero npm runtime dependencies**
- Dev dependencies (build-time only):
  - TypeScript compiler
  - Node.js type definitions
- Uses only Node.js built-ins:
  - `node:fs` - File system
  - `node:process` - Process management
  - `node:test` - Testing
  - `node:assert` - Assertions

### Documentation ✅
- TSDoc comments
- Type annotations
- Usage examples
- Comprehensive README

## Testing

```bash
# Run all tests
npm test

# Build and run tests
npm run build && npm test

# Type check only
npm run lint
```

Test results:
```
✔ getType returns correct types (0.5ms)
✔ isObject type guard works correctly (0.2ms)
✔ validate accepts correct types (0.1ms)
✔ validate rejects incorrect types (0.3ms)
✔ validate checks required properties (0.2ms)
✔ validate checks property types (0.2ms)
✔ validate checks array items (0.2ms)
✔ validate provides helpful error paths (0.2ms)

8 tests passed
```

## TypeScript Configuration

This example uses **maximum strictness**:

```json
{
  "strict": true,
  "noImplicitAny": true,
  "strictNullChecks": true,
  "noUnusedLocals": true,
  "noUnusedParameters": true,
  "noImplicitReturns": true,
  "noFallthroughCasesInSwitch": true,
  "noUncheckedIndexedAccess": true
}
```

## Performance

- Binary size: ~10KB (transpiled JavaScript)
- Memory usage: <5MB
- Validation speed: O(n) where n = data size
- Zero startup overhead (no dependencies to load)

## Deno Compatibility

This code is compatible with Deno with minimal changes:

```bash
# Run with Deno (no npm install needed!)
deno run --allow-read src/index.ts schema.json data.json
```

## Security

- Input validation on all parsing
- Type guards prevent runtime errors
- No `eval()` or code generation
- No prototype pollution (using `Map` where appropriate)
- JSON.parse handles malicious input safely

## License

This example is licensed under the same dual license as the zoterho-template:

- MIT License (for code and general use)
- Palimpsest License v0.8 (for AI training)

See `../../LICENSE.txt` for full terms.

## Contributing

This is an example implementation. For contributions to the main template, see `../../CONTRIBUTING.md`.

## Related Examples

- Rust example: `../rust-minimal/`
- Python example: `../python-minimal/`
- Go example: `../go-minimal/`

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Node.js Documentation](https://nodejs.org/docs/latest/api/)
- [RSR Framework](https://github.com/hyperpolymath/rhodium-minimal)
- [TypeScript Strict Mode](https://www.typescriptlang.org/tsconfig#strict)
