
# Project Blueprint

## Overview

This document outlines the plan, style, design, and features of a bespoke Legal Management System for Jubilee Insurance, built with Flutter and Firebase. The system is designed to streamline and automate the contract review and case management processes for the legal and business teams.

## Current State & Features

*   **Authentication:** Robust user authentication is in place, allowing sign-in via email/password and Microsoft accounts. User roles (e.g., 'Client', 'Legal') are managed in Firestore.
*   **UI Foundation:**
    *   A modern, responsive UI with support for light/dark modes and dynamic font sizing.
    *   A main navigation structure with tabs for Dashboard, Contracts, Cases, Tasks, Analytics, and Reports.
*   **Contracts Tab:**
    *   The 'Contracts' tab is set up with two sub-tabs: 'Business Contract' and 'Service Contract'.
    *   These sub-tabs are currently blank placeholders awaiting implementation of their specific workflows.

## Plan for Current Request: Contract Workflow Implementation

The next phase is to build out the core functionality for the 'Business Contract' and 'Service Contract' sub-tabs based on the detailed process flows provided.

### 1. High-Level Design for Contract Sub-Tabs

Each sub-tab (Business & Service) will be composed of two primary views:

*   **Contracts Dashboard:**
    *   This will be the main view for the sub-tab.
    *   It will display a real-time list of all contracts of that type, fetched from Firestore.
    *   Each item in the list will be a summary card showing key details like **Contract Title**, **Current Status** (e.g., "In Legal Review", "Awaiting Client Signature"), and **Expiry Date**.
    *   A **Floating Action Button** will allow authorized users (i.e., the 'Business' team) to initiate a new contract review process.
*   **Contract Details & Workflow View:**
    *   Clicking a contract on the dashboard will navigate the user here.
    *   **Workflow Stepper:** A visual timeline at the top will clearly indicate the contract's current stage in the process.
    *   **Contract Information Panel:** Displays the essential metadata captured during initiation (Parties, Commencement Date, Expiry Date, Contract Price, etc.). This section will be read-only after the initial submission.
    *   **Documents & Versioning Section:** A secure file management area to upload and access all related documents. It will maintain a version history of the primary contract as it's revised.
    *   **Review & Communication Thread:** A dedicated, chronological comment thread for all communication between the Legal and Business teams regarding the contract, creating a clear and auditable record.
    *   **Contextual Action Buttons:** The UI will dynamically display action buttons (e.g., "Submit to Legal", "Share with Client", "Upload Executed Contract") based on the contract's current status and the user's role.

### 2. Backend & Technical Implementation

*   **Firestore Database (`contracts` collection):**
    *   A new `contracts` collection will be created.
    *   Each document will represent a single contract, storing its metadata, type ('Business' or 'Service'), current status, involved user IDs, and timestamps for each stage.
    *   Sub-collections within each contract document will manage the discussion thread comments and the list of document references.
*   **Firebase Storage:**
    *   All uploaded files will be stored securely in Firebase Storage, organized into folders based on the contract ID.
*   **Firebase Cloud Functions (for automation):**
    *   **5-Day Upload Reminder:** A scheduled function will query for contracts signed by the CEO over 5 days ago that are missing the final executed copy.
    *   **60-Day Expiry Reminder:** A separate scheduled function will find all contracts expiring in 60 days.
    *   These functions will trigger automated notifications (e.g., in-app or email) to the responsible parties.
*   **Role-Based Access Control (RBAC):**
    *   The application will enforce strict permissions. The UI and available actions will adapt based on the logged-in user's role ('Business' or 'Legal'), ensuring data integrity and process compliance.

This structured approach will create an intuitive, efficient, and powerful system that directly addresses the specified workflows, enhancing clarity and accountability in Jubilee Insurance's contract management process.
