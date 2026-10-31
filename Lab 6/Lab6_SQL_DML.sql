                                
                                
                                -- Lab 6 : SQL - DDL and DML 

-- Tasks :

-- Part 1: Data Definition Language (DDL) 

/*
CREATE DATABASE Lab6 ;

USE Lab6; 
                                           -- The final RLMS relational schema :
                                           
-- Person TABLE :

CREATE TABLE Person (
pid INT PRIMARY KEY ,
firstName VARCHAR (100) NOT NULL ,
lastName VARCHAR (100) NOT NULL ,
email VARCHAR (150) NOT NULL ,
affiliation VARCHAR (150) NOT NULL ,
startDate DATE NOT NULL ,
endDate DATE 
);

-- Student TABLE :

CREATE TABLE Student (
pid INT PRIMARY KEY ,
program VARCHAR (20) NOT NULL ,
FOREIGN KEY ( pid ) REFERENCES Person ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Employee TABLE :

CREATE TABLE Employee (
pid INT PRIMARY KEY ,
phone VARCHAR (30) NOT NULL ,
office VARCHAR (100) NOT NULL ,
position VARCHAR(100) NOT NULL,

-- At most one current supervisor .
-- NULL is allowed for the Dean .

supervisorPid INT ,
FOREIGN KEY ( pid ) REFERENCES Person ( pid ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( supervisorPid ) REFERENCES Employee ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Academic TABLE :

CREATE TABLE Academic (
pid INT PRIMARY KEY ,
FOREIGN KEY ( pid ) REFERENCES Employee ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Faculty TABLE :

CREATE TABLE Faculty (
pid INT PRIMARY KEY ,
FOREIGN KEY ( pid ) REFERENCES Academic ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Administrative TABLE :

CREATE TABLE Administrative (
pid INT PRIMARY KEY ,
FOREIGN KEY ( pid ) REFERENCES Employee ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Technical TABLE :

CREATE TABLE Technical (
pid INT PRIMARY KEY ,
FOREIGN KEY ( pid ) REFERENCES Employee ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Advises TABLE :

CREATE TABLE Advises (
academicPid INT NOT NULL ,
studentPid INT NOT NULL ,

PRIMARY KEY ( academicPid , studentPid ) ,

FOREIGN KEY ( academicPid ) REFERENCES Academic ( pid ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( studentPid ) REFERENCES Student ( pid ) ON DELETE CASCADE ON UPDATE CASCADE
) ;

-- Laboratory TABLE :

CREATE TABLE Laboratory (
labId INT PRIMARY KEY ,
name VARCHAR (150) NOT NULL ,
building VARCHAR (100) NOT NULL ,
roomNumber VARCHAR (50) NOT NULL ,
discipline VARCHAR (150) NOT NULL ,

-- Supervises : exactly one Faculty supervisor
supervisorPid INT NOT NULL ,
FOREIGN KEY ( supervisorPid ) REFERENCES Faculty ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE
) ;

-- Attached TABLE :

CREATE TABLE Attached (
pid INT NOT NULL ,
labId INT NOT NULL ,
PRIMARY KEY ( pid , labId ) ,

FOREIGN KEY ( pid ) REFERENCES Person ( pid ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( labId ) REFERENCES Laboratory ( labId ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ResearchProject TABLE :

CREATE TABLE ResearchProject (
code VARCHAR (50) PRIMARY KEY ,
title VARCHAR (200) NOT NULL ,
startDate DATE NOT NULL ,
endDate DATE NOT NULL ,
status VARCHAR (20) NOT NULL
);

-- Participates TABLE :

CREATE TABLE Participates (
pid INT NOT NULL ,
projectCode VARCHAR (50) NOT NULL ,
role VARCHAR (30) NOT NULL ,
PRIMARY KEY ( pid , projectCode ) ,
FOREIGN KEY ( pid ) REFERENCES Person ( pid ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( projectCode ) REFERENCES ResearchProject ( code ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Budget TABLE :

CREATE TABLE Budget (
budgetLine VARCHAR (50) PRIMARY KEY ,
amountGranted DECIMAL (12 ,2) NOT NULL ,
amountDisbursed DECIMAL (12 ,2) NOT NULL ,
startDate DATE NOT NULL ,
endDate DATE NOT NULL ,
-- Manages : exactly one Academic manager
managerPid INT NOT NULL ,
FOREIGN KEY ( managerPid ) REFERENCES Academic ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- FundsPrj TABLE :

CREATE TABLE FundsPrj (
budgetLine VARCHAR (50) NOT NULL ,
projectCode VARCHAR (50) NOT NULL ,
PRIMARY KEY ( budgetLine , projectCode ) ,
FOREIGN KEY ( budgetLine ) REFERENCES Budget ( budgetLine ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( projectCode ) REFERENCES ResearchProject ( code ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- FundsLab TABLE :
CREATE TABLE FundsLab (
budgetLine VARCHAR (50) NOT NULL ,
labId INT NOT NULL ,
PRIMARY KEY ( budgetLine , labId ) ,
FOREIGN KEY ( budgetLine ) REFERENCES Budget ( budgetLine ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( labId ) REFERENCES Laboratory ( labId ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- EquipmentModel TABLE :

CREATE TABLE EquipmentModel (
modelId INT PRIMARY KEY ,
commercialName VARCHAR (150) NOT NULL ,
manufacturer VARCHAR (150) NOT NULL ,
category VARCHAR (100) NOT NULL ,
requiredEnvironment VARCHAR (200) NOT NULL ,
trainingMandatory BOOLEAN NOT NULL
);

-- EquipmentUnit TABLE :

CREATE TABLE EquipmentUnit (
serialNo VARCHAR (100) PRIMARY KEY ,
acquisitionDate DATE NOT NULL ,
purchaseCost DECIMAL (12 ,2) NOT NULL ,
status VARCHAR (30) NOT NULL ,
portable BOOLEAN NOT NULL ,
-- InstanceOf : exactly one EquipmentModel
modelId INT NOT NULL ,
-- LocatedIn : exactly one Laboratory
labId INT NOT NULL ,
FOREIGN KEY ( modelId ) REFERENCES EquipmentModel ( modelId ) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY ( labId ) REFERENCES Laboratory ( labId ) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Certification TABLE :

CREATE TABLE Certification (
code VARCHAR (50) PRIMARY KEY ,
title VARCHAR (150) NOT NULL ,
issuingAuthority VARCHAR (150) NOT NULL ,
validityPeriod INT NOT NULL ,
safetyLevel VARCHAR (100) NOT NULL
);

-- Requires TABLE :

CREATE TABLE Requires (
modelId INT NOT NULL ,
certCode VARCHAR (50) NOT NULL ,
PRIMARY KEY ( modelId , certCode ) ,
FOREIGN KEY ( modelId ) REFERENCES EquipmentModel ( modelId ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( certCode ) REFERENCES Certification ( code ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Holds TABLE :

CREATE TABLE Holds (
pid INT NOT NULL ,
certCode VARCHAR (50) NOT NULL ,
issueDate DATE NOT NULL ,
expirationDate DATE NOT NULL ,
grade VARCHAR (50) ,
PRIMARY KEY ( pid , certCode ) ,
FOREIGN KEY ( pid ) REFERENCES Person ( pid ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( certCode ) REFERENCES Certification ( code ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Reservation TABLE :

CREATE TABLE Reservation (
resId INT PRIMARY KEY ,
submissionTS TIMESTAMP NOT NULL ,
plannedStart TIMESTAMP NOT NULL ,
plannedEnd TIMESTAMP NOT NULL ,
purpose VARCHAR (255) NOT NULL ,
status VARCHAR (20) NOT NULL DEFAULT 'Pending',
-- MadeBy : exactly one Person
madeByPid INT NOT NULL ,
-- For : exactly one ResearchProject
projectCode VARCHAR (50) NOT NULL ,
-- Approves : at most one approver
approverPid INT ,
FOREIGN KEY ( madeByPid ) REFERENCES Person ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE ,
FOREIGN KEY ( projectCode ) REFERENCES ResearchProject ( code ) ON DELETE NO ACTION ON UPDATE CASCADE,
FOREIGN KEY ( approverPid ) REFERENCES Person ( pid ) ON DELETE SET NULL ON UPDATE CASCADE );

-- Reserves TABLE :

CREATE TABLE Reserves (
resId INT NOT NULL ,
serialNo VARCHAR (100) NOT NULL ,
PRIMARY KEY ( resId , serialNo ) ,
FOREIGN KEY ( resId ) REFERENCES Reservation ( resId ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( serialNo ) REFERENCES EquipmentUnit ( serialNo ) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Maintenance TABLE :

CREATE TABLE Maintenance (
serialNo VARCHAR (100) NOT NULL ,
startTS TIMESTAMP NOT NULL ,
endTS TIMESTAMP NOT NULL ,
type VARCHAR (20) NOT NULL ,
description VARCHAR (255) NOT NULL ,
cost DECIMAL (12 ,2) NOT NULL ,
outcome VARCHAR (30) NOT NULL ,
-- DoneBy : exactly one Technical staff member
technicalPid INT NOT NULL ,
PRIMARY KEY ( serialNo , startTS ) ,
FOREIGN KEY ( serialNo ) REFERENCES EquipmentUnit ( serialNo ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( technicalPid ) REFERENCES Technical ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- CalibrationRecord TABLE :
CREATE TABLE CalibrationRecord (
serialNo VARCHAR (100) NOT NULL ,
calibDate DATE NOT NULL ,
calibrationType VARCHAR (100) NOT NULL ,
result VARCHAR (20) NOT NULL ,
nextDueDate DATE NOT NULL ,
remarks VARCHAR (255) NOT NULL ,
PRIMARY KEY ( serialNo , calibDate ) ,
FOREIGN KEY ( serialNo ) REFERENCES EquipmentUnit ( serialNo ) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Consumable TABLE :

CREATE TABLE Consumable (
consId INT PRIMARY KEY ,
name VARCHAR (150) NOT NULL ,
unitOfMeasure VARCHAR (50) NOT NULL ,
hazardLevel VARCHAR (100) NOT NULL ,
reorderThreshold DECIMAL (12 ,2) NOT NULL
);

-- Supplier TABLE :

CREATE TABLE Supplier (
suppId INT PRIMARY KEY ,
name VARCHAR (150) NOT NULL ,
contactEmail VARCHAR (150) NOT NULL ,
phone VARCHAR (30) NOT NULL
);

-- Supplies TABLE :

CREATE TABLE Supplies (
suppId INT NOT NULL ,
consId INT NOT NULL ,
labId INT NOT NULL ,
unitPrice DECIMAL (12 ,2) NOT NULL ,
PRIMARY KEY ( suppId , consId , labId ) ,
FOREIGN KEY ( suppId ) REFERENCES Supplier ( suppId ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( consId ) REFERENCES Consumable ( consId ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( labId ) REFERENCES Laboratory ( labId ) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Stocks TABLE :

CREATE TABLE Stocks (
labId INT NOT NULL ,
consId INT NOT NULL ,
quantityOnHand DECIMAL (12 ,2) NOT NULL ,
lastRestockDate DATE NOT NULL ,
storageCondition VARCHAR (150) ,
-- Monitors : exactly one Technical member
-- for each stock occurrence
technicalPid INT NOT NULL ,
monitoringSince DATE NOT NULL ,
PRIMARY KEY ( labId , consId ) ,
FOREIGN KEY ( labId ) REFERENCES Laboratory ( labId ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( consId ) REFERENCES Consumable ( consId ) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( technicalPid ) REFERENCES Technical ( pid ) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- Consumes TABLE :

CREATE TABLE Consumes (
resId INT NOT NULL ,
labId INT NOT NULL ,
consId INT NOT NULL ,
quantityUsed DECIMAL (12 ,2) NOT NULL ,
PRIMARY KEY ( resId , labId , consId ) ,
FOREIGN KEY ( resId ) REFERENCES Reservation ( resId ) ON DELETE CASCADE ON UPDATE CASCADE ,
FOREIGN KEY ( labId , consId ) REFERENCES Stocks ( labId , consId ) ON DELETE NO ACTION ON UPDATE CASCADE
);

 */

