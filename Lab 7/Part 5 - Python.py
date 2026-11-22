import mysql.connector as c
connection = c.connect(
    host = 'localhost',
    user = 'root',
    password = '67896789@',
    database = 'lab7'
)
cursor = connection.cursor()

#question2
def test_restock(lab_id, cons_id, qty):
    print(f"--- Testing RestockLab(labId={lab_id}, consId={cons_id}, qty={qty}) ---")
    try:
        # Pass 0 as a placeholder for the OUT parameter (newQuantity)
        args = [lab_id, cons_id, qty, 0]
        result_args = cursor.callproc('RestockLab', args)
        
        # Commit the UPDATE to the database
        connection.commit()
        
        # The OUT parameter is at index 3 of the returned tuple
        new_qty = result_args[3]
        print(f"SUCCESS! New quantity on hand: {new_qty}\n")
        
    except c.Error as err:
        # This catches your SIGNAL SQLSTATE '45000' errors
        print(f"REJECTED by Database: {err.msg}\n")

# --- DEMONSTRATIONS ---
def test():
    # 1. Successful CALL (Replace 1, 101 with a valid pair from your Stocks table)
    test_restock(lab_id=1, cons_id=1, qty=25)

    # 2. Rejection 1: Non-positive quantity
    test_restock(lab_id=1, cons_id=101, qty=-5)

    # 3. Rejection 2: Non-existent (labId, consId) pair
    test_restock(lab_id=999, cons_id=999, qty=10)
#question3
def getInServiceEquipmentUnits(lab_name: str) -> None:
    query = (
        'SELECT E.serialNo, M.commercialName '
        'FROM Laboratory L '
        'JOIN EquipmentUnit E ON E.labId = L.labId '
        'JOIN EquipmentModel M ON M.modelId = E.modelId '
        'WHERE L.name = %s AND E.status = "InService"'
    )
    cursor.execute(query, (lab_name,))
    print("Available equipment units: ")
    for tup in cursor.fetchall():
        print(f"Commercial Name: {tup[1]}Serial Number: {tup[0]}")

#question4
def getLowStocks()->None:
    query = (
        'SELECT * '
        'FROM LaboratoryStockSummary L '
        'WHERE L.stockLevel = "Low" '
    )
    cursor.execute(query)
    for tup in cursor.fetchall():
        print(tup)
#question5
#the same function used to demonstrate correctness in question 2
#question6

def test_equipment_reservation(
    res_id, status, start, end, serial_no
):
    print(
        f"--- Testing Reservation {res_id} | "
        f"{status} | {serial_no} | {start} to {end} ---"
    )

    try:
        # First create the reservation itself
        cursor.execute("""
            INSERT INTO Reservation (
                resId, submissionTS, plannedStart, plannedEnd,
                purpose, status, madeByPid, projectCode, approverPid
            )
            VALUES (%s, NOW(), %s, %s, %s, %s, %s, %s, %s)
        """, (
            res_id,
            start,
            end,
            "Trigger testing",
            status,
            8,
            "P1",
            3 if status == "Approved" else None
        ))

        # Then assign the equipment.
        # This is where your trigger executes.
        cursor.execute("""
            INSERT INTO Reserves (resId, serialNo)
            VALUES (%s, %s)
        """, (res_id, serial_no))

        connection.commit()
        print("SUCCESS! Equipment reservation accepted.\n")

    except c.Error as err:
        connection.rollback()
        print(f"REJECTED by Database: {err.msg}\n")



test()
getInServiceEquipmentUnits("Physics Laboratory")
getLowStocks()
# Task 6: person 8 holds C1, but unit U3 requires both C1 and C2.
# Reservation ID 16 must be free before running this test.
test_equipment_reservation(
    16, "Pending",
    "2026-11-04 10:00:00",
    "2026-11-04 12:00:00",
    "U3",
)

cursor.close()
connection.close()




#question7
#a/ The program shows an error, because the view LaboratoryStockSummary uses the old column name
#b/ the SQL statement used: we replace the view with one with the same definition but uses the new name
# so instead of C.name we use C.designation so CREATE OR REPLACE VIEW LaboratoryStockSummary AS "same definition
# but with the new change"

#The rows printed are identical to those printed before the renaming
#c/ The property is logical data independence
# No. The Task 3 query directly references Laboratory.name.
# Renaming that column would make the query invalid because it depends directly on the original schema.




