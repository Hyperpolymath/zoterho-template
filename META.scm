;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;;; META.scm — zoterho-template

(define-module (zoterho-template meta)
  #:export (architecture-decisions development-practices design-rationale))

(define architecture-decisions
  '((adr-001
     (title . "RSR Compliance")
     (status . "accepted")
     (date . "2025-12-15")
     (context . "Project in the hyperpolymath ecosystem")
     (decision . "Follow Rhodium Standard Repository guidelines")
     (consequences . ("RSR Gold target" "SHA-pinned actions" "SPDX headers" "Multi-platform CI")))))

(define development-practices
  '((code-style (languages . ("unknown")) (formatter . "auto-detect") (linter . "auto-detect"))
    (security (sast . "CodeQL") (credentials . "env vars only"))
    (testing (coverage-minimum . 70))
    (versioning (scheme . "SemVer 2.0.0"))))

(define design-rationale
  '((why-rsr "RSR ensures consistency, security, and maintainability.")))
;; ============================================================================
;; CROSS-PLATFORM STATUS (Added 2025-12-17)
;; ============================================================================

(cross-platform-status
  (generated "2025-12-17")
  (primary-platform "github")
  (gitlab-mirror
    (path "hyperpolymath/extensions/zotero/zoterho-template")
    (url "https://gitlab.com/hyperpolymath/extensions/zotero/zoterho-template")
    (last-gitlab-activity "2025-12-11")
    (sync-status "gh-primary")
    (notes "GitHub newer. Safe to sync GH→GL."))
  
  (reconciliation-instructions
    ";; git remote add gitlab https://gitlab.com/hyperpolymath/extensions/zotero/zoterho-template.git"
    ";; git fetch gitlab && git log gitlab/main --oneline"
    ";; git diff main gitlab/main"
    ";; git merge gitlab/main --allow-unrelated-histories  # if needed")
  
  (action-required "gh-primary"))

