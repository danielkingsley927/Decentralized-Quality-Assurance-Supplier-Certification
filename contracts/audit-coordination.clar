;; Audit Coordination Contract
;; Coordinates supplier quality audits

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-found (err u401))
(define-constant err-already-exists (err u402))
(define-constant err-unauthorized (err u403))
(define-constant err-invalid-status (err u404))

;; Audit statuses
(define-constant status-scheduled u1)
(define-constant status-in-progress u2)
(define-constant status-completed u3)
(define-constant status-cancelled u4)

;; Data structures
(define-map audits
  { audit-id: uint }
  {
    supplier-id: uint,
    auditor: principal,
    qa-department-id: uint,
    audit-type: (string-ascii 50),
    scheduled-date: uint,
    completion-date: (optional uint),
    status: uint,
    findings: (list 20 (string-ascii 200)),
    recommendations: (list 10 (string-ascii 200)),
    compliance-rating: (optional uint)
  }
)

(define-map audit-schedule
  { supplier-id: uint, date: uint }
  { audit-id: uint, auditor: principal }
)

(define-data-var next-audit-id uint u1)

;; Schedule an audit
(define-public (schedule-audit
  (supplier-id uint)
  (auditor principal)
  (qa-department-id uint)
  (audit-type (string-ascii 50))
  (scheduled-date uint)
)
  (let ((audit-id (var-get next-audit-id)))
    (asserts! (is-none (map-get? audit-schedule { supplier-id: supplier-id, date: scheduled-date })) err-already-exists)

    (map-set audits
      { audit-id: audit-id }
      {
        supplier-id: supplier-id,
        auditor: auditor,
        qa-department-id: qa-department-id,
        audit-type: audit-type,
        scheduled-date: scheduled-date,
        completion-date: none,
        status: status-scheduled,
        findings: (list),
        recommendations: (list),
        compliance-rating: none
      }
    )

    (map-set audit-schedule
      { supplier-id: supplier-id, date: scheduled-date }
      { audit-id: audit-id, auditor: auditor }
    )

    (var-set next-audit-id (+ audit-id u1))
    (ok audit-id)
  )
)

;; Start audit
(define-public (start-audit (audit-id uint))
  (let ((audit (unwrap! (map-get? audits { audit-id: audit-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get auditor audit)) err-unauthorized)
    (asserts! (is-eq (get status audit) status-scheduled) err-invalid-status)

    (map-set audits
      { audit-id: audit-id }
      (merge audit { status: status-in-progress })
    )
    (ok true)
  )
)

;; Complete audit
(define-public (complete-audit
  (audit-id uint)
  (findings (list 20 (string-ascii 200)))
  (recommendations (list 10 (string-ascii 200)))
  (compliance-rating uint)
)
  (let ((audit (unwrap! (map-get? audits { audit-id: audit-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get auditor audit)) err-unauthorized)
    (asserts! (is-eq (get status audit) status-in-progress) err-invalid-status)

    (map-set audits
      { audit-id: audit-id }
      (merge audit {
        status: status-completed,
        completion-date: (some block-height),
        findings: findings,
        recommendations: recommendations,
        compliance-rating: (some compliance-rating)
      })
    )
    (ok true)
  )
)

;; Cancel audit
(define-public (cancel-audit (audit-id uint))
  (let ((audit (unwrap! (map-get? audits { audit-id: audit-id }) err-not-found)))
    (asserts! (or (is-eq tx-sender (get auditor audit)) (is-eq tx-sender contract-owner)) err-unauthorized)

    (map-set audits
      { audit-id: audit-id }
      (merge audit { status: status-cancelled })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-audit (audit-id uint))
  (map-get? audits { audit-id: audit-id })
)

(define-read-only (get-scheduled-audit (supplier-id uint) (date uint))
  (map-get? audit-schedule { supplier-id: supplier-id, date: date })
)

(define-read-only (is-audit-completed (audit-id uint))
  (match (map-get? audits { audit-id: audit-id })
    audit (is-eq (get status audit) status-completed)
    false
  )
)
