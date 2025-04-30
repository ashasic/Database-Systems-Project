from flask import render_template
from .config import get_db_connection
from pymysql.cursors import DictCursor

def init_app(app):

    @app.route('/')
    def index():
        return render_template('index.html')

    @app.route('/orders')
    def orders():
        """Query 1: Orders with Customer & SaleAMT (JOIN)"""
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
                               rows=rows)

    @app.route('/store-sales')
    def store_sales():
        """Query 2: Total sales per store (JOIN + AGGREGATION)"""
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
        """Query 3: Products ordered more than once (SUBQUERY)"""
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