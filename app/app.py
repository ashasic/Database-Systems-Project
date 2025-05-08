from flask import Flask, render_template
import pymysql.cursors
import os
from dotenv import load_dotenv

app = Flask(__name__)
app.secret_key = '12345'

def get_db():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='12345',
        db='grocery_db',
        cursorclass=pymysql.cursors.DictCursor
    )

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/orders')
def orders():
    """Query 1: List Orders with Customer Full Name and SaleAMT (JOIN)"""
    sql = """
      SELECT O.OrderID,
             CONCAT(C.FirstName,' ',C.LastName) AS CustomerName,
             O.SaleAMT
      FROM Orders O
      JOIN Customers C ON O.CustomerNum = C.CustomerNum
      ORDER BY O.OrderID;
    """
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()
    conn.close()
    return render_template('results.html',
                           title="Orders ➞ Customer & Sale Amount",
                           description="Displays each order alongside the customer’s full name and the total sale amount.",
                           columns=["OrderID","CustomerName","SaleAMT"],
                           rows=rows)


@app.route('/store-sales')
def store_sales():
    """Query 2: Total SaleAMT for Each Store Location (JOIN + AGGREGATION)"""
    sql = """
      SELECT S.Location AS StoreLocation,
             SUM(O.SaleAMT) AS TotalSales
      FROM Orders O
      JOIN Store S ON O.Location = S.Location
      GROUP BY S.Location
      ORDER BY TotalSales DESC;
    """
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()
    conn.close()
    return render_template('results.html',
                           title="Store Sales Summary",
                           description="Aggregates total sales per store location.",
                           columns=["StoreLocation","TotalSales"],
                           rows=rows)


@app.route('/frequent-products')
def frequent_products():
    """Query 3: Products Ordered More Than Once (SUBQUERY)"""
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
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()
    conn.close()
    return render_template('results.html',
                           title="Frequently Ordered Products",
                           description="Lists products that have been ordered more than once.",
                           columns=["ItemNum","ItemName"],
                           rows=rows)


if __name__ == '__main__':
    app.run(debug=True)