-- Part 2 : Data Manipulation Language (DML) - Population and Updates :

/*
INSERT INTO Person (pid, firstName, lastName, email, affiliation, startDate, endDate) VALUES
(1, 'Driss',   'Bitar',      'dr.bitar@um6p.ma',   'Faculty of Science',    '2015-09-01', NULL),
(2, 'Leila',   'Haddad',     'l.haddad@um6p.ma',   'Faculty of Science',    '2018-09-01', NULL),
(3, 'Adam',    'Ait Lahcen', 'mr.lahcen@um6p.ma',  'Faculty of Science',    '2019-02-01', NULL),
(4, 'Sara',    'Idrissi',    's.idrissi@um6p.ma',  'Administration Office', '2020-01-15', NULL),
(5, 'Youssef', 'Amrani',     'y.amrani@um6p.ma',   'Technical Services',    '2021-03-01', NULL),
(6, 'Nadia',   'Fassi',      'n.fassi@um6p.ma',    'Technical Services',    '2022-09-01', NULL),
(7, 'Amine',   'Chraibi',    'a.chraibi@univ.ma',  'Faculty of Science',    '2023-09-01', NULL),
(8, 'Rayane',  'Benyassine', 'mr.rayane@univ.ma',  'Faculty of Science',    '2024-09-01', NULL),
(9, 'Hamza',   'Ouazzani',   'h.ouazzani@univ.ma', 'Faculty of Science',    '2025-09-01', '2027-06-30');

INSERT INTO Student (pid, program) VALUES
(7, 'PhD'),
(8, 'MSc'),
(9, 'MSc');


INSERT INTO Employee (pid, phone, office, position, supervisorPid) VALUES
(1, '+212600000001', 'Deanery 1', 'Dean',                  NULL),
(2, '+212600000002', 'Riad5-O12', 'Associate Professor',   1),
(3, '+212600000003', 'Riad3-O07', 'Assistant Professor',   1),
(4, '+212600000004', 'Admin-O01', 'Lab Coordinator',       1),
(5, '+212600000005', 'Riad5-T01', 'Senior Lab Technician', 2),
(6, '+212600000006', 'Riad3-T02', 'Lab Technician',        3);

INSERT INTO Academic (pid) VALUES
(1),
(2),
(3);


INSERT INTO Faculty (pid) VALUES
(1),
(2),
(3);

INSERT INTO Administrative (pid) VALUES
(4);

INSERT INTO Technical (pid) VALUES
(5),
(6);

INSERT INTO Advises (academicPid, studentPid) VALUES
(2, 7),
(3, 8),
(2, 8),
(3, 9);

INSERT INTO Laboratory (labId, name, building, roomNumber, discipline, supervisorPid) VALUES
(1, 'Physics Laboratory',   'Riad5', 'R101', 'Physics',           2),
(2, 'Chemistry Laboratory', 'Riad3', 'C204', 'Chemistry',         3),
(3, 'Materials Laboratory', 'Riad7', 'M010', 'Materials Science', 1);

INSERT INTO Attached (pid, labId) VALUES
(2, 1),
(5, 1),
(7, 1),
(3, 2),
(6, 2),
(8, 2),
(1, 3),
(9, 3);


INSERT INTO ResearchProject (code, title, startDate, endDate, status) VALUES
('P-OPT-01',  'Optical Imaging of Thin Films',      '2026-01-01', '2027-12-31', 'Active'),
('P-THR-02',  'Thermal Conductivity of Composites', '2025-09-01', '2027-06-30', 'Active'),
('P-CHM-03',  'Catalyst Degradation Study',         '2024-02-01', '2027-06-30', 'Cancelled'),
('P-NANO-04', 'Nanoparticle Synthesis',             '2026-03-01', '2028-02-28', 'Active');

-- Exactly one PI per project
INSERT INTO Participates (pid, projectCode, role) VALUES
(2, 'P-OPT-01',  'Principal Investigator'),
(7, 'P-OPT-01',  'Researcher'),
(5, 'P-OPT-01',  'Technician'),
(3, 'P-THR-02',  'Principal Investigator'),
(8, 'P-THR-02',  'Researcher'),
(6, 'P-THR-02',  'Technician'),
(3, 'P-CHM-03',  'Principal Investigator'),
(8, 'P-CHM-03',  'Researcher'),
(1, 'P-NANO-04', 'Principal Investigator'),
(9, 'P-NANO-04', 'Researcher');

INSERT INTO Budget (budgetLine, amountGranted, amountDisbursed, startDate, endDate, managerPid) VALUES
('BL-2026-A', 150000.00, 62000.50, '2026-01-01', '2026-12-31', 2),
('BL-2026-B',  80000.00, 20000.00, '2026-01-01', '2026-12-31', 3),
('BL-2025-C',  40000.00, 39500.00, '2025-01-01', '2025-12-31', 1),
('BL-2026-D', 120000.00, 10000.00, '2026-03-01', '2027-02-28', 2);

INSERT INTO FundsPrj (budgetLine, projectCode) VALUES
('BL-2026-A', 'P-OPT-01'),
('BL-2026-A', 'P-THR-02'),
('BL-2026-B', 'P-THR-02'),
('BL-2025-C', 'P-CHM-03'),
('BL-2026-D', 'P-NANO-04');

INSERT INTO FundsLab (budgetLine, labId) VALUES
('BL-2026-A', 1),
('BL-2026-B', 2),
('BL-2025-C', 2),
('BL-2026-D', 3);

-- Model 4 has no units
INSERT INTO EquipmentModel (modelId, commercialName, manufacturer, category, requiredEnvironment, trainingMandatory) VALUES
(1, 'Olympus BX53',         'Olympus', 'Optical Microscope',  'Vibration-free table, 18-25 C', TRUE),
(2, 'Zeiss Axio Imager A2', 'Zeiss',   'Optical Microscope',  'Dust-free room, 18-25 C',       TRUE),
(3, 'Fluke 1524 Reference', 'Fluke',   'Thermometer',         'Room temperature',              FALSE),
(4, 'Hitachi SU8010',       'Hitachi', 'Electron Microscope', 'Clean room, high vacuum',       TRUE);


INSERT INTO EquipmentUnit (serialNo, acquisitionDate, purchaseCost, status, portable, modelId, labId) VALUES
('OLY-BX53-001', '2023-03-15', 18500.00, 'Available',      FALSE, 1, 1),
('OLY-BX53-002', '2024-06-01', 19200.00, 'In Maintenance', FALSE, 1, 1),
('ZEI-AXIO-001', '2022-11-20', 45000.00, 'Available',      FALSE, 2, 3),
('FLK-1524-001', '2025-01-10',  2300.00, 'Available',      TRUE,  3, 1),
('FLK-1524-002', '2025-01-10',  2300.00, 'Available',      TRUE,  3, 2),
('FLK-1524-003', '2025-06-20',  2300.00, 'Available',      TRUE,  3, 1);

INSERT INTO Certification (code, title, issuingAuthority, validityPeriod, safetyLevel) VALUES
('CERT-MIC',   'Microscope Operation', 'University Safety Office',    24, 'Level 1'),
('CERT-LASER', 'Laser Safety',         'National Laser Safety Board', 12, 'Level 2'),
('CERT-CHEM',  'Chemical Handling',    'University Safety Office',    36, 'Level 2');

INSERT INTO Requires (modelId, certCode) VALUES
(1, 'CERT-MIC'),
(1, 'CERT-LASER'),
(2, 'CERT-MIC'),
(4, 'CERT-LASER');


INSERT INTO Holds (pid, certCode, issueDate, expirationDate, grade) VALUES
(2, 'CERT-MIC',   '2025-02-10', '2027-02-10', 'A'),
(2, 'CERT-LASER', '2026-01-20', '2027-01-20', 'B'),
(5, 'CERT-MIC',   '2025-05-20', '2027-05-20', 'B'),
(7, 'CERT-MIC',   '2025-09-15', '2027-09-15', 'A'),
(8, 'CERT-MIC',   '2025-10-01', '2027-10-01', 'B'),
(7, 'CERT-LASER', '2026-03-01', '2027-03-01', 'A'),
(3, 'CERT-CHEM',  '2024-01-15', '2027-01-15', NULL),
(6, 'CERT-CHEM',  '2025-06-10', '2028-06-10', 'A');



INSERT INTO Reservation (resId, submissionTS, plannedStart, plannedEnd, purpose, status, madeByPid, projectCode, approverPid) VALUES
(1, '2026-09-01 09:00:00', '2026-09-10 09:00:00', '2026-09-10 12:00:00', 'Thin film imaging',           'Completed', 7, 'P-OPT-01', 2),
(2, '2026-10-27 14:30:00', '2026-11-03 10:00:00', '2026-11-03 16:00:00', 'Composite sample inspection', 'Approved',  8, 'P-THR-02', 3),
(3, '2026-10-28 11:00:00', '2026-11-12 09:00:00', '2026-11-12 13:00:00', 'Surface roughness analysis',  'Pending',   7, 'P-OPT-01', NULL),
(4, '2026-10-05 08:15:00', '2026-10-15 14:00:00', '2026-10-15 17:00:00', 'Grain structure imaging',     'Rejected',  8, 'P-THR-02', 3),
(5, '2026-10-10 10:00:00', '2026-10-20 09:00:00', '2026-10-20 11:00:00', 'Calibration comparison',      'Cancelled', 2, 'P-OPT-01', NULL),
(6, '2025-11-01 09:30:00', '2025-11-10 09:00:00', '2025-11-10 15:00:00', 'Catalyst temperature runs',   'Completed', 8, 'P-CHM-03', 3),
(7, '2026-10-29 09:00:00', '2026-11-20 09:00:00', '2026-11-20 12:00:00', 'Catalyst re-test',            'Pending',   8, 'P-CHM-03', NULL);


INSERT INTO Reserves (resId, serialNo) VALUES
(1, 'OLY-BX53-001'),
(1, 'FLK-1524-001'),
(2, 'ZEI-AXIO-001'),
(2, 'FLK-1524-002'),
(3, 'OLY-BX53-001'),
(4, 'ZEI-AXIO-001'),
(5, 'OLY-BX53-001'),
(6, 'FLK-1524-002'),
(7, 'FLK-1524-002');

INSERT INTO Maintenance (serialNo, startTS, endTS, type, description, cost, outcome, technicalPid) VALUES
('OLY-BX53-001', '2026-03-05 09:00:00', '2026-03-05 11:30:00', 'Preventive', 'Annual cleaning and alignment', 120.00, 'Completed',   5),
('OLY-BX53-002', '2026-10-20 08:00:00', '2026-10-31 17:00:00', 'Corrective', 'Stage motor replacement',       450.00, 'In Progress', 5),
('ZEI-AXIO-001', '2026-06-12 13:00:00', '2026-06-14 17:00:00', 'Corrective', 'Replace light source',          800.00, 'Completed',   6),
('FLK-1524-001', '2025-12-01 10:00:00', '2025-12-01 11:00:00', 'Preventive', 'Sensor inspection',              60.00, 'Completed',   6);

INSERT INTO CalibrationRecord (serialNo, calibDate, calibrationType, result, nextDueDate, remarks) VALUES
('FLK-1524-001', '2026-01-15', 'Temperature',       'Pass', '2027-01-15', 'Within tolerance'),
('FLK-1524-002', '2026-01-15', 'Temperature',       'Pass', '2027-01-15', 'Within tolerance'),
('OLY-BX53-001', '2026-02-20', 'Optical alignment', 'Pass', '2027-02-20', 'No adjustment needed'),
('ZEI-AXIO-001', '2026-05-10', 'Optical alignment', 'Fail', '2026-06-10', 'Re-calibration required'),
('ZEI-AXIO-001', '2026-06-14', 'Optical alignment', 'Pass', '2027-06-14', 'Passed after light source replacement');

INSERT INTO Consumable (consId, name, unitOfMeasure, hazardLevel, reorderThreshold) VALUES
(1, 'Ethanol 96%',              'L',   'Flammable', 5.00),
(2, 'Microscope Immersion Oil', 'ml',  'Low',       50.00),
(3, 'Liquid Nitrogen',          'L',   'High',      20.00),
(4, 'Nitrile Gloves',           'box', 'Low',       10.00),
(5, 'Acetone',                  'L',   'Flammable', 5.00);

INSERT INTO Supplier (suppId, name, contactEmail, phone) VALUES
(1, 'ChemSupply Maroc',      'sales@chemsupply.ma',   '+212522000001'),
(2, 'LabEquip Distribution', 'info@labequip.ma',      '+212522000002'),
(3, 'CryoGas Africa',        'orders@cryogas.africa', '+212522000003');


INSERT INTO Supplies (suppId, consId, labId, unitPrice) VALUES
(1, 1, 2, 12.50),
(2, 1, 2, 11.90),
(1, 1, 1, 13.00),
(1, 5, 1,  9.80),
(2, 2, 1, 45.00),
(2, 4, 1,  6.00),
(2, 4, 2,  6.20),
(3, 3, 3,  2.50);


INSERT INTO Stocks (labId, consId, quantityOnHand, lastRestockDate, storageCondition, technicalPid, monitoringSince) VALUES
(1, 2,  40.00, '2026-09-15', 'Room temperature, dark', 5, '2025-01-10'),
(1, 4,  25.00, '2026-08-20', 'Dry shelf',              5, '2025-03-01'),
(2, 1,  30.00, '2026-10-01', 'Flammables cabinet',     6, '2025-06-01'),
(2, 4,  15.00, '2026-07-12', 'Dry shelf',              6, '2025-06-01'),
(3, 3, 100.00, '2026-10-10', 'Cryogenic dewar',        6, '2026-01-05');

INSERT INTO Consumes (resId, labId, consId, quantityUsed) VALUES
(1, 1, 2, 5.00),
(1, 1, 4, 2.00),
(2, 2, 1, 3.50),
(6, 2, 1, 1.50),
(6, 2, 4, 1.00);

*/
-- Performing the mentioned DML operations ;


