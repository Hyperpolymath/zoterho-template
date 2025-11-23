# Security Hardening Guide

This comprehensive guide covers security hardening practices for RSR-compliant projects across all supported languages (Rust, TypeScript, Python).

## Table of Contents

1. [OWASP Top 10 Mitigation](#owasp-top-10-mitigation)
2. [Input Validation and Sanitization](#input-validation-and-sanitization)
3. [Authentication and Authorization](#authentication-and-authorization)
4. [Cryptography and Secrets Management](#cryptography-and-secrets-management)
5. [Dependency Security](#dependency-security)
6. [Code Injection Prevention](#code-injection-prevention)
7. [Security Testing](#security-testing)
8. [Security Headers and HTTPS](#security-headers-and-https)
9. [Language-Specific Security](#language-specific-security)
10. [Security Audit Checklist](#security-audit-checklist)
11. [Incident Response](#incident-response)

## OWASP Top 10 Mitigation

### A01:2021 - Broken Access Control

**Problem**: Users can act outside their intended permissions.

**Mitigation**:

```typescript
// TypeScript - Implement role-based access control
interface User {
  id: string;
  roles: string[];
}

class AccessControl {
  private permissions: Map<string, Set<string>> = new Map([
    ['admin', new Set(['read', 'write', 'delete', 'manage_users'])],
    ['user', new Set(['read', 'write'])],
    ['guest', new Set(['read'])]
  ]);

  canAccess(user: User, resource: string, action: string): boolean {
    // Deny by default
    if (!user || !user.roles) return false;

    // Check if any of user's roles grant permission
    return user.roles.some(role => {
      const perms = this.permissions.get(role);
      return perms?.has(action) ?? false;
    });
  }
}

// Usage
function deleteResource(user: User, resourceId: string): void {
  const ac = new AccessControl();
  if (!ac.canAccess(user, 'resource', 'delete')) {
    throw new Error('Access denied');
  }
  // Proceed with deletion
}
```

```rust
// Rust - Type-safe authorization
use std::collections::HashSet;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Permission {
    Read,
    Write,
    Delete,
    ManageUsers,
}

#[derive(Debug, Clone)]
pub enum Role {
    Admin,
    User,
    Guest,
}

impl Role {
    pub fn permissions(&self) -> HashSet<Permission> {
        match self {
            Role::Admin => vec![
                Permission::Read,
                Permission::Write,
                Permission::Delete,
                Permission::ManageUsers,
            ].into_iter().collect(),
            Role::User => vec![Permission::Read, Permission::Write].into_iter().collect(),
            Role::Guest => vec![Permission::Read].into_iter().collect(),
        }
    }
}

pub struct User {
    pub id: String,
    pub roles: Vec<Role>,
}

impl User {
    pub fn can(&self, permission: Permission) -> bool {
        self.roles.iter()
            .flat_map(|role| role.permissions())
            .any(|p| p == permission)
    }
}
```

```python
# Python - Decorator-based access control
from functools import wraps
from enum import Enum
from typing import Set, Callable

class Permission(Enum):
    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    MANAGE_USERS = "manage_users"

class Role(Enum):
    ADMIN = "admin"
    USER = "user"
    GUEST = "guest"

ROLE_PERMISSIONS = {
    Role.ADMIN: {Permission.READ, Permission.WRITE, Permission.DELETE, Permission.MANAGE_USERS},
    Role.USER: {Permission.READ, Permission.WRITE},
    Role.GUEST: {Permission.READ},
}

class User:
    def __init__(self, user_id: str, roles: list[Role]):
        self.id = user_id
        self.roles = roles

    def can(self, permission: Permission) -> bool:
        return any(
            permission in ROLE_PERMISSIONS.get(role, set())
            for role in self.roles
        )

def require_permission(permission: Permission):
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user = kwargs.get('user') or (args[0] if args else None)
            if not isinstance(user, User) or not user.can(permission):
                raise PermissionError(f"Permission {permission.value} required")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@require_permission(Permission.DELETE)
def delete_resource(user: User, resource_id: str) -> None:
    # Delete logic here
    pass
```

### A02:2021 - Cryptographic Failures

**Problem**: Sensitive data exposed due to weak or missing encryption.

**Mitigation**:

```typescript
// TypeScript - Secure password hashing with Argon2
import argon2 from 'argon2';

class PasswordHasher {
  private static readonly MEMORY_COST = 65536; // 64 MB
  private static readonly TIME_COST = 3;
  private static readonly PARALLELISM = 4;

  static async hash(password: string): Promise<string> {
    return argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: this.MEMORY_COST,
      timeCost: this.TIME_COST,
      parallelism: this.PARALLELISM,
    });
  }

  static async verify(hash: string, password: string): Promise<boolean> {
    try {
      return await argon2.verify(hash, password);
    } catch {
      return false;
    }
  }
}

// Encrypt sensitive data at rest
import { createCipheriv, createDecipheriv, randomBytes, scrypt } from 'crypto';
import { promisify } from 'util';

const scryptAsync = promisify(scrypt);

class DataEncryption {
  private static readonly ALGORITHM = 'aes-256-gcm';
  private static readonly KEY_LENGTH = 32;
  private static readonly IV_LENGTH = 16;
  private static readonly TAG_LENGTH = 16;

  static async encrypt(plaintext: string, masterKey: string): Promise<string> {
    const iv = randomBytes(this.IV_LENGTH);
    const key = await scryptAsync(masterKey, 'salt', this.KEY_LENGTH) as Buffer;

    const cipher = createCipheriv(this.ALGORITHM, key, iv);
    const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();

    // Format: iv:tag:ciphertext
    return `${iv.toString('base64')}:${tag.toString('base64')}:${encrypted.toString('base64')}`;
  }

  static async decrypt(ciphertext: string, masterKey: string): Promise<string> {
    const [ivStr, tagStr, encryptedStr] = ciphertext.split(':');
    const iv = Buffer.from(ivStr, 'base64');
    const tag = Buffer.from(tagStr, 'base64');
    const encrypted = Buffer.from(encryptedStr, 'base64');

    const key = await scryptAsync(masterKey, 'salt', this.KEY_LENGTH) as Buffer;

    const decipher = createDecipheriv(this.ALGORITHM, key, iv);
    decipher.setAuthTag(tag);

    return decipher.update(encrypted) + decipher.final('utf8');
  }
}
```

```rust
// Rust - Secure encryption with authenticated encryption
use argon2::{
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    Aes256Gcm, Nonce,
};
use rand::RngCore;

pub struct SecurePassword;

impl SecurePassword {
    pub fn hash(password: &str) -> Result<String, argon2::password_hash::Error> {
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        let hash = argon2.hash_password(password.as_bytes(), &salt)?;
        Ok(hash.to_string())
    }

    pub fn verify(hash: &str, password: &str) -> Result<bool, argon2::password_hash::Error> {
        let parsed_hash = PasswordHash::new(hash)?;
        Ok(Argon2::default()
            .verify_password(password.as_bytes(), &parsed_hash)
            .is_ok())
    }
}

pub struct DataEncryption;

impl DataEncryption {
    pub fn encrypt(plaintext: &str, key: &[u8; 32]) -> Result<Vec<u8>, aes_gcm::Error> {
        let cipher = Aes256Gcm::new(key.into());
        let mut nonce_bytes = [0u8; 12];
        OsRng.fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        let mut ciphertext = cipher.encrypt(nonce, plaintext.as_bytes())?;

        // Prepend nonce to ciphertext
        let mut result = nonce_bytes.to_vec();
        result.append(&mut ciphertext);
        Ok(result)
    }

    pub fn decrypt(ciphertext: &[u8], key: &[u8; 32]) -> Result<String, aes_gcm::Error> {
        if ciphertext.len() < 12 {
            return Err(aes_gcm::Error);
        }

        let (nonce_bytes, encrypted) = ciphertext.split_at(12);
        let nonce = Nonce::from_slice(nonce_bytes);
        let cipher = Aes256Gcm::new(key.into());

        let plaintext = cipher.decrypt(nonce, encrypted)?;
        Ok(String::from_utf8(plaintext).unwrap_or_default())
    }
}
```

### A03:2021 - Injection

See [Code Injection Prevention](#code-injection-prevention) section.

### A04:2021 - Insecure Design

**Mitigation**: Follow secure design principles:

1. **Defense in Depth**: Multiple layers of security
2. **Principle of Least Privilege**: Minimal necessary access
3. **Secure by Default**: Safe defaults, opt-in for risky features
4. **Fail Securely**: Errors should deny access, not grant it

```typescript
// Example: Secure by default configuration
interface SecurityConfig {
  allowInsecureConnections: boolean;
  maxLoginAttempts: number;
  sessionTimeout: number; // in seconds
  requireMFA: boolean;
}

const DEFAULT_CONFIG: SecurityConfig = {
  allowInsecureConnections: false, // Secure by default
  maxLoginAttempts: 3,
  sessionTimeout: 900, // 15 minutes
  requireMFA: true,
};

class SecurityManager {
  private config: SecurityConfig;

  constructor(overrides?: Partial<SecurityConfig>) {
    this.config = { ...DEFAULT_CONFIG, ...overrides };

    // Validate that overrides don't weaken security
    if (this.config.allowInsecureConnections) {
      console.warn('WARNING: Insecure connections are allowed!');
    }
  }
}
```

### A05:2021 - Security Misconfiguration

**Mitigation**:

```yaml
# Docker security best practices
# Dockerfile
FROM node:20-alpine AS builder

# Don't run as root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set secure working directory
WORKDIR /app

# Copy dependencies first (layer caching)
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

COPY . .
RUN npm run build

# Production image
FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy only necessary files
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Drop privileges
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "dist/index.js"]
```

### A06:2021 - Vulnerable and Outdated Components

See [Dependency Security](#dependency-security) section.

### A07:2021 - Identification and Authentication Failures

See [Authentication and Authorization](#authentication-and-authorization) section.

### A08:2021 - Software and Data Integrity Failures

**Mitigation**:

```typescript
// Implement Subresource Integrity (SRI) for external resources
const ALLOWED_RESOURCES = new Map<string, string>([
  [
    'https://cdn.example.com/library.js',
    'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
  ],
]);

function validateResourceIntegrity(url: string, hash: string): boolean {
  const expectedHash = ALLOWED_RESOURCES.get(url);
  return expectedHash === hash;
}

// Digital signatures for critical data
import { createSign, createVerify } from 'crypto';

class DataSigner {
  static sign(data: string, privateKey: string): string {
    const sign = createSign('SHA256');
    sign.update(data);
    sign.end();
    return sign.sign(privateKey, 'base64');
  }

  static verify(data: string, signature: string, publicKey: string): boolean {
    const verify = createVerify('SHA256');
    verify.update(data);
    verify.end();
    return verify.verify(publicKey, signature, 'base64');
  }
}
```

### A09:2021 - Security Logging and Monitoring Failures

**Mitigation**:

```typescript
// Comprehensive security logging
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'security-audit' },
  transports: [
    new winston.transports.File({ filename: 'security-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'security-combined.log' }),
  ],
});

interface SecurityEvent {
  type: 'login' | 'logout' | 'access_denied' | 'data_access' | 'config_change';
  userId?: string;
  ip: string;
  timestamp: Date;
  success: boolean;
  metadata?: Record<string, unknown>;
}

class SecurityAudit {
  static log(event: SecurityEvent): void {
    securityLogger.info({
      ...event,
      timestamp: event.timestamp.toISOString(),
    });

    // Alert on suspicious activity
    if (event.type === 'access_denied') {
      this.checkForBruteForce(event);
    }
  }

  private static loginAttempts = new Map<string, number[]>();

  private static checkForBruteForce(event: SecurityEvent): void {
    const key = `${event.userId || 'unknown'}:${event.ip}`;
    const attempts = this.loginAttempts.get(key) || [];
    const now = Date.now();

    // Keep only attempts from last 15 minutes
    const recentAttempts = attempts.filter(t => now - t < 15 * 60 * 1000);
    recentAttempts.push(now);
    this.loginAttempts.set(key, recentAttempts);

    // Alert if more than 5 attempts in 15 minutes
    if (recentAttempts.length > 5) {
      securityLogger.error({
        type: 'brute_force_detected',
        key,
        attempts: recentAttempts.length,
      });
      // Trigger incident response
    }
  }
}
```

### A10:2021 - Server-Side Request Forgery (SSRF)

**Mitigation**:

```typescript
// SSRF prevention
import { parse } from 'url';
import { isIP } from 'net';

class SSRFProtection {
  private static readonly BLOCKED_NETWORKS = [
    '127.0.0.0/8',    // Loopback
    '10.0.0.0/8',     // Private network
    '172.16.0.0/12',  // Private network
    '192.168.0.0/16', // Private network
    '169.254.0.0/16', // Link-local
    '::1/128',        // IPv6 loopback
    'fc00::/7',       // IPv6 private
  ];

  static isAllowedURL(urlString: string): boolean {
    try {
      const url = parse(urlString);

      // Only allow HTTP(S)
      if (!url.protocol || !['http:', 'https:'].includes(url.protocol)) {
        return false;
      }

      // Check hostname
      if (!url.hostname) {
        return false;
      }

      // Block localhost variations
      if (['localhost', '0.0.0.0'].includes(url.hostname)) {
        return false;
      }

      // Block IP addresses in private ranges
      if (isIP(url.hostname)) {
        return !this.isPrivateIP(url.hostname);
      }

      return true;
    } catch {
      return false;
    }
  }

  private static isPrivateIP(ip: string): boolean {
    // Simplified check - use proper CIDR checking in production
    return ip.startsWith('127.') ||
           ip.startsWith('10.') ||
           ip.startsWith('192.168.') ||
           ip === '::1';
  }
}

// Usage in HTTP client
async function fetchURL(url: string): Promise<Response> {
  if (!SSRFProtection.isAllowedURL(url)) {
    throw new Error('URL not allowed');
  }
  return fetch(url);
}
```

## Input Validation and Sanitization

### TypeScript Input Validation

```typescript
import { z } from 'zod';

// Define schemas for all inputs
const UserSchema = z.object({
  email: z.string().email().max(255),
  username: z.string().min(3).max(50).regex(/^[a-zA-Z0-9_-]+$/),
  age: z.number().int().positive().max(150),
  website: z.string().url().optional(),
});

type User = z.infer<typeof UserSchema>;

// Validate all user input
function createUser(input: unknown): User {
  // Throws if validation fails
  return UserSchema.parse(input);
}

// File upload validation
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_FILE_TYPES = ['image/jpeg', 'image/png', 'image/gif'];

function validateFileUpload(file: File): void {
  if (file.size > MAX_FILE_SIZE) {
    throw new Error('File too large');
  }

  if (!ALLOWED_FILE_TYPES.includes(file.type)) {
    throw new Error('Invalid file type');
  }

  // Validate file extension separately (don't trust MIME type alone)
  const extension = file.name.split('.').pop()?.toLowerCase();
  if (!['jpg', 'jpeg', 'png', 'gif'].includes(extension || '')) {
    throw new Error('Invalid file extension');
  }
}

// SQL Injection prevention with parameterized queries
import { Pool } from 'pg';

const pool = new Pool();

async function getUserById(userId: string): Promise<unknown> {
  // NEVER concatenate user input into SQL
  // const query = `SELECT * FROM users WHERE id = '${userId}'`; // VULNERABLE!

  // Use parameterized queries
  const query = 'SELECT * FROM users WHERE id = $1';
  const result = await pool.query(query, [userId]);
  return result.rows[0];
}

// HTML sanitization
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHTML(html: string): string {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
  });
}

// Path traversal prevention
import path from 'path';

function safeFilePath(userInput: string, baseDir: string): string {
  const normalizedPath = path.normalize(userInput);
  const fullPath = path.join(baseDir, normalizedPath);

  // Ensure the resolved path is within baseDir
  if (!fullPath.startsWith(path.resolve(baseDir))) {
    throw new Error('Path traversal detected');
  }

  return fullPath;
}
```

### Rust Input Validation

```rust
use validator::{Validate, ValidationError};
use regex::Regex;

#[derive(Debug, Validate)]
pub struct User {
    #[validate(email)]
    pub email: String,

    #[validate(length(min = 3, max = 50), regex = "USERNAME_REGEX")]
    pub username: String,

    #[validate(range(min = 1, max = 150))]
    pub age: u8,

    #[validate(url)]
    pub website: Option<String>,
}

lazy_static::lazy_static! {
    static ref USERNAME_REGEX: Regex = Regex::new(r"^[a-zA-Z0-9_-]+$").unwrap();
}

// SQL injection prevention with sqlx
use sqlx::{PgPool, query_as};

#[derive(sqlx::FromRow)]
struct DbUser {
    id: i32,
    username: String,
}

async fn get_user_by_id(pool: &PgPool, user_id: i32) -> Result<Option<DbUser>, sqlx::Error> {
    // Parameterized query - sqlx prevents SQL injection
    query_as::<_, DbUser>("SELECT id, username FROM users WHERE id = $1")
        .bind(user_id)
        .fetch_optional(pool)
        .await
}

// Path traversal prevention
use std::path::{Path, PathBuf};

pub fn safe_file_path(user_input: &str, base_dir: &Path) -> Result<PathBuf, std::io::Error> {
    let normalized = Path::new(user_input);
    let full_path = base_dir.join(normalized);

    // Canonicalize and check it's within base_dir
    let canonical = full_path.canonicalize()?;
    let base_canonical = base_dir.canonicalize()?;

    if !canonical.starts_with(base_canonical) {
        return Err(std::io::Error::new(
            std::io::ErrorKind::PermissionDenied,
            "Path traversal detected"
        ));
    }

    Ok(canonical)
}
```

### Python Input Validation

```python
from pydantic import BaseModel, EmailStr, Field, HttpUrl, validator
from typing import Optional
import re

class User(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=50)
    age: int = Field(gt=0, le=150)
    website: Optional[HttpUrl] = None

    @validator('username')
    def username_alphanumeric(cls, v):
        if not re.match(r'^[a-zA-Z0-9_-]+$', v):
            raise ValueError('Username must be alphanumeric with - and _')
        return v

# SQL injection prevention with parameterized queries
import psycopg2

def get_user_by_id(conn, user_id: int):
    """Safely retrieve user by ID using parameterized query."""
    with conn.cursor() as cursor:
        # NEVER use string formatting for SQL queries!
        # query = f"SELECT * FROM users WHERE id = '{user_id}'"  # VULNERABLE!

        # Use parameterized queries
        cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
        return cursor.fetchone()

# HTML sanitization
import bleach

ALLOWED_TAGS = ['b', 'i', 'em', 'strong', 'a', 'p', 'br']
ALLOWED_ATTRIBUTES = {'a': ['href']}

def sanitize_html(html: str) -> str:
    """Sanitize HTML to prevent XSS attacks."""
    return bleach.clean(
        html,
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        strip=True
    )

# Path traversal prevention
from pathlib import Path

def safe_file_path(user_input: str, base_dir: Path) -> Path:
    """Safely resolve file path preventing traversal attacks."""
    requested_path = (base_dir / user_input).resolve()
    base_dir_resolved = base_dir.resolve()

    # Check if the resolved path is within base_dir
    if not requested_path.is_relative_to(base_dir_resolved):
        raise ValueError("Path traversal detected")

    return requested_path

# Command injection prevention
import shlex
import subprocess

def safe_command_execution(user_input: str) -> str:
    """Safely execute command with user input."""
    # NEVER use shell=True with user input!
    # subprocess.run(f"echo {user_input}", shell=True)  # VULNERABLE!

    # Use argument list without shell
    result = subprocess.run(
        ['echo', user_input],  # Arguments as list
        shell=False,  # Don't use shell
        capture_output=True,
        text=True,
        timeout=5
    )
    return result.stdout
```

## Authentication and Authorization

### Multi-Factor Authentication (MFA)

```typescript
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';

class MFAService {
  static generateSecret(userEmail: string): { secret: string; qrCode: string } {
    const secret = speakeasy.generateSecret({
      name: `MyApp (${userEmail})`,
      length: 32,
    });

    return {
      secret: secret.base32,
      qrCode: secret.otpauth_url || '',
    };
  }

  static async generateQRCode(otpauthUrl: string): Promise<string> {
    return QRCode.toDataURL(otpauthUrl);
  }

  static verifyToken(secret: string, token: string): boolean {
    return speakeasy.totp.verify({
      secret,
      encoding: 'base32',
      token,
      window: 2, // Allow 2 time steps before/after
    });
  }
}

// Usage in authentication flow
interface AuthRequest {
  email: string;
  password: string;
  mfaToken?: string;
}

async function authenticate(req: AuthRequest): Promise<{ token: string }> {
  // 1. Verify password
  const user = await findUserByEmail(req.email);
  if (!user || !(await PasswordHasher.verify(user.passwordHash, req.password))) {
    throw new Error('Invalid credentials');
  }

  // 2. Check if MFA is enabled
  if (user.mfaSecret) {
    if (!req.mfaToken) {
      throw new Error('MFA token required');
    }

    if (!MFAService.verifyToken(user.mfaSecret, req.mfaToken)) {
      throw new Error('Invalid MFA token');
    }
  }

  // 3. Generate session token
  return { token: generateJWT(user) };
}
```

### JWT Best Practices

```typescript
import jwt from 'jsonwebtoken';

interface TokenPayload {
  userId: string;
  email: string;
  roles: string[];
}

class JWTService {
  private static readonly ACCESS_TOKEN_EXPIRY = '15m';
  private static readonly REFRESH_TOKEN_EXPIRY = '7d';
  private static readonly ALGORITHM = 'RS256'; // Use asymmetric encryption

  static generateAccessToken(payload: TokenPayload, privateKey: string): string {
    return jwt.sign(payload, privateKey, {
      algorithm: this.ALGORITHM,
      expiresIn: this.ACCESS_TOKEN_EXPIRY,
      issuer: 'myapp.com',
      audience: 'myapp-api',
    });
  }

  static generateRefreshToken(userId: string, privateKey: string): string {
    return jwt.sign({ userId, type: 'refresh' }, privateKey, {
      algorithm: this.ALGORITHM,
      expiresIn: this.REFRESH_TOKEN_EXPIRY,
      issuer: 'myapp.com',
    });
  }

  static verifyAccessToken(token: string, publicKey: string): TokenPayload {
    try {
      const payload = jwt.verify(token, publicKey, {
        algorithms: [this.ALGORITHM],
        issuer: 'myapp.com',
        audience: 'myapp-api',
      }) as TokenPayload;

      return payload;
    } catch (error) {
      throw new Error('Invalid token');
    }
  }
}

// Rate limiting for authentication endpoints
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply to login route
// app.post('/auth/login', authLimiter, loginHandler);
```

## Cryptography and Secrets Management

### Secrets Management

```typescript
// Never hardcode secrets!
// ❌ BAD
const API_KEY = 'sk-1234567890abcdef';

// ✅ GOOD - Use environment variables
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY must be set');
}

// .env file (never commit to git!)
// API_KEY=sk-1234567890abcdef
// DATABASE_URL=postgresql://user:pass@localhost/db

// Use a secrets manager for production
class SecretsManager {
  private cache = new Map<string, string>();
  private cacheExpiry = 5 * 60 * 1000; // 5 minutes

  async getSecret(name: string): Promise<string> {
    // Check cache
    const cached = this.cache.get(name);
    if (cached) return cached;

    // Fetch from secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.)
    const secret = await this.fetchFromVault(name);
    this.cache.set(name, secret);

    // Clear cache after expiry
    setTimeout(() => this.cache.delete(name), this.cacheExpiry);

    return secret;
  }

  private async fetchFromVault(name: string): Promise<string> {
    // Implementation depends on your secrets manager
    // AWS Secrets Manager example:
    // const client = new SecretsManagerClient({});
    // const response = await client.send(new GetSecretValueCommand({ SecretId: name }));
    // return response.SecretString || '';
    throw new Error('Not implemented');
  }
}
```

### Key Rotation

```typescript
interface EncryptionKey {
  id: string;
  key: Buffer;
  createdAt: Date;
  expiresAt: Date;
}

class KeyRotationManager {
  private keys: Map<string, EncryptionKey> = new Map();
  private currentKeyId: string;

  constructor(initialKey: EncryptionKey) {
    this.keys.set(initialKey.id, initialKey);
    this.currentKeyId = initialKey.id;
  }

  getCurrentKey(): EncryptionKey {
    const key = this.keys.get(this.currentKeyId);
    if (!key) throw new Error('No current key available');
    return key;
  }

  getKey(keyId: string): EncryptionKey | undefined {
    return this.keys.get(keyId);
  }

  async rotateKey(): Promise<void> {
    const newKey: EncryptionKey = {
      id: this.generateKeyId(),
      key: await this.generateKey(),
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), // 90 days
    };

    this.keys.set(newKey.id, newKey);
    this.currentKeyId = newKey.id;

    // Remove expired keys
    for (const [id, key] of this.keys) {
      if (key.expiresAt < new Date()) {
        this.keys.delete(id);
      }
    }
  }

  private generateKeyId(): string {
    return `key-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  private async generateKey(): Promise<Buffer> {
    const { randomBytes } = await import('crypto');
    return randomBytes(32);
  }
}

// Encrypt with key ID
function encryptWithKeyId(plaintext: string, keyManager: KeyRotationManager): string {
  const key = keyManager.getCurrentKey();
  const encrypted = encrypt(plaintext, key.key);
  return `${key.id}:${encrypted}`;
}

// Decrypt with correct key
function decryptWithKeyId(ciphertext: string, keyManager: KeyRotationManager): string {
  const [keyId, encrypted] = ciphertext.split(':');
  const key = keyManager.getKey(keyId);
  if (!key) throw new Error('Key not found');
  return decrypt(encrypted, key.key);
}
```

## Dependency Security

### Automated Dependency Scanning

```bash
# package.json scripts
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix",
    "audit:ci": "npm audit --audit-level=moderate"
  }
}
```

```yaml
# GitHub Actions - Dependency scanning
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0' # Weekly

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run npm audit
        run: npm audit --audit-level=moderate

      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          path: '.'
          format: 'HTML'

  rust-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - uses: actions-rs/audit-check@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Dependency Pinning

```json
// package.json - Pin exact versions
{
  "dependencies": {
    "express": "4.18.2",  // ✅ Exact version
    "lodash": "~4.17.21", // ✅ Patch updates only
    "react": "^18.2.0"    // ⚠️ Minor updates allowed
  }
}
```

```toml
# Cargo.toml - Pin versions
[dependencies]
serde = "=1.0.152"  # Exact version
tokio = "~1.25"     # Patch updates only
```

### Supply Chain Security

```yaml
# GitHub Actions - Verify dependencies
- name: Verify package integrity
  run: |
    npm ci  # Uses package-lock.json for reproducible builds
    npm audit signatures  # Verify package signatures
```

## Code Injection Prevention

### Command Injection

```python
# ❌ NEVER DO THIS
import os
user_input = request.args.get('filename')
os.system(f'cat {user_input}')  # VULNERABLE!

# ✅ DO THIS
import subprocess
result = subprocess.run(
    ['cat', user_input],  # List of arguments
    shell=False,  # Never use shell with user input
    capture_output=True,
    timeout=5,
    check=True
)
```

### NoSQL Injection

```typescript
// MongoDB - Prevent NoSQL injection
import { ObjectId } from 'mongodb';

// ❌ VULNERABLE
async function getUser(userId: string) {
  return db.collection('users').findOne({ _id: userId });
}

// ✅ SAFE - Validate and sanitize
async function getUserSafe(userId: string) {
  // Validate ObjectId format
  if (!ObjectId.isValid(userId)) {
    throw new Error('Invalid user ID');
  }

  return db.collection('users').findOne({ _id: new ObjectId(userId) });
}

// ❌ VULNERABLE - Object injection
async function findUsers(query: any) {
  return db.collection('users').find(query).toArray();
}

// ✅ SAFE - Validate query structure
const QuerySchema = z.object({
  email: z.string().email().optional(),
  role: z.enum(['admin', 'user', 'guest']).optional(),
});

async function findUsersSafe(query: unknown) {
  const validatedQuery = QuerySchema.parse(query);
  return db.collection('users').find(validatedQuery).toArray();
}
```

### Template Injection

```typescript
// Server-Side Template Injection (SSTI) prevention
import Handlebars from 'handlebars';

// ❌ VULNERABLE
const template = Handlebars.compile(userInput);

// ✅ SAFE - Use predefined templates only
const ALLOWED_TEMPLATES = {
  welcome: Handlebars.compile('Welcome, {{name}}!'),
  farewell: Handlebars.compile('Goodbye, {{name}}!'),
};

function renderTemplate(templateName: string, data: { name: string }): string {
  const template = ALLOWED_TEMPLATES[templateName as keyof typeof ALLOWED_TEMPLATES];
  if (!template) {
    throw new Error('Invalid template');
  }

  // Escape data
  return template({ name: Handlebars.escapeExpression(data.name) });
}
```

## Security Testing

### Static Application Security Testing (SAST)

```yaml
# .github/workflows/sast.yml
name: SAST

on: [push, pull_request]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
            p/typescript
            p/rust

  codeql:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@v3
      - uses: github/codeql-action/init@v2
        with:
          languages: typescript, python
      - uses: github/codeql-action/autobuild@v2
      - uses: github/codeql-action/analyze@v2

  eslint-security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run lint:security
```

```json
// .eslintrc.json - Security rules
{
  "plugins": ["security"],
  "extends": ["plugin:security/recommended"],
  "rules": {
    "security/detect-object-injection": "error",
    "security/detect-non-literal-regexp": "error",
    "security/detect-unsafe-regex": "error",
    "security/detect-buffer-noassert": "error",
    "security/detect-eval-with-expression": "error",
    "security/detect-no-csrf-before-method-override": "error",
    "security/detect-possible-timing-attacks": "error"
  }
}
```

### Dynamic Application Security Testing (DAST)

```yaml
# .github/workflows/dast.yml
name: DAST

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  zap-scan:
    runs-on: ubuntu-latest
    steps:
      - name: ZAP Scan
        uses: zaproxy/action-full-scan@v0.4.0
        with:
          target: 'https://staging.myapp.com'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
```

### Dependency Scanning

See [Dependency Security](#dependency-security) section.

### Penetration Testing Checklist

- [ ] SQL Injection testing
- [ ] XSS testing (reflected, stored, DOM-based)
- [ ] CSRF testing
- [ ] Authentication bypass attempts
- [ ] Authorization testing
- [ ] Session management testing
- [ ] File upload vulnerabilities
- [ ] API security testing
- [ ] Rate limiting effectiveness
- [ ] SSL/TLS configuration
- [ ] Security headers validation
- [ ] CORS policy testing

## Security Headers and HTTPS

### HTTP Security Headers

```typescript
// Express.js security headers
import helmet from 'helmet';
import express from 'express';

const app = express();

// Use Helmet for security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true,
  },
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin',
  },
  noSniff: true,
  xssFilter: true,
  frameguard: {
    action: 'deny',
  },
}));

// Additional security headers
app.use((req, res, next) => {
  res.setHeader('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});
```

### HTTPS Configuration

```typescript
// Node.js HTTPS server
import https from 'https';
import fs from 'fs';

const options = {
  key: fs.readFileSync('private-key.pem'),
  cert: fs.readFileSync('certificate.pem'),

  // Strong cipher suites
  ciphers: [
    'TLS_AES_128_GCM_SHA256',
    'TLS_AES_256_GCM_SHA384',
    'TLS_CHACHA20_POLY1305_SHA256',
    'ECDHE-RSA-AES128-GCM-SHA256',
    'ECDHE-RSA-AES256-GCM-SHA384',
  ].join(':'),

  // Modern TLS only
  minVersion: 'TLSv1.2',
  maxVersion: 'TLSv1.3',

  // Prefer server cipher order
  honorCipherOrder: true,
};

https.createServer(options, app).listen(443);
```

### CORS Configuration

```typescript
import cors from 'cors';

// Restrictive CORS configuration
app.use(cors({
  origin: (origin, callback) => {
    const allowedOrigins = [
      'https://myapp.com',
      'https://www.myapp.com',
    ];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  maxAge: 86400, // 24 hours
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

## Language-Specific Security

### Rust Unsafe Code

```rust
// ❌ Avoid unsafe when possible
unsafe {
    let ptr = some_pointer;
    *ptr = value;
}

// ✅ Use safe alternatives
use std::sync::Arc;
use std::sync::Mutex;

// Safe shared mutable state
let data = Arc::new(Mutex::new(vec![1, 2, 3]));

// If unsafe is necessary, minimize scope and document
/// # Safety
/// This function is safe to call only when:
/// - `ptr` is a valid, non-null pointer
/// - `ptr` points to properly initialized memory
/// - No other references to this memory exist
unsafe fn write_raw(ptr: *mut i32, value: i32) {
    // SAFETY: Caller guarantees ptr is valid
    *ptr = value;
}

// Wrap unsafe in safe abstractions
pub struct SafeBuffer {
    ptr: *mut u8,
    len: usize,
}

impl SafeBuffer {
    pub fn new(size: usize) -> Self {
        let layout = std::alloc::Layout::array::<u8>(size).unwrap();
        let ptr = unsafe { std::alloc::alloc(layout) };
        Self { ptr, len: size }
    }

    pub fn write(&mut self, index: usize, value: u8) -> Result<(), &'static str> {
        if index >= self.len {
            return Err("Index out of bounds");
        }
        unsafe {
            // SAFETY: Index checked above
            *self.ptr.add(index) = value;
        }
        Ok(())
    }
}

impl Drop for SafeBuffer {
    fn drop(&mut self) {
        let layout = std::alloc::Layout::array::<u8>(self.len).unwrap();
        unsafe {
            std::alloc::dealloc(self.ptr, layout);
        }
    }
}
```

### TypeScript Prototype Pollution

```typescript
// ❌ VULNERABLE to prototype pollution
function merge(target: any, source: any): any {
  for (const key in source) {
    target[key] = source[key];  // Can pollute Object.prototype!
  }
  return target;
}

// Malicious input
const malicious = JSON.parse('{"__proto__": {"isAdmin": true}}');
merge({}, malicious);
// Now all objects have isAdmin = true!

// ✅ SAFE - Prevent prototype pollution
function safeMerge(target: Record<string, unknown>, source: unknown): Record<string, unknown> {
  if (typeof source !== 'object' || source === null) {
    return target;
  }

  const safeSource = source as Record<string, unknown>;

  for (const key in safeSource) {
    // Skip prototype chain properties
    if (!Object.prototype.hasOwnProperty.call(safeSource, key)) {
      continue;
    }

    // Blacklist dangerous keys
    if (['__proto__', 'constructor', 'prototype'].includes(key)) {
      continue;
    }

    target[key] = safeSource[key];
  }

  return target;
}

// Or use Object.create(null) for prototype-free objects
function createSafeObject(): Record<string, unknown> {
  return Object.create(null);
}

// Use libraries with prototype pollution protection
import merge from 'lodash/merge';  // Has built-in protection
```

### Python Eval and Exec

```python
# ❌ NEVER use eval() or exec() with user input!
user_input = request.args.get('code')
result = eval(user_input)  # EXTREMELY DANGEROUS!

# ✅ Use safer alternatives
import ast

def safe_eval_math(expression: str) -> float:
    """Safely evaluate mathematical expressions."""
    try:
        # Parse to AST
        tree = ast.parse(expression, mode='eval')

        # Whitelist allowed operations
        allowed_nodes = (
            ast.Expression, ast.BinOp, ast.UnaryOp, ast.Num,
            ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Mod,
            ast.Pow, ast.USub, ast.UAdd
        )

        for node in ast.walk(tree):
            if not isinstance(node, allowed_nodes):
                raise ValueError(f"Forbidden operation: {type(node).__name__}")

        # Evaluate safely
        return eval(compile(tree, '<string>', 'eval'))
    except (SyntaxError, ValueError) as e:
        raise ValueError(f"Invalid expression: {e}")

# For configuration, use safe parsers
import json
import yaml

# ✅ SAFE - Use safe YAML loader
def load_config(config_str: str):
    return yaml.safe_load(config_str)  # Not yaml.load()!

# ✅ SAFE - JSON is inherently safe
def load_json_config(config_str: str):
    return json.loads(config_str)
```

## Security Audit Checklist

### Code Review Security Checklist

- [ ] All user inputs are validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] No hardcoded credentials or secrets
- [ ] Authentication requires strong passwords/MFA
- [ ] Authorization checks on all sensitive operations
- [ ] Cryptography uses modern algorithms (AES-256, RSA-2048+)
- [ ] HTTPS enforced everywhere
- [ ] Security headers properly configured
- [ ] CORS policy is restrictive
- [ ] Rate limiting on authentication endpoints
- [ ] File uploads are validated and scanned
- [ ] Error messages don't leak sensitive information
- [ ] Logging doesn't include sensitive data
- [ ] Dependencies are up to date
- [ ] No use of dangerous functions (eval, exec, etc.)
- [ ] Session management is secure
- [ ] CSRF protection is implemented
- [ ] XSS protection is in place

### Infrastructure Security Checklist

- [ ] Principle of least privilege applied
- [ ] Network segmentation in place
- [ ] Firewalls configured properly
- [ ] Regular security patches applied
- [ ] Backups are encrypted and tested
- [ ] Monitoring and alerting configured
- [ ] Incident response plan exists
- [ ] DDoS protection enabled
- [ ] WAF configured if applicable
- [ ] Database access restricted
- [ ] API rate limiting implemented
- [ ] Security scanning in CI/CD pipeline

## Incident Response

### Incident Response Plan

```typescript
// Incident severity levels
enum IncidentSeverity {
  Critical = 'critical',  // Data breach, system compromise
  High = 'high',          // Service disruption, vulnerability exploitation
  Medium = 'medium',      // Minor security issue
  Low = 'low',           // Security concern, no immediate risk
}

interface SecurityIncident {
  id: string;
  severity: IncidentSeverity;
  description: string;
  detectedAt: Date;
  detectedBy: string;
  affectedSystems: string[];
  status: 'detected' | 'investigating' | 'contained' | 'resolved';
  timeline: IncidentEvent[];
}

interface IncidentEvent {
  timestamp: Date;
  action: string;
  performedBy: string;
  notes: string;
}

class IncidentResponseTeam {
  private incidents: Map<string, SecurityIncident> = new Map();

  reportIncident(incident: Omit<SecurityIncident, 'id' | 'status' | 'timeline'>): string {
    const id = this.generateIncidentId();
    const fullIncident: SecurityIncident = {
      ...incident,
      id,
      status: 'detected',
      timeline: [{
        timestamp: new Date(),
        action: 'Incident reported',
        performedBy: incident.detectedBy,
        notes: incident.description,
      }],
    };

    this.incidents.set(id, fullIncident);
    this.notifyTeam(fullIncident);
    this.executeRunbook(fullIncident);

    return id;
  }

  private async executeRunbook(incident: SecurityIncident): Promise<void> {
    switch (incident.severity) {
      case IncidentSeverity.Critical:
        await this.criticalIncidentRunbook(incident);
        break;
      case IncidentSeverity.High:
        await this.highSeverityRunbook(incident);
        break;
      default:
        await this.standardRunbook(incident);
    }
  }

  private async criticalIncidentRunbook(incident: SecurityIncident): Promise<void> {
    // 1. Immediate containment
    await this.containThreat(incident);

    // 2. Notify stakeholders
    await this.notifyStakeholders(incident);

    // 3. Preserve evidence
    await this.preserveEvidence(incident);

    // 4. Begin investigation
    await this.investigateIncident(incident);

    // 5. Communicate with users if needed
    if (this.requiresUserNotification(incident)) {
      await this.notifyUsers(incident);
    }
  }

  private async containThreat(incident: SecurityIncident): Promise<void> {
    console.log(`Containing threat: ${incident.id}`);
    // Implementation:
    // - Isolate affected systems
    // - Revoke compromised credentials
    // - Block malicious IPs
    // - Disable compromised accounts
  }

  private async preserveEvidence(incident: SecurityIncident): Promise<void> {
    console.log(`Preserving evidence for: ${incident.id}`);
    // Implementation:
    // - Capture system snapshots
    // - Preserve logs
    // - Document findings
    // - Chain of custody
  }

  private requiresUserNotification(incident: SecurityIncident): boolean {
    // Data breach notification laws (GDPR, CCPA, etc.)
    return incident.severity === IncidentSeverity.Critical &&
           incident.affectedSystems.some(s => s.includes('user-data'));
  }

  private generateIncidentId(): string {
    return `INC-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  private notifyTeam(incident: SecurityIncident): void {
    // Send alerts to security team
    console.log(`SECURITY INCIDENT: ${incident.severity} - ${incident.description}`);
  }

  private async notifyStakeholders(incident: SecurityIncident): Promise<void> {
    // Notify management, legal, PR teams as needed
  }

  private async investigateIncident(incident: SecurityIncident): Promise<void> {
    // Forensic investigation
  }

  private async notifyUsers(incident: SecurityIncident): Promise<void> {
    // User breach notification
  }

  private async highSeverityRunbook(incident: SecurityIncident): Promise<void> {
    // High severity incident handling
  }

  private async standardRunbook(incident: SecurityIncident): Promise<void> {
    // Standard incident handling
  }
}
```

### Security Monitoring

```typescript
// Real-time security monitoring
class SecurityMonitor {
  private alerts: SecurityAlert[] = [];

  monitorAuthentication(): void {
    // Track failed login attempts
    // Detect brute force attacks
    // Monitor for credential stuffing
  }

  monitorDataAccess(): void {
    // Track data exports
    // Detect unusual access patterns
    // Monitor for data exfiltration
  }

  monitorSystemActivity(): void {
    // Track privilege escalation attempts
    // Monitor file system changes
    // Detect malware signatures
  }

  private generateAlert(alert: SecurityAlert): void {
    this.alerts.push(alert);

    if (alert.severity === 'critical') {
      this.triggerIncidentResponse(alert);
    }
  }

  private triggerIncidentResponse(alert: SecurityAlert): void {
    const irt = new IncidentResponseTeam();
    irt.reportIncident({
      severity: IncidentSeverity.Critical,
      description: alert.message,
      detectedAt: new Date(),
      detectedBy: 'Security Monitor',
      affectedSystems: alert.affectedSystems,
    });
  }
}

interface SecurityAlert {
  severity: 'low' | 'medium' | 'high' | 'critical';
  message: string;
  affectedSystems: string[];
  timestamp: Date;
}
```

### Post-Incident Review

After resolving an incident:

1. **Document everything**: Timeline, actions taken, root cause
2. **Conduct blameless postmortem**: Focus on system improvements
3. **Update runbooks**: Incorporate lessons learned
4. **Implement preventive measures**: Fix root causes
5. **Test improvements**: Verify fixes work
6. **Train team**: Share knowledge gained
7. **Update documentation**: Security policies, procedures

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [SANS Security Resources](https://www.sans.org/security-resources/)

## License

This guide is dual-licensed under MIT OR Apache-2.0, same as the RSR template.
