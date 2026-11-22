-- Valid: Academic person as PI
INSERT INTO Participates (pid, projectCode, role)
VALUES (2, 'P-NANO-04', 'PI');

-- Invalid: Administrative staff
INSERT INTO Participates (pid, projectCode, role)
VALUES (4, 'P-NANO-04', 'Researcher');

-- Invalid: Student/non-Academic as PI
INSERT INTO Participates (pid, projectCode, role)
VALUES (7, 'P-NANO-04', 'PI');

-- Invalid: Second PI in the same project
INSERT INTO Participates (pid, projectCode, role)
VALUES (3, 'P-NANO-04', 'PI');

-- Invalid: Second Co-PI
INSERT INTO Participates (pid, projectCode, role)
VALUES (2, 'P-NANO-04', 'Co-PI');

-- Invalid: overlapping approved reservation
INSERT INTO Reservation
VALUES (20, NOW(), '2026-11-03 12:00:00',
        '2026-11-03 18:00:00', 'Trigger test',
        'Approved', 2, 'P-THR-02', 3);

INSERT INTO Reserves VALUES (20, 'FLK-1524-002');

-- Valid: adjacent interval
INSERT INTO Reservation
VALUES (21, NOW(), '2026-11-03 16:00:00',
        '2026-11-03 18:00:00', 'Trigger test',
        'Approved', 2, 'P-THR-02', 3);

INSERT INTO Reserves VALUES (21, 'FLK-1524-002');

-- Invalid: missing CERT-LASER
INSERT INTO Reserves VALUES (3, 'OLY-BX53-002');

-- Valid: model 3 requires no certifications
INSERT INTO Reserves VALUES (3, 'FLK-1524-003');

-- Valid: consume 5
INSERT INTO Consumes VALUES (2, 2, 4, 5.00);

-- Invalid: zero quantity
INSERT INTO Consumes VALUES (2, 2, 4, 0);

-- Invalid: insufficient stock
INSERT INTO Consumes VALUES (2, 2, 4, 1000);

-- Invalid: nonexistent stock occurrence
INSERT INTO Consumes VALUES (2, 3, 4, 2);

SELECT *
FROM Stocks
WHERE labId = 2 AND consId = 4;

-- Insert maintenance
INSERT INTO Maintenance
(serialNo, startTS, endTS, type, description, cost, outcome, technicalPid)
VALUES
('FLK-1524-003', NOW(), NULL, 'Corrective',
 'Trigger testing', 100, 'In Progress', 5);

-- Check status
SELECT serialNo, status
FROM EquipmentUnit
WHERE serialNo = 'FLK-1524-003';

-- Resolve maintenance
UPDATE Maintenance
SET outcome = 'Resolved'
WHERE serialNo = 'FLK-1524-003'
AND description = 'Trigger testing';

-- Check status again
SELECT serialNo, status
FROM EquipmentUnit
WHERE serialNo = 'FLK-1524-003';

-- Invalid: person 10 is already a Student
INSERT INTO Employee
VALUES (10, '+212600000010', 'Office 10', 'Technician', 1);

-- Create a new person
INSERT INTO Person
VALUES (11, 'Test', 'Person', 'test11@um6p.ma',
        'Technical Services', '2026-01-01', NULL);

-- Valid: person 11 becomes an Employee
INSERT INTO Employee
VALUES (11, '+212600000011', 'Office 11', 'Technician', 1);

-- Invalid: person 11 is already an Employee
INSERT INTO Student VALUES (11, 'MSc');

-- Invalid: employee 5 reports to person 2, not the Dean
INSERT INTO Faculty VALUES (5);

-- Make employee 5 report to the Dean
UPDATE Employee
SET supervisorPid = 1
WHERE pid = 5;

-- Valid
INSERT INTO Faculty VALUES (5);

-- Invalid: Faculty employee cannot stop reporting to the Dean
UPDATE Employee
SET supervisorPid = 2
WHERE pid = 5;

-- Invalid: the Dean cannot have a supervisor
UPDATE Employee
SET supervisorPid = 2
WHERE pid = 1;

-- Part 5

SELECT commercialName,
       availableUnits(modelId) AS availableUnits
FROM EquipmentModel;

CALL RestockLab(1, 2, 5, @newQuantity);
SELECT @newQuantity;

CALL RestockLab(1, 2, -5, @newQuantity);

CALL RestockLab(999, 999, 10, @newQuantity);

SELECT E.serialNo, M.commercialName
FROM Laboratory L
JOIN EquipmentUnit E ON E.labId = L.labId
JOIN EquipmentModel M ON M.modelId = E.modelId
WHERE L.name = 'Chemistry Laboratory'
AND E.status = 'InService';

SELECT *
FROM LaboratoryStockSummary
WHERE stockLevel = 'Low';