/*
-- 1/
INSERT INTO Person (pid, firstName, lastName, email, affiliation, startDate, endDate) VALUES
(10, 'Amir','jaber', 'amir.jaber@um6p.ma', 'Faculty of Science', '2015-09-01', NULL) ;
INSERT INTO Student (pid, program) VALUES 
(10,'PhD');
INSERT INTO Advises (academicPid, studentPid) VALUES (2, 10);  -- every student needs an advisor

-- 2/
INSERT INTO EquipmentUnit(serialNo, acquisitionDate, purchaseCost, status, portable, modelId, labId) VALUES
('ZEI-AXIO-002', '2022-11-20', 45000.00, 'Available', FALSE, 2, 3);

-- 3/
INSERT INTO Reservation(resId, submissionTS, plannedStart, plannedEnd, purpose, status, madeByPid, projectCode, approverPid) VALUES
(8, '2026-10-22 10:30:00', '2026-11-04 10:00:00', '2026-11-04 16:00:00', 'Composite sample inspection', 'Pending',  8, 'P-THR-02', NULL);
INSERT INTO Reserves (resId, serialNo) VALUES
(8, 'ZEI-AXIO-002');

-- 4/
UPDATE Reservation
SET status = 'Approved' , approverPid = 2 
WHERE resId = 8 and status = 'Pending' ;

-- 5/
UPDATE Stocks
SET quantityOnHand = 10.00
WHERE labId = 2 and consId = 4;

-- 6/
INSERT INTO Consumes (resId, labId, consId, quantityUsed) VALUES
(2,2,4, 7.00);

-- 7/
UPDATE Reservation
SET status = 'Cancelled'
WHERE status = 'Pending' and projectCode IN (SELECT code FROM ResearchProject where status = 'Cancelled' );

-- 8/
INSERT INTO Supplier (suppId, name, contactEmail, phone)
VALUES (5, 'Test Supplier', 'test@test.ma', '+212895002349');
DELETE FROM Supplier WHERE suppId = 5;
SELECT * FROM Supplier WHERE suppId = 5; 


*/
-- Part 3 : Data Manipulation Language (DML) – Queries

