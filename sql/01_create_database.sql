-- ============================================================================
-- CreditPulse Database Creation Script
-- ============================================================================
-- Project: CreditPulse Business Intelligence
-- Purpose: Create the creditpulse_db database
-- Author: Kiro AI
-- Date: 2026-10-07
-- ============================================================================

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS creditpulse_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Display success message
SELECT 'Database creditpulse_db created successfully' AS Status;

-- Show databases to confirm
SHOW DATABASES LIKE 'creditpulse_db';

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
