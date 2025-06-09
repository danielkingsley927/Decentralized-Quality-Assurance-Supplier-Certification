# Decentralized Quality Assurance Supplier Certification System

A comprehensive blockchain-based system for managing supplier quality assurance, certifications, audits, and continuous improvement tracking using Clarity smart contracts.

## Overview

This system provides a decentralized approach to supplier quality management with the following key components:

- **QA Department Verification**: Validates and manages quality assurance departments
- **Supplier Assessment**: Evaluates supplier quality capabilities and performance
- **Certification Management**: Issues and manages supplier certifications at different levels
- **Audit Coordination**: Schedules and manages quality audits
- **Improvement Tracking**: Tracks supplier quality improvements and action plans

## Smart Contracts

### 1. QA Department Verification (`qa-department-verification.clar`)

Manages the registration and verification of quality assurance departments.

**Key Features:**
- Register QA departments with lead auditors
- Set certification levels and permissions
- Grant auditor permissions for certification and auditing
- Track department status and activity

**Main Functions:**
- `register-qa-department`: Register a new QA department
- `update-department-status`: Activate/deactivate departments
- `grant-auditor-permissions`: Assign permissions to auditors

### 2. Supplier Assessment (`supplier-assessment.clar`)

Handles supplier registration and quality assessments.

**Key Features:**
- Register suppliers with contact information
- Create comprehensive assessments with multiple scoring criteria
- Track quality, compliance, and process scores
- Calculate overall supplier ratings

**Main Functions:**
- `register-supplier`: Register a new supplier
- `create-assessment`: Perform quality assessment
- `get-supplier-latest-score`: Retrieve current supplier rating

### 3. Certification Management (`certification-management.clar`)

Manages supplier certifications at different levels (Bronze, Silver, Gold, Platinum).

**Key Features:**
- Four-tier certification system
- Automatic expiration and renewal tracking
- Requirements-based certification issuance
- Certification revocation capabilities

**Certification Levels:**
- **Bronze**: 60+ score, 1 year validity, 1 audit required
- **Silver**: 70+ score, 1 year validity, 2 audits required
- **Gold**: 80+ score, 6 months validity, 3 audits required
- **Platinum**: 90+ score, 6 months validity, 4 audits required

**Main Functions:**
- `issue-certification`: Issue new certifications
- `revoke-certification`: Revoke existing certifications
- `renew-certification`: Renew expiring certifications

### 4. Audit Coordination (`audit-coordination.clar`)

Coordinates and manages supplier quality audits.

**Key Features:**
- Schedule audits with specific auditors
- Track audit progress through multiple statuses
- Record findings and recommendations
- Assign compliance ratings

**Audit Statuses:**
- Scheduled
- In Progress
- Completed
- Cancelled

**Main Functions:**
- `schedule-audit`: Schedule new audits
- `start-audit`: Begin audit process
- `complete-audit`: Finalize audit with findings
- `cancel-audit`: Cancel scheduled audits

### 5. Improvement Tracking (`improvement-tracking.clar`)

Tracks supplier quality improvements and action plans.

**Key Features:**
- Create improvement plans with specific targets
- Assign improvement actions to responsible parties
- Track metrics and improvement percentages
- Monitor plan progress and completion

**Improvement Statuses:**
- Identified
- Planned
- In Progress
- Completed
- Verified

**Main Functions:**
- `create-improvement-plan`: Create new improvement plans
- `add-improvement-action`: Add specific actions to plans
- `complete-action`: Mark actions as completed
- `record-improvement-metric`: Track quantitative improvements

## Getting Started

### Prerequisites

- Clarity CLI or compatible development environment
- Stacks blockchain testnet access
- Basic understanding of Clarity smart contracts

### Deployment

1. Deploy contracts in the following order:
   \`\`\`bash
   clarinet deploy qa-department-verification
   clarinet deploy supplier-assessment
   clarinet deploy certification-management
   clarinet deploy audit-coordination
   clarinet deploy improvement-tracking
   \`\`\`

2. Initialize the system by registering QA departments:
   ```clarity
   (contract-call? .qa-department-verification register-qa-department "Main QA Dept" 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u3)
   \`\`\`

### Usage Examples

#### Register a Supplier
```clarity
(contract-call? .supplier-assessment register-supplier "ACME Manufacturing" 'ST1SUPPLIER123 "Electronics")
