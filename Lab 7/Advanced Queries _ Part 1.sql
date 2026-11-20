                                       
                                       -- Part 1: Advanced Queries :

-- 1/
SELECT CONCAT(P1.firstName, ' ', P1.lastName) AS Employee_fullName, CONCAT(P2.firstName, ' ', P2.lastName) AS Supervisor_fullName
FROM Employee E
JOIN Person P1 ON E.pid = P1.pid
LEFT JOIN Person P2 ON E.supervisorPid = P2.pid;

-- 2/
SELECT R.resId , CONCAT(P.firstName, ' ', P.lastName) AS Approver_fullName
FROM Reservation R LEFT JOIN Person P ON R.approverPid = P.pid;

-- 3/
SELECT E1.modelId, E1.serialNo AS Unit1, E2.serialNo AS Unit2
FROM EquipmentUnit E1 JOIN EquipmentUnit E2 ON E1.modelId = E2.modelId and E1.labId <> E2.labId and E1.serialNo < E2.serialNo;

-- 4/
SELECT EM.commercialName, Count(EU.serialNo) as number_of_units
FROM EquipmentModel EM LEFT JOIN EquipmentUnit EU ON EM.modelId = EU.modelId
GROUP BY EM.modelId;

-- 5/
SELECT EU.labId, EU.serialNo
FROM EquipmentUnit EU
WHERE EU.purchaseCost >= (SELECT Max(EU1.purchaseCost) FROM EquipmentUnit EU1  WHERE EU.labId = EU1.labId );

-- 6/
SELECT S.labId, sum(quantityOnHand) AS total_quantity
FROM Stocks S
GROUP BY S.labId
HAVING sum(quantityOnHand) > (SELECT AVG(A.total) FROM (SELECT sum(S1.quantityOnHand) as total from Stocks S1 GROUP BY labId) AS A);


-- 7/
SELECT C.consId
FROM Consumable C
WHERE NOT EXISTS (
SELECT L.labId
FROM Laboratory L
WHERE NOT EXISTS ( 
SELECT S.labId
FROM Stocks S
WHERE S.labId = L.labId and S.consId = C.consId
));
