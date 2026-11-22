-- Part 4 | Business rules on the Lab 6 schema


-- 1 Participation rules:
-- Administrative staff cannot participate in research projects
DELIMITER //
CREATE TRIGGER AdminProjectParticipationInsert
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN 
	IF EXISTS(
		SELECT 1
        FROM Administrative A
        WHERE A.pid = NEW.pid)
	THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrative staff cannot participate in research projects';
	END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER AdminProjectParticipationUpdate
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN 
	IF EXISTS(
		SELECT 1
        FROM Administrative A
        WHERE A.pid = NEW.pid)
	THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrative staff cannot participate in research projects';
	END IF;
END//
DELIMITER ;

-- Only academics may take the PI or Co-PI role.

DELIMITER //
CREATE TRIGGER AcademicRoleInsert
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
    IF (NEW.role = "PI" OR NEW.role = "Co-PI") 
    AND NOT EXISTS (
		SELECT 1
        FROM Academic A
        WHERE A.pid = NEW.pid
    )
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PI and Co-PI must belong to academic';
	END IF;
END // 
DELIMITER ;

DELIMITER //
CREATE TRIGGER AcademicRoleUpdate
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
    IF (NEW.role = "PI" OR NEW.role = "Co-PI") 
    AND NOT EXISTS (
		SELECT 1
        FROM Academic A
        WHERE A.pid = NEW.pid
    )
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An Academic must have a role of either PI or Co-PI';
	END IF;
END // 
DELIMITER ;

-- Each research project has at most one 'PI'
DELIMITER //
CREATE TRIGGER AtMostOnePIInsert
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
	IF NEW.role = "PI" AND EXISTS(
		SELECT 1
        FROM Participates P
        WHERE P.role = "PI" AND NEW.projectCode = P.projectCode)
	THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "Each research project has at most one PI";
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER AtMostOnePIUpdate
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
	IF NEW.role = "PI" AND EXISTS(
		SELECT 1
        FROM Participates P
        WHERE P.role = "PI" 
			AND NEW.projectCode = P.projectCode
            AND NOT (P.pid = OLD.pid
					AND P.projectCode = OLD.projectCode)
        )
	THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "Each research project has at most one PI";
    END IF;
END //
DELIMITER ;

-- Each research project has at most one 'Co-PI'
DELIMITER //
CREATE TRIGGER AtMostOneCoPIInsert
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
	IF NEW.role = "Co-PI" AND EXISTS(
		SELECT 1
        FROM Participates P
        WHERE P.role = "Co-PI" AND NEW.projectCode = P.projectCode)
	THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "Each research project has at most one Co-PI";
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER AtMostOneCoPIUpdate
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
	IF NEW.role = "Co-PI" AND EXISTS(
		SELECT pid
        FROM Participates P
        WHERE P.role = "Co-PI" 
			AND NEW.projectCode = P.projectCode
            AND NOT(P.pid = OLD.pid
					AND P.projectCode = OLD.projectCode)
        )
	THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "Each research project has at most one Co-PI";
    END IF;
END //
DELIMITER ;

-- 2 Preventing double booking

-- a/ Adding an equipment unit to a reservation
DELIMITER //
CREATE TRIGGER EquipmentUnitReservationInsert
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
	DECLARE n_status VARCHAR(50);
    DECLARE n_start TIMESTAMP;
    DECLARE n_end TIMESTAMP;
    -- getting the info about the reservation
    SELECT status, plannedStart, plannedEnd
    INTO n_status, n_start, n_end
    FROM Reservation R
    WHERE R.resId = NEW.resId;
    -- trigger condition
    IF n_status = 'Approved'
		AND EXISTS(
			SELECT 1
            FROM Reservation R
            JOIN Reserves R1 ON R.resId = R1.resId
            WHERE R.resId != NEW.resId
				AND R.status = 'Approved'
                AND R1.serialNo = NEW.serialNo
                AND R.plannedStart < n_end
                AND R.plannedEnd > n_start)
	THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Equipment unit is already reserved";
	END IF;
END // 
DELIMITER ;
	
-- 2b. Recheck all assigned units when a reservation is approved or rescheduled.

DELIMITER //
CREATE TRIGGER EquipmentUnitReservationUpdate
BEFORE UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved'
       AND EXISTS (
           SELECT 1
           FROM Reserves R1
           JOIN Reserves R2
             ON R1.serialNo = R2.serialNo
           JOIN Reservation R
             ON R.resId = R2.resId

           WHERE R1.resId = NEW.resId
             AND R.resId != NEW.resId
             AND R.status = 'Approved'
             AND R.plannedStart < NEW.plannedEnd
             AND R.plannedEnd > NEW.plannedStart)
	THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Equipment unit is already reserved";
	END IF;
END // 
DELIMITER ;

-- 3 enforcing certification eligibility for equipment reservation

-- checking the insert

DELIMITER //

CREATE TRIGGER EquipmentReservationCertificationEligibility
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
	DECLARE reserver INT;
	DECLARE _plannedstart TIMESTAMP;
	DECLARE model INT;

	-- getting the person who made the reservation and its details
	SELECT madeByPid, plannedStart
	INTO reserver, _plannedstart
	FROM Reservation R
	WHERE R.resId = NEW.resId;

	-- getting the equipment model Id
	SELECT modelId 
	INTO model
	FROM EquipmentUnit E
	WHERE E.serialNo = NEW.serialNo;
	-- checking if the person holds the certifs needed
	IF EXISTS(
		SELECT 1 
		FROM Requires R
		WHERE R.modelId = model 
			AND NOT EXISTS(
				SELECT 1 
				FROM Holds H
				WHERE H.pid = reserver AND H.certCode = R.certCode AND H.expirationDate >= DATE(_plannedstart)
				)
		)
	THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Reserver does not have a valid certification for the requested equipment units";
	END IF;
							
