# Database-Systems-Project

Project Setup and Run Instructions

1. Install prerequisites  
Ensure you have a running MySQL server and Python 3.13.3 with pip.

2. Initialize the database  
Start MySQL workbench, connect to an instance then create a
schema called grocery_db. After connecting to the schema,
execute all the queries within deliverable5_ddl_dml.sql

OR 

run your setup script in one go:  
mysql -u root -p < deliverable5_ddl_dml.sql 
The script should create tables, views, triggers, sample data, etc.

3. Create and activate a Python virtual environment  
python -m venv venv  
Windows: venv\Scripts\activate  
macOS/Linux: source venv/bin/activate

4. Install Python dependencies  
pip install -r requirements.txt

5. Configure database credentials  
Copy the example config and edit your connection settings:  
cp app/config.example.py app/config.py  
In app/config.py, set:  
DB_HOST = "localhost"  
DB_USER = "root"  
DB_PASS = "your_password"  
DB_NAME = "your_database"

6. Start the Flask application  
flask --app app --debug run

7. Verify in your browser  
Home dashboard: http://127.0.0.1:5000  
Customer orders: http://127.0.0.1:5000/orders  
Store sales: http://127.0.0.1:5000/store-sales  
Frequent products (subquery): http://127.0.0.1:5000/frequent-products

8. Troubleshooting  
If you see a template error, confirm app/templates/index.html and app/templates/results.html exist. If you see a DB error, verify your credentials in config.py and that MySQL is running.
