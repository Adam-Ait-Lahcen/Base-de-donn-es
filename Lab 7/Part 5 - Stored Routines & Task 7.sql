-- Part 5 | Stored routines and the schema-change experiment
-- 1/ FUNCTION TO RETURN AVAILABLE UNITS
DELIMITER //

CREATE FUNCTION availableUnits(mId INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total INT;

    SELECT COUNT(*)
    INTO total
    FROM EquipmentUnit E
    WHERE E.modelId = mId
      AND E.status = 'InService';

    RETURN total;
END //

DELIMITER ;

-- demonstration
SELECT commercialName,
       availableUnits(modelId) AS availableUnits
FROM EquipmentModel;
-- 2/ procedure to restock

DELIMITER //
CREATE PROCEDURE RestockLab(IN labId INT, IN consId INT, IN qty DECIMAL(12,2), OUT newQuantity DECIMAL(12,2))
BEGIN
    IF qty <= 0
    THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantity must be positive';
    END IF;
    IF NOT EXISTS(
        SELECT 1
        FROM Stocks S
        WHERE S.labId = labId AND S.consId = consId
    )
    THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_Text = 'There is no stock occurrence for the given labId and consId pair';
    END IF;
    UPDATE Stocks S
    SET S.quantityOnHand = S.quantityOnHand + qty, S.lastRestockDate = NOW()
    WHERE S.labId = labId AND S.consId = consId;
    SELECT quantityOnHand
    INTO newQuantity
    FROM Stocks S
    WHERE S.labId = labId AND S.consId = consId;
END //
DELIMITER ;
-- Task 7 | Run the following stages separately and keep the Python output.
-- First capture the baseline, using the original view and a known stock state.
-- 7a. Rename the column, then run the unchanged program to observe the view error.
ALTER TABLE Consumable RENAME COLUMN name TO designation;
-- 7b. Preserve the view's public columns. Run Python again before continuing.
CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT S.labId, L.name as LabName, S.consId, C.designation as ConsumableName, C.unitOfMeasure, S.quantityOnHand, C.reorderThreshold, S.technicalPid, S.monitoringSince  as MonitoringStartDate,
IF(S.quantityOnHand <= C.reorderThreshold, 'LOW', 'OK') as stockLevel
FROM Stocks S
JOIN Laboratory L ON S.labId = L.labId
JOIN Consumable C ON S.consId = C.consId;
-- 7d. Restore the column. Then rerun the original Part 2 view definition
-- with CREATE OR REPLACE VIEW and C.name AS ConsumableName.
ALTER TABLE Consumable RENAME COLUMN designation TO name;

CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT S.labId, L.name AS LabName, S.consId, C.name AS ConsumableName,
       C.unitOfMeasure, S.quantityOnHand, C.reorderThreshold, S.technicalPid,
       S.monitoringSince AS MonitoringStartDate,
       IF(S.quantityOnHand <= C.reorderThreshold, 'LOW', 'OK') AS stockLevel
FROM Stocks S
JOIN Laboratory L ON L.labId = S.labId
JOIN Consumable C ON C.consId = S.consId;
