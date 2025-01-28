from flask import Flask, jsonify, request
import pyodbc

app = Flask(__name__)

# Configure database connection
DATABASE_PATH = r"D:\Flutter apps\khamsat_faisal_desktop_app\assets\db.accdb"  # Replace with your .accdb file path
CONNECTION_STRING = (
    r"Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
    f"DBQ={DATABASE_PATH};"
)

# Function to fetch all data from the database
def fetch_data():
    try:
        connection = pyodbc.connect(CONNECTION_STRING)
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM MaterialsTable")  # Replace 'TableName' with your table name
        columns = [column[0] for column in cursor.description]
        rows = cursor.fetchall()
        data = [dict(zip(columns, row)) for row in rows]
        cursor.close()
        connection.close()
        return data
    except Exception as e:
        print(f"Error fetching data: {e}")
        return []

@app.route('/items', methods=['GET'])
def get_items():
    data = fetch_data()
    if not data:
        return jsonify({"error": "Could not fetch data or database is empty"}), 500
    return jsonify(data)

@app.route('/items/filter', methods=['GET'])
def filter_items():
    search = request.args.get('search', '').lower()
    status = request.args.get('status', 'جميع')
    beneficiary = request.args.get('beneficiary', 'جميع')

    data = fetch_data()
    if not data:
        return jsonify({"error": "Could not fetch data or database is empty"}), 500

    filtered_data = [
        item for item in data
        if (search in item.get('اسم المادة', '').lower()) and
           (status == 'جميع' or item.get('حالة المادة') == status) and
           (beneficiary == 'جميع' or item.get('لصالح من') == beneficiary)
    ]
    return jsonify(filtered_data)

if __name__ == '__main__':
    app.run(debug=True)
