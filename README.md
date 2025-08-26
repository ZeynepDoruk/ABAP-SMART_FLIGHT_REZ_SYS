mart Flight Reservation & Delay Prediction System
Overview

This project is a comprehensive flight management and prediction platform that integrates SAP ABAP, Python Machine Learning, and Amadeus API to deliver an intelligent reservation and delay prediction system.
The system is designed to provide seamless integration between enterprise-level ERP systems and modern data-driven services, combining both back-end business logic and advanced predictive analytics.

Key Features
1. SAP ABAP Module
Custom Z-tables and database structures for flight reservations.
ABAP reports and transaction codes for:
Creating and managing reservations.
Displaying flight schedules and booking data.
Exporting and analyzing flight-related information.
Integrated ALV reports with Excel export functionality.
Admin management functionalities for user and booking control.

2. Python Module
Machine Learning models trained on real-world flight delay datasets (Kaggle).
Delay prediction based on:
Flight route.
Departure and arrival times.
Airline and seasonal patterns.
Flask-based REST API to expose prediction results.
Email notification system for sending updates to administrators and users.

3. Amadeus API Integration
Real-time flight information retrieval (schedules, availability, pricing).
Flight search and booking integration.
Synchronization between Amadeus API and SAP system to ensure data consistency.
Technical Architecture
Backend (ERP): SAP ABAP (NetWeaver, custom Z-programs, ALV, selection screens).
Machine Learning & API Services: Python (Pandas, Scikit-learn, Flask).
External Data Source: Amadeus API (RESTful integration).
Database: SAP custom tables and Oracle DB (for development environment).
Notifications: Python SMTP email service for admin and user updates.

Project Objectives

Enhance flight reservation systems with intelligent automation.
Reduce delays and disruptions by leveraging predictive analytics.
Bridge ERP systems with modern APIs and data science models.
Provide a scalable and user-friendly environment for both administrators and end users.
Future Improvements
Migration to SAP S/4HANA for improved performance.
Integration with Fiori applications for modern UX.
Advanced deep learning models for more accurate delay predictions.
Mobile app integration for passengers.

Author
Zeynep Doruk
Final Year Project – Smart Flight Reservation & Delay Prediction System
