Bounty DAO Smart Contract

Overview

The Bounty DAO Smart Contract is a decentralized bounty management system built on the Stacks blockchain using Clarity.
It enables individuals or DAOs to create bounties, accept solutions, approve valid submissions, and distribute rewards in a transparent and trust-minimized way.

This contract is suitable for open-source projects, bug bounty programs, freelance task management, and DAO-based incentive systems.

Features

Create Bounty: Any user can create a bounty by locking up STX rewards until the task is solved or expires.

Submit Solution: Solvers can submit solutions before the bounty expires.

Approve Solution: Bounty creators approve valid solutions and automatically release rewards to the solver.

Withdraw Expired Bounties: If no valid solution is approved before expiry, creators can withdraw their locked funds.

Read-only Queries: Check bounty details, solution submissions, contract balance, and next bounty ID.

Data Structures

Bounties Map (bounties): Stores bounty metadata including creator, reward, expiry, and solver status.

Solutions Map (solutions): Stores submitted solutions with timestamps per bounty ID and solver.

Error Codes

ERR-NOT-AUTHORIZED (401) → Caller is not authorized.

ERR-BOUNTY-NOT-FOUND (404) → Bounty does not exist.

ERR-INSUFFICIENT-FUNDS (400) → Creator does not provide reward funds.

ERR-BOUNTY-EXPIRED (403) → Attempt to interact with an expired bounty.

ERR-BOUNTY-ALREADY-SOLVED (409) → Bounty already has an approved solver.

ERR-INVALID-SOLUTION (422) → No valid solution exists for approval.

Public Functions

(create-bounty title description expiry-blocks) → Creates a bounty and locks reward funds.

(submit-solution bounty-id solution) → Submit a solution to a bounty.

(approve-solution bounty-id solver) → Approve solver’s submission and release reward.

(withdraw-expired-bounty bounty-id) → Withdraw locked funds from expired bounties.

Read-only Functions

(get-bounty bounty-id) → Returns details of a bounty.

(get-solution bounty-id solver) → Returns a solver’s submission.

(get-contract-balance) → Returns the STX balance locked in the contract.

(get-next-bounty-id) → Returns the ID for the next bounty to be created.

Example Flow

Alice creates a bounty with a reward of 100 STX and a 100-block expiry.

Bob submits a solution before the deadline.

Alice approves Bob’s solution, and 100 STX are automatically transferred to Bob.

If no valid solution is approved, Alice can reclaim her 100 STX after expiry.

Security Considerations

Rewards are escrowed in the contract upon bounty creation.

Only the bounty creator can approve solutions or withdraw expired bounties.

Once solved, a bounty cannot be modified or re-approved.

Future Enhancements

Multi-solver payouts (split rewards).

DAO-based voting to approve solutions.

Reputation system for solvers and creators.

Optional arbitration process for disputes.