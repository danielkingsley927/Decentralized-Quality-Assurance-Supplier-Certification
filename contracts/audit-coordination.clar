;; Certification Management Contract
;; Manages supplier certifications

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u300))
(define-constant err-not-found (err u301))
(define-constant err-already-exists (err u302))
(define-constant err-unauthorized (err u303))
(define-constant err-insufficient-score (err u304))
(define-constant err-expired (err u305))

;; Certification levels
(define-constant cert-bronze u1)
(define-constant cert-silver u2)
(define-constant cert-gold u3)
(define-constant cert-platinum u4)

;; Data structures
(define-map certifications
  { cert-id: uint }
  {
    supplier-id: uint,
    certification-level: uint,
    issued-by: principal,
    qa-department-id: uint,
    issued-at: uint,
    expires-at: uint,
    active: bool,
    requirements-met: (list 10 (string-ascii 100))
  }
)

(define-map certification-requirements
  { level: uint }
  {
    min-score: uint,
    validity-period: uint,
    required-audits: uint
  }
)

(define-data-var next-cert-id uint u1)

;; Initialize certification requirements
(define-private (init-requirements)
  (begin
    (map-set certification-requirements { level: cert-bronze } { min-score: u60, validity-period: u52560, required-audits: u1 })
    (map-set certification-requirements { level: cert-silver } { min-score: u70, validity-period: u52560, required-audits: u2 })
    (map-set certification-requirements { level: cert-gold } { min-score: u80, validity-period: u26280, required-audits: u3 })
    (map-set certification-requirements { level: cert-platinum } { min-score: u90, validity-period: u26280, required-audits: u4 })
  )
)

;; Issue certification
(define-public (issue-certification
  (supplier-id uint)
  (certification-level uint)
  (qa-department-id uint)
  (supplier-score uint)
  (requirements-met (list 10 (string-ascii 100)))
)
  (let (
    (cert-id (var-get next-cert-id))
    (requirements (unwrap! (map-get? certification-requirements { level: certification-level }) err-not-found))
    (validity-period (get validity-period requirements))
  )
    (asserts! (>= supplier-score (get min-score requirements)) err-insufficient-score)

    (map-set certifications
      { cert-id: cert-id }
      {
        supplier-id: supplier-id,
        certification-level: certification-level,
        issued-by: tx-sender,
        qa-department-id: qa-department-id,
        issued-at: block-height,
        expires-at: (+ block-height validity-period),
        active: true,
        requirements-met: requirements-met
      }
    )

    (var-set next-cert-id (+ cert-id u1))
    (ok cert-id)
  )
)

;; Revoke certification
(define-public (revoke-certification (cert-id uint))
  (let ((cert (unwrap! (map-get? certifications { cert-id: cert-id }) err-not-found)))
    (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get issued-by cert))) err-unauthorized)

    (map-set certifications
      { cert-id: cert-id }
      (merge cert { active: false })
    )
    (ok true)
  )
)

;; Renew certification
(define-public (renew-certification (cert-id uint) (new-score uint))
  (let (
    (cert (unwrap! (map-get? certifications { cert-id: cert-id }) err-not-found))
    (requirements (unwrap! (map-get? certification-requirements { level: (get certification-level cert) }) err-not-found))
    (validity-period (get validity-period requirements))
  )
    (asserts! (>= new-score (get min-score requirements)) err-insufficient-score)
    (asserts! (is-eq tx-sender (get issued-by cert)) err-unauthorized)

    (map-set certifications
      { cert-id: cert-id }
      (merge cert {
        issued-at: block-height,
        expires-at: (+ block-height validity-period),
        active: true
      })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-certification (cert-id uint))
  (map-get? certifications { cert-id: cert-id })
)

(define-read-only (is-certification-valid (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert (and (get active cert) (> (get expires-at cert) block-height))
    false
  )
)

(define-read-only (get-certification-requirements (level uint))
  (map-get? certification-requirements { level: level })
)

;; Initialize on deployment
(init-requirements)
