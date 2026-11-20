                                       -- Part 3: CHECK Constraints : 

-- 1/ 

ALTER TABLE Student ADD constraint student_program CHECK (program IN ('BSc','BEng','MSc','PhD'));
UPDATE Student SET program = 'Bachelor' WHERE pid = 9;

ALTER TABLE Employee ADD CONSTRAINT employee_position CHECK (position IN ('dean','faculty','scientist','postdoc','secretary','technician','lab manager','accountant','engineer'));
UPDATE Employee SET position = 'director' WHERE pid = 5;

ALTER TABLE ResearchProject ADD CONSTRAINT project_status CHECK (status IN ('Proposed','Active','Suspended','Completed','Cancelled'));
UPDATE ResearchProject SET status = 'Rejected' WHERE code = 'P1';

ALTER TABLE Participates ADD CONSTRAINT participation_role CHECK (role IN ('PI','Co-PI','Collaborator'));
UPDATE Participates SET role = 'Observer' WHERE pid = 2 AND projectCode = 'P1';

ALTER TABLE EquipmentUnit ADD CONSTRAINT equipment_status CHECK (status IN ('InService','UnderMaintenance','OutOfService','Retired'));
UPDATE EquipmentUnit SET status = 'Lost' WHERE serialNo = 'U2';

ALTER TABLE Reservation ADD CONSTRAINT reservation_status CHECK (status IN ('Pending','Approved','Rejected','Cancelled','Completed'));
UPDATE Reservation SET status = 'OnHold' WHERE resId = 2;

ALTER TABLE Maintenance ADD CONSTRAINT maintenance_type CHECK (type IN ('Preventive','Corrective')), ADD CONSTRAINT maintenance_outcome CHECK (outcome IN ('Resolved','FollowUpRequired'));
UPDATE Maintenance SET type = 'Upgrade' WHERE serialNo = 'U1';
UPDATE Maintenance SET outcome = 'Pending' WHERE serialNo = 'U1';

ALTER TABLE CalibrationRecord ADD CONSTRAINT calibration_result CHECK (result IN ('Pass','Fail','Adjusted'));
UPDATE CalibrationRecord SET result = 'Unknown' WHERE serialNo = 'U5' AND calibDate = '2026-06-15';


-- 2/

ALTER TABLE Budget ADD CONSTRAINT budget_granted CHECK ( amountGranted >= 0), 
ADD CONSTRAINT budget_disbursed CHECK ( amountDisbursed >= 0);
UPDATE Budget SET amountGranted = -1 WHERE budgetLine = 'B1';
UPDATE Budget SET amountDisbursed = -1 WHERE budgetLine = 'B1';

ALTER TABLE EquipmentUnit ADD CONSTRAINT unit_purchase_cost CHECK (purchaseCost >= 0);
UPDATE EquipmentUnit SET purchaseCost = -1 WHERE serialNo = 'U1';

ALTER TABLE Maintenance ADD CONSTRAINT maintenance_cost CHECK (cost >= 0);
UPDATE Maintenance SET cost = -50 WHERE serialNo = 'U6';

ALTER TABLE Supplies ADD CONSTRAINT supplies_price CHECK (unitPrice >= 0);
UPDATE Supplies SET unitPrice = -1 WHERE suppId = 1 AND consId = 1 AND labId = 1;

ALTER TABLE Stocks ADD CONSTRAINT stocks_quantity CHECK (quantityOnHand >= 0);
UPDATE Stocks SET quantityOnHand = -5 WHERE labId = 1 AND consId = 1;

ALTER TABLE Consumes ADD CONSTRAINT consumes_quantity CHECK (quantityUsed > 0);
UPDATE Consumable SET reorderThreshold = -1 WHERE consId = 1;

ALTER TABLE Consumable ADD CONSTRAINT consumable_reorder_threshold CHECk (reorderThreshold >= 0);
UPDATE Consumes SET quantityUsed = 0 WHERE resId = 1 AND labId = 1 AND consId = 1;

-- 3/ 

ALTER TABLE Reservation ADD CONSTRAINT reservation_dates CHECK ( plannedEnd > plannedStart );
UPDATE Reservation SET plannedEnd = plannedStart WHERE resId = 1;

ALTER TABLE Maintenance ADD CONSTRAINT maintenance_dates CHECK ( endTS >= startTS ) ;
UPDATE Maintenance SET endTS = '2026-09-30 17:00:00' WHERE serialNo = 'U6'; 

-- A short paragraph : which desired RLMS rules can a CHECK constraint not express, and why?
/* 
    A CHECK constraint is evaluated on a single row of a single table, so it can compare the columns of the row being inserted or updated
  against constants or against each other, nevertheless, it fails with a rule that needs information from other rows of the same table or
  informations from another table.
    For instance, in the PR3 requirement, in Participates(pid, projectCode, role), a row (8, 'P1', 'Collaborator') can only be judged by
  looking at other rows of the same project code to see who is the PI since each project must have one PI. Therefore, A CHECK cannot query
  other rows or other tables, so it has nothing to compare against.
*/