END //
DELIMITER ;

-- 4 Enforce consumable stock consistency

-- a/ Validate Consumption

DELIMITER //
CREATE TRIGGER ValidateConsumption
BEFORE INSERT ON Consumes
FOR EACH ROW
BEGIN
	DECLARE onHandQuantity DECIMAL(12,2);
    IF NOT EXISTS (
        SELECT 1
        FROM Stocks S
        WHERE S.labId = NEW.labId
          AND S.consId = NEW.consId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock occurrence does not exist';
    END IF;
    -- getting the quantity on hand
    SELECT quantityOnHand 
    INTO onHandQuantity
    FROM Stocks S
    WHERE NEW.labId = S.labId AND NEW.consId = S.consId;
	IF NEW.quantityUsed <= 0
		OR NOT EXISTS(
			SELECT 1
            FROM Stocks S
            WHERE NEW.labId = S.labId AND NEW.consId = S.consId)
		OR onHandQuantity < NEW.quantityUsed
	THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock or invalid quantity input';
	END IF;
END //
DELIMITER ;

-- b/ update stock

DELIMITER //
CREATE TRIGGER UpdateStockConsumed
AFTER INSERT ON Consumes
FOR EACH ROW
BEGIN
    UPDATE Stocks S
    SET S.quantityOnHand = S.quantityOnHand - NEW.quantityUsed
    WHERE NEW.labId = S.labId AND NEW.consId = S.consId;
END //
DELIMITER ;

-- 5 Synchronize maintenance and equipment status

-- a/ Maintenance starts

DELIMITER //
CREATE TRIGGER MaintenanceStart 
AFTER INSERT ON Maintenance
FOR EACH ROW
BEGIN
	UPDATE EquipmentUnit E
    SET E.status = 'UnderMaintenance'
    WHERE E.serialNo = NEW.serialNo;
END//
DELIMITER ;

-- b/ Maintenance is resolved

DELIMITER //
CREATE TRIGGER MaintenanceResolved
AFTER UPDATE ON Maintenance
FOR EACH ROW
BEGIN
	IF NEW.outcome = 'Resolved' AND OLD.outcome <> 'Resolved'
    THEN
		UPDATE EquipmentUnit E
		SET E.status = 'InService'
		WHERE E.serialNo = NEW.serialNo;
	END IF;
END //
DELIMITER ;

-- 6 Enforce People-hierarchy rules

-- a/  Disjointness of Student and Employee
-- on student
DELIMITER //
CREATE TRIGGER StudentNotEmployee
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
	IF EXISTS(
		SELECT 1
        FROM Employee E
        WHERE E.pid = NEW.pid)
	THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An employee cannot be a student';
	END IF;
END //
DELIMITER ;
-- on employee
DELIMITER //
CREATE TRIGGER EmployeeNotStudent
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
	IF EXISTS(
		SELECT 1
        FROM Student S
        WHERE S.pid = NEW.pid)
	THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A student cannot be an employee';
	END IF;
END //
DELIMITER ;

-- b/ Reporting to the Dean 

-- on faculty
DELIMITER //
CREATE TRIGGER FacultyReportingInsert
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
	DECLARE supId INT;
    DECLARE pos VARCHAR(100);
    -- getting the suprevisor Id
    SELECT supervisorPid
    INTO supId
    FROM Employee E
    WHERE E.pid = NEW.pid;
    -- getting the position of the suprevisor
    SELECT position
    INTO pos
    FROM Employee E
    WHERE E.pid = supId;
    -- checking the condition
    IF pos is Null or pos != 'dean'
    THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A faculty member must be supervised by a dean';
	END IF;
END // 
DELIMITER ;
-- On insertion into Administrative
DELIMITER //
CREATE TRIGGER AdministrativeReportingInsert
BEFORE INSERT ON Administrative
FOR EACH ROW
BEGIN
	DECLARE supId INT;
    DECLARE pos VARCHAR(100);
    -- getting the suprevisor Id
    SELECT supervisorPid
    INTO supId
    FROM Employee E
    WHERE E.pid = NEW.pid;
    -- getting the position of the suprevisor
    SELECT position
    INTO pos
    FROM Employee E
    WHERE E.pid = supId;
    -- checking the condition
    IF pos is Null or pos != 'dean'
    THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An administrative member must be supervised by a dean';
	END IF;
END // 
DELIMITER ;

-- Update on Employee
DELIMITER //
CREATE TRIGGER EmployeeSupUpdate
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
	DECLARE new_pos VARCHAR(100);
    -- getting the position of the new suprevisor
    SELECT position
    INTO new_pos
    FROM Employee E
    WHERE E.pid = NEW.supervisorPid;
    -- checking the condition
    IF (new_pos is null or new_pos != 'dean')
		AND(EXISTS(
					SELECT 1
                    FROM Faculty F
                    WHERE F.pid = NEW.pid)
			OR EXISTS(
					SELECT 1
                    FROM Administrative A
                    WHERE A.pid = NEW.pid))
	THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A faculty or an administrative must be supervised by a dean';
	END IF;
END // 
DELIMITER ;

-- c/ The Dean has no supervisor

-- on insert
DELIMITER //
CREATE TRIGGER DeanSupervisorInsert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
	IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL
    THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A dean must report to no one';
	END IF;
END //
DELIMITER ;

-- on update
DELIMITER //
CREATE TRIGGER DeanSupervisorUpdate
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
	IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL
    THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A dean must report to no one';
	END IF;
END //
DELIMITER ;

