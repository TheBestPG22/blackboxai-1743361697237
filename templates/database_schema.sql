-- Radiology Information System Database Schema
PRAGMA foreign_keys = ON;

-- Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'radiologist', 'technician', 'receptionist')),
    status TEXT NOT NULL CHECK(status IN ('active', 'inactive')),
    last_login DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Patients Table
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mrn TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    dob DATE NOT NULL,
    gender TEXT CHECK(gender IN ('male', 'female', 'other')),
    phone TEXT,
    email TEXT,
    address TEXT,
    insurance_provider TEXT,
    insurance_number TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Imaging Studies Table
CREATE TABLE imaging_studies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    study_uid TEXT UNIQUE NOT NULL,
    patient_id INTEGER NOT NULL,
    study_date DATETIME NOT NULL,
    modality TEXT NOT NULL CHECK(modality IN ('xray', 'ct', 'mri', 'ultrasound', 'mammography')),
    body_part TEXT NOT NULL,
    description TEXT,
    referring_physician TEXT,
    status TEXT NOT NULL CHECK(status IN ('scheduled', 'in-progress', 'completed', 'cancelled')),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- DICOM Images Table
CREATE TABLE dicom_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    study_id INTEGER NOT NULL,
    sop_instance_uid TEXT UNIQUE NOT NULL,
    file_path TEXT NOT NULL,
    series_number INTEGER,
    instance_number INTEGER,
    image_type TEXT,
    acquisition_date DATETIME,
    processed BOOLEAN DEFAULT 0,
    processing_results TEXT,
    FOREIGN KEY (study_id) REFERENCES imaging_studies(id) ON DELETE CASCADE
);

-- AI Processing Results
CREATE TABLE ai_processing (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    algorithm_name TEXT NOT NULL,
    processing_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    results_json TEXT NOT NULL,
    confidence_score REAL,
    FOREIGN KEY (image_id) REFERENCES dicom_images(id) ON DELETE CASCADE
);

-- Reports Table
CREATE TABLE reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    study_id INTEGER NOT NULL,
    radiologist_id INTEGER NOT NULL,
    report_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    findings TEXT,
    impression TEXT,
    status TEXT NOT NULL CHECK(status IN ('draft', 'finalized', 'amended')),
    FOREIGN KEY (study_id) REFERENCES imaging_studies(id) ON DELETE CASCADE,
    FOREIGN KEY (radiologist_id) REFERENCES users(id)
);

-- Appointments Table
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL,
    study_id INTEGER,
    appointment_date DATETIME NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    status TEXT NOT NULL CHECK(status IN ('scheduled', 'completed', 'cancelled', 'no-show')),
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (study_id) REFERENCES imaging_studies(id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX idx_imaging_studies_patient ON imaging_studies(patient_id);
CREATE INDEX idx_dicom_images_study ON dicom_images(study_id);
CREATE INDEX idx_ai_processing_image ON ai_processing(image_id);