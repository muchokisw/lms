
# Project Blueprint

## Overview

This document outlines the plan, style, design, and features of an agentic legal management system built with Flutter and Firebase. The system will leverage AI to assist with case management, document analysis, and other legal tasks.

## Current State

*   **Application:** Blank Flutter app connected to Firebase.

## Plan for Current Request

### Goal: Develop an agentic legal management system.

### File Structure (Phase 1 - Foundation):

### Firestore Database Structure:

```json
{
  "users": {
      "userId": 
      "firstName": 
      "secondName":
      "email": 
      "createdAt"(timestamp):
      "updatedAt"(timestamp):
      "role": 
  },
  "cases": {
    "caseId1": {
      "caseNumber": "C-2024-001",
      "title": "Contract Dispute - Acme Inc.",
      "description": "Breach of contract regarding software development.",
      "status": "open", // or "closed", "pending"
      "client": "clientId1",
      "assignedLawyers": ["lawyerId1", "lawyerId2"],
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  },
  "documents": {
    "docId1": {
      "caseId": "caseId1",
      "fileName": "contract.pdf",
      "storagePath": "/documents/caseId1/contract.pdf",
      "uploadedBy": "userId1",
      "createdAt": "timestamp",
      "summary": "This is an AI-generated summary of the document."
    }
  }
}
```

### Development Steps:

1.  **Create the proposed file structure.** I will create the directories and empty files for the initial structure.
2.  **Implement the authentication feature.** This will include the UI for login/signup and the repository for interacting with Firebase Auth.
3.  **Build the core services.** I will create the services for interacting with Firestore, Firebase Storage, and the Gemini API.
4.  **Develop the case and document management features.** This will involve creating the models, repositories, and UI for managing cases and documents.

https://jubileeinsurancelms.firebaseapp.com/__/auth/handler 
