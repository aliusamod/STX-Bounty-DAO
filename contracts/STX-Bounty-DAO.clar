;; Bounty DAO Smart Contract
;; A simple contract for managing bounties and releasing funds to solvers

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-BOUNTY-NOT-FOUND (err u404))
(define-constant ERR-INSUFFICIENT-FUNDS (err u400))
(define-constant ERR-BOUNTY-EXPIRED (err u403))
(define-constant ERR-BOUNTY-ALREADY-SOLVED (err u409))
(define-constant ERR-INVALID-SOLUTION (err u422))

;; Data Variables
(define-data-var next-bounty-id uint u1)

;; Data Maps
(define-map bounties
  { bounty-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    reward: uint,
    expiry-block: uint,
    solved: bool,
    solver: (optional principal)
  }
)

(define-map solutions
  { bounty-id: uint, solver: principal }
  {
    solution: (string-ascii 1000),
    submitted-at: uint
  }
)

;; Private Functions
(define-private (is-bounty-creator (bounty-id uint) (user principal))
  (match (map-get? bounties { bounty-id: bounty-id })
    bounty (is-eq (get creator bounty) user)
    false
  )
)

;; Public Functions

;; Create a new bounty
(define-public (create-bounty (title (string-ascii 100)) (description (string-ascii 500)) (expiry-blocks uint))
  (let
    (
      (bounty-id (var-get next-bounty-id))
      (reward-amount (stx-get-balance tx-sender))
    )
    (asserts! (> reward-amount u0) ERR-INSUFFICIENT-FUNDS)
    (try! (stx-transfer? reward-amount tx-sender (as-contract tx-sender)))
    (map-set bounties
      { bounty-id: bounty-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        reward: reward-amount,
        expiry-block: (+ block-height expiry-blocks),
        solved: false,
        solver: none
      }
    )
    (var-set next-bounty-id (+ bounty-id u1))
    (ok bounty-id)
  )
)

;; Submit a solution to a bounty
(define-public (submit-solution (bounty-id uint) (solution (string-ascii 1000)))
  (let
    (
      (bounty-data (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (< block-height (get expiry-block bounty-data)) ERR-BOUNTY-EXPIRED)
    (asserts! (not (get solved bounty-data)) ERR-BOUNTY-ALREADY-SOLVED)
    (map-set solutions
      { bounty-id: bounty-id, solver: tx-sender }
      {
        solution: solution,
        submitted-at: block-height
      }
    )
    (ok true)
  )
)

;; Approve solution and release funds
(define-public (approve-solution (bounty-id uint) (solver principal))
  (let
    (
      (bounty-data (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERR-BOUNTY-NOT-FOUND))
      (solution-data (unwrap! (map-get? solutions { bounty-id: bounty-id, solver: solver }) ERR-INVALID-SOLUTION))
    )
    (asserts! (is-bounty-creator bounty-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (not (get solved bounty-data)) ERR-BOUNTY-ALREADY-SOLVED)
    (try! (as-contract (stx-transfer? (get reward bounty-data) tx-sender solver)))
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty-data { solved: true, solver: (some solver) })
    )
    (ok true)
  )
)

;; Withdraw expired bounty funds
(define-public (withdraw-expired-bounty (bounty-id uint))
  (let
    (
      (bounty-data (unwrap! (map-get? bounties { bounty-id: bounty-id }) ERR-BOUNTY-NOT-FOUND))
    )
    (asserts! (is-bounty-creator bounty-id tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (>= block-height (get expiry-block bounty-data)) ERR-BOUNTY-EXPIRED)
    (asserts! (not (get solved bounty-data)) ERR-BOUNTY-ALREADY-SOLVED)
    (try! (as-contract (stx-transfer? (get reward bounty-data) tx-sender (get creator bounty-data))))
    (ok true)
  )
)

;; Read-only Functions

;; Get bounty details
(define-read-only (get-bounty (bounty-id uint))
  (map-get? bounties { bounty-id: bounty-id })
)

;; Get solution details
(define-read-only (get-solution (bounty-id uint) (solver principal))
  (map-get? solutions { bounty-id: bounty-id, solver: solver })
)

;; Get contract balance
(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

;; Get next bounty ID
(define-read-only (get-next-bounty-id)
  (var-get next-bounty-id)
)