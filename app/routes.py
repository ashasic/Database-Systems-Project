from flask import flash, redirect, render_template, request, url_for
from .config import get_db_connection
from pymysql.cursors import DictCursor

def init_app(app):

    @app.route('/')
    def index():
        return render_template('index.html')

    @app.route('/orders')
    def orders():
        sql = """
          SELECT O.OrderID,
                 CONCAT(C.FirstName,' ',C.LastName) AS CustomerName,
                 O.SaleAMT
          FROM Orders O
          JOIN Customers C ON O.CustomerNum = C.CustomerNum
          ORDER BY O.OrderID;
        """
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                cur.execute(sql)
                rows = cur.fetchall()
        finally:
            conn.close()

        return render_template('results.html',
                               title="Orders → Customer & SaleAMT",
                               description="Each order alongside the customer’s full name and the total sale amount.",
                               columns=["OrderID", "CustomerName", "SaleAMT"],
                               rows=rows,
                               centered=True)

    @app.route('/store-sales')
    def store_sales():
        sql = """
          SELECT S.Location AS StoreLocation,
                 SUM(O.SaleAMT) AS TotalSales
          FROM Orders O
          JOIN Store S ON O.Location = S.Location
          GROUP BY S.Location
          ORDER BY TotalSales DESC;
        """
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                cur.execute(sql)
                rows = cur.fetchall()
        finally:
            conn.close()

        return render_template('results.html',
                               title="Store Sales Summary",
                               description="Aggregated total sales per store location.",
                               columns=["StoreLocation", "TotalSales"],
                               rows=rows)

    @app.route('/frequent-products')
    def frequent_products():
        sql = """
          SELECT P.ItemNum, P.ItemName
          FROM Products P
          WHERE P.ItemNum IN (
            SELECT OD.ItemNum
            FROM OrderDetails OD
            GROUP BY OD.ItemNum
            HAVING COUNT(*) > 1
          );
        """
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                cur.execute(sql)
                rows = cur.fetchall()
        finally:
            conn.close()

        return render_template('results.html',
                               title="Frequently Ordered Products",
                               description="Products that have been ordered more than once.",
                               columns=["ItemNum", "ItemName"],
                               rows=rows)

    @app.route('/order', methods=['GET', 'POST'])
    def order():
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                if request.method == 'POST' and not request.args.get('order_id'):
                    customer_id = request.form['customer_id']
                    location = request.form['location']
                    cur.execute("INSERT INTO Orders (CustomerNum, DateSold, Location) VALUES (%s, NOW(), %s)",
                                (customer_id, location))
                    conn.commit()
                    new_order_id = cur.lastrowid
                    return redirect(url_for('order', order_id=new_order_id))

                cur.execute("SELECT CustomerNum, FirstName, LastName FROM Customers")
                customers = cur.fetchall()

                cur.execute("SELECT DISTINCT Location FROM Store")
                locations = [row['Location'] for row in cur.fetchall()]

                order_id = request.args.get('order_id', type=int)
                products, items, total = [], [], 0

                if order_id:
                    search = request.args.get('search', '').strip()
                    if search:
                        cur.execute("""
                            SELECT ItemNum, ItemName, PricePerUnit
                            FROM Products
                            WHERE ItemName LIKE %s
                            ORDER BY ItemName ASC
                        """, (f"%{search}%",))
                    else:
                        cur.execute("""
                            SELECT P.ItemNum, P.ItemName, P.PricePerUnit, COUNT(OD.ItemNum) AS TimesOrdered
                            FROM Products P
                            LEFT JOIN OrderDetails OD ON P.ItemNum = OD.ItemNum
                            GROUP BY P.ItemNum
                            ORDER BY TimesOrdered DESC
                            LIMIT 10
                        """)
                    products = cur.fetchall()

                    cur.execute("""
                        SELECT OD.ItemNum, P.ItemName, OD.Quantity, OD.PricePerUnit
                        FROM OrderDetails OD
                        JOIN Products P ON OD.ItemNum = P.ItemNum
                        WHERE OD.OrderID = %s
                    """, (order_id,))
                    items = cur.fetchall()

                    total = sum((item['Quantity'] or 0) * (item['PricePerUnit'] or 0) for item in items)
        finally:
            conn.close()

        return render_template('order_items.html', order_id=order_id, products=products, items=items, total=total, customers=customers, locations=locations)

    @app.route('/add_item/<int:order_id>', methods=['POST'])
    def add_item(order_id):
        item_num = request.form['item_num']
        quantity = int(request.form['quantity'])
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                cur.execute("SELECT PricePerUnit FROM Products WHERE ItemNum = %s", (item_num,))
                price_data = cur.fetchone()
                price = price_data['PricePerUnit'] if price_data else 0

                cur.execute("SELECT Quantity FROM OrderDetails WHERE OrderID = %s AND ItemNum = %s", (order_id, item_num))
                existing = cur.fetchone()

                if existing:
                    new_qty = existing['Quantity'] + quantity
                    cur.execute("""
                        UPDATE OrderDetails
                        SET Quantity = %s
                        WHERE OrderID = %s AND ItemNum = %s
                    """, (new_qty, order_id, item_num))
                else:
                    cur.execute("""
                        INSERT INTO OrderDetails (OrderID, ItemNum, Quantity, PricePerUnit)
                        VALUES (%s, %s, %s, %s)
                    """, (order_id, item_num, quantity, price))

                conn.commit()
        finally:
            conn.close()

        return redirect(url_for('order', order_id=order_id))

    @app.route('/remove_item/<int:order_id>', methods=['POST'])
    def remove_item(order_id):
        item_num = request.form['item_num']
        conn = get_db_connection()
        try:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM OrderDetails WHERE OrderID = %s AND ItemNum = %s", (order_id, item_num))
                conn.commit()
        finally:
            conn.close()
        return redirect(url_for('order', order_id=order_id))

    @app.route('/confirm_order/<int:order_id>', methods=['POST'])
    def confirm_order(order_id):
        conn = get_db_connection()
        try:
            with conn.cursor(DictCursor) as cur:
                cur.execute("""
                    SELECT SUM(Quantity * PricePerUnit) AS Total
                    FROM OrderDetails
                    WHERE OrderID = %s
                """, (order_id,))
                result = cur.fetchone()
                total = result['Total'] if result and result['Total'] else 0

                cur.execute("""
                    UPDATE Orders
                    SET SaleAMT = %s
                    WHERE OrderID = %s
                """, (total, order_id))

                conn.commit()
        finally:
            conn.close()

        return render_template('order_confirm.html', order_id=order_id, total=total)
    
    @app.route('/delete_order/<int:order_id>', methods=['POST'])
    def delete_order(order_id):
        conn = get_db_connection()
        try:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM OrderDetails WHERE OrderID = %s", (order_id,))
                cur.execute("DELETE FROM Orders WHERE OrderID = %s", (order_id,))
                conn.commit()
        finally:
            conn.close()
        return redirect(url_for('orders'))

