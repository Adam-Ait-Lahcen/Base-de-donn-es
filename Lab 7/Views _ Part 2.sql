
                                       -- Part 2: Views :

-- 1. UpcomingApprovedReservationsByLab :

CREATE VIEW UpcomingApprovedReservationsByLab AS 
SELECT EU.labId, L.name AS labName, DATE(R.plannedStart) AS ReservationDate, count(distinct RS.resId) as approved_reservations
FROM  Reserves RS 
JOIN Reservation R ON R.resId = RS.resId
JOIN EquipmentUnit EU ON  RS.serialNo = EU.serialNo
JOIN Laboratory L ON EU.labId = L.labId 
WHERE R.status = 'Approved'  and R.plannedStart >= CURRENT_DATE() and R.plannedStart < CURRENT_DATE() + INTERVAL 14 DAY
GROUP BY EU.labId, L.name, DATE(R.plannedStart);

SELECT * FROM UpcomingApprovedReservationsByLab;

-- Explanation : 
-- This view encapsulates the joins accross Reserves, Reservation, EquipmentUnit and Laboratory with the conditions on the reservation's status and the planned start. 
-- In addition, it encapsulates the aggregation used on the number of distinct approved reservations.
 
 -- 2. EquipmentInventoryByLab
 
CREATE VIEW EquipmentInventoryByLab AS
SELECT EU.labId, L.name as labName, EU.modelId, EM.commercialName, EM.category, Count(EU.serialNo) AS TotalUnits,
(SELECT COUNT(*) FROM EquipmentUnit E1 WHERE E1.labId = EU.labId AND E1.modelId = EU.modelId AND E1.status = 'InService') AS UnitsInService,
(SELECT COUNT(*) FROM EquipmentUnit E2 WHERE E2.labId = EU.labId AND E2.modelId = EU.modelId AND E2.status = 'UnderMaintenance') AS UnitsUnderMaintenance
FROM EquipmentUnit EU 
JOIN EquipmentModel EM ON EU.modelId = EM.modelId
JOIN Laboratory L ON EU.labId = L.labId
GROUP BY EU.labId, L.name, EU.modelId, EM.commercialName, EM.category;

SELECT * FROM EquipmentInventoryByLab
WHERE TotalUnits = 1; 
 
-- Explanation : 
-- This view encapsulates the joins accross EquipmentUnit, EquipmentModel and Laboratory and three uses of count as an aggregate function.
 
 
 -- 3. PersonReservationSummary
 
CREATE VIEW PersonReservationSummary AS
SELECT P.pid, P.firstName, P.lastName , count(resId) as numberOfReservation, 
(SELECT COUNT(R1.resId) FROM Reservation R1 WHERE R1.madeByPid = R.madeByPid and R1.status = 'Approved') AS NumberOfApprovedReservation,
(SELECT COUNT(R2.resId) FROM Reservation R2 WHERE R2.madeByPid = R.madeByPid and R2.status = 'Pending') AS NumberOfPendingReservation,
(SELECT COUNT(R3.resId) FROM Reservation R3 WHERE R3.madeByPid = R.madeByPid and R3.status = 'Cancelled') AS NumberOfCancelledReservation
FROM Reservation R RIGHT OUTER JOIN Person P ON R.madeByPid = P.pid
GROUP BY P.pid, P.firstName, P.lastName;

SELECT * FROM  PersonReservationSummary
WHERE numberOfReservation = 0;

-- Explanation : 
-- The view encapsulates the outer join between Person and Reservation and, for each person, the total number of reservations they made plus the numbers that are approved, pending and cancelled


-- 4. ProjectReservationSummary :

CREATE VIEW ProjectReservationSummary AS
SELECT PR.code, PR.title, PR.status, count(R.resId) as TotalReservation, 
(SELECT COUNT(*) FROM Reservation R1 WHERE R1.projectCode = PR.code and R1.status = 'approved' ) as NumberOfApprovedReservation,
(SELECT MIN(R2.plannedStart) FROM Reservation R2 WHERE R2.projectCode = PR.code AND R2.status = 'Approved' AND R2.plannedStart >= '2026-11-14 00:00:00') AS NextApprovedReservation
FROM ResearchProject PR
LEFT JOIN Reservation R ON PR.code = R.projectCode 
GROUP BY PR.code, PR.title, PR.status;

SELECT *
FROM ProjectReservationSummary
WHERE NumberOfApprovedReservation = 0;

-- Explanation : 
-- The view encapsulates the join of ResearchProject and Reservation with two aggregate functions to find the number of approved reservations and to find the next approved reservation if it exists, per research project.

-- 5. LaboratoryStockSummary

CREATE VIEW LaboratoryStockSummary AS
SELECT S.labId, L.name as LabName, S.consId, C.name as ConsumableName, C.unitOfMeasure, S.quantityOnHand, C.reorderThreshold, S.technicalPid, S.monitoringSince  as MonitoringStartDate,
IF(S.quantityOnHand <= C.reorderThreshold, 'Low', 'Ok') as stockLevel
FROM Stocks S
JOIN Laboratory L ON S.labId = L.labId
JOIN Consumable C ON S.consId = C.consId;

SELECT * FROM LaboratoryStockSummary
WHERE stockLevel = 'Low';

-- Explanation : 
-- The view encapsulates the join of Stocks, Laboratory and Consumable and adds a derived stockLevel flag.