-- A. Simple Queries
/*
SELECT pid, firstName, lastName, email 
FROM Person
ORDER BY lastName, firstName;

SELECT DISTINCT discipline
FROM Laboratory;

SELECT * 
FROM Person
WHERE email LIKE '%@um6p.ma' ;

SELECT *
FROM Person 
WHERE endDate is NULL ;

SELECT * 
FROM Reservation 
WHERE plannedStart >= '2026-11-01 00:00:00' AND plannedStart < '2026-12-01 00:00:00' ;

-- B. Queries Using Joins 

SELECT concat(firstName,' ',lastName) AS Participant , title, role
FROM ResearchProject RP, Participates PP, Person P
WHERE projectCode = Code and (P.pid = PP.pid);

SELECT B.* , concat(P.firstName,' ',P.lastName) AS Manager
FROM Budget B, Person P
WHERE B.managerPid = P.pid;

SELECT R.* , concat(firstName,' ',lastName) AS Reserver, title
FROM Reservation R, Person P, ResearchProject RP
WHERE R.madeByPid = P.pid and R.projectCode = RP.code;

SELECT R.resId, R.serialNo, commercialName, L.name AS Laboratory_name
FROM Reserves R, EquipmentUnit EU, EquipmentModel EM, Laboratory L
WHERE R.serialNo = EU.serialNo and EU.modelId = EM.modelId and EU.labId = L.labId;

SELECT  R.*, concat(firstName,' ',lastName) AS Approver_fullName
FROM Reservation R, Person P
WHERE R.approverPid = P.pid and status = 'Approved' ;

SELECT L.name AS LaboratoryName, C.name AS ConsumableName , quantityOnHand, concat(firstName,' ',lastName) AS monitor_fullName
FROM Stocks S, Person P, Laboratory L, Consumable C
WHERE S.technicalPid = P.pid and S.labId = L.labId and S.consId = C.consId;

-- C. Aggregation Queries

SELECT labId, count(serialNo) as numberOfEquipmentUnit
FROM EquipmentUnit
GROUP BY labId ;

SELECT consId, SUM(quantityUsed) as TotalQuantityUsed
FROM Consumes
GROUP BY consId;


-- D. Queries Combining Joins and Aggregation

SELECT L.name , count(EU.serialNo) as numberOfEquipmentUnit
FROM EquipmentUnit EU, Laboratory L
WHERE EU.labId = L.labId
GROUP BY L.labId
HAVING numberOfEquipmentUnit > 3;

SELECT RP.title, sum(amountGranted) as TotalAmountGranted
FROM ResearchProject RP, FundsPrj FP, Budget B
WHERE RP.code = FP.projectCode and FP.budgetLine = B.budgetLine
GROUP BY RP.code ;

SELECT L.labId, EM.category, count(serialNo) as numberOfEquipmentUnit, avg(EU.purchaseCost) as average_purchase_cost
FROM EquipmentUnit EU, Laboratory L, EquipmentModel EM
WHERE EU.labId = L.labId and EU.modelId = EM.modelId
GROUP BY L.labId, EM.category;

SELECT suppId, count(DISTINCT consId) as number_of_consumable
FROM Supplies S
GROUP BY suppId;

SELECT labId, consId, min(unitPrice) AS lowest_unit_price_negotiated
FROM Supplies S
GROUP BY labId, consId;

SELECT C.resId, CONCAT(firstName, ' ', lastName) as Reserver_fullName, sum(quantityUsed) as TotalQuantity
FROM Consumes C, Reservation R, Person P
WHERE C.resId = R.resId and R.madeByPid = P.pid 
GROUP BY C.resId;

-- E. Set Operations and Nested Queries

SELECT P.pid, CONCAT(P.firstName, ' ', P.lastName) AS fullName
FROM Person P
WHERE P.pid IN (
    SELECT supervisorPid FROM Laboratory
    INTERSECT
    SELECT managerPid FROM Budget
);


SELECT P.pid
FROM Person P
WHERE P.pid NOT IN ( SELECT madeByPid FROM Reservation );

SELECT EU.serialNo
FROM EquipmentUnit EU
WHERE NOT EXISTS (SELECT R.serialNo FROM Reserves R WHERE EU.serialNo = R.serialNo );

SELECT EU.serialNo
FROM EquipmentUnit EU
WHERE EU.purchaseCost >= ALL (SELECT EU1.purchaseCost FROM EquipmentUnit EU1 );


-- F. Division Queries 

SELECT M.modelId, P.pid
FROM EquipmentModel M, Person P
WHERE EXISTS (SELECT * FROM Requires Q WHERE Q.modelId = M.modelId)
  AND NOT EXISTS (
        SELECT * FROM Requires Q
        WHERE Q.modelId = M.modelId
          AND NOT EXISTS (
                SELECT * FROM Holds H
                WHERE H.pid = P.pid AND H.certCode = Q.certCode))
ORDER BY modelId, pid;

*/


