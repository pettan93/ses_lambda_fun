from flask import Flask, request, render_template, jsonify
import os
import datetime
import uuid
import mimetypes
from itertools import groupby

app = Flask(__name__)

# Store print jobs in memory
print_jobs = []

# Setup upload dir
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'upload')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def extract_company(email):
    """Get company from email"""
    return email.split('@')[0] if '@' in email else email

@app.route('/')
def index():
    """Main page with jobs by company"""
    sorted_jobs = sorted(print_jobs, key=lambda x: x['company'])
    companies_jobs = {company: list(jobs) for company, jobs in groupby(sorted_jobs, key=lambda x: x['company'])}
    return render_template('index.html', companies_jobs=companies_jobs)

@app.route('/api/pushPrintJob', methods=['POST'])
def push_print_job():
    """Add new print job"""
    # Validate required fields
    if 'sender' not in request.form:
        return jsonify({"error": "Sender is required"}), 400
    if 'receiver' not in request.form:
        return jsonify({"error": "Receiver is required"}), 400
    if 'file' not in request.files:
        return jsonify({"error": "File is required"}), 400

    sender = request.form['sender']
    receiver = request.form['receiver']
    file = request.files['file']

    # Basic email check
    if '@' not in sender or '.' not in sender:
        return jsonify({"error": "Invalid sender email format"}), 400

    # PDF validation
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    if os.path.splitext(file.filename)[1].lower() != '.pdf':
        return jsonify({"error": "Only PDF files are allowed"}), 400
    if file.content_type != 'application/pdf':
        return jsonify({"error": "File must be a PDF"}), 400

    # Save file with unique name
    unique_filename = f"{uuid.uuid4()}.pdf"
    file_path = os.path.join(UPLOAD_FOLDER, unique_filename)
    file.save(file_path)

    # Create job record
    print_job = {
        'id': str(uuid.uuid4()),
        'sender': sender,
        'receiver': receiver,
        'company': extract_company(receiver),
        'original_filename': file.filename,
        'stored_filename': unique_filename,
        'file_size': os.path.getsize(file_path),
        'upload_date': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'file_path': file_path
    }
    print_jobs.append(print_job)

    return jsonify({"message": "Print job added successfully", "job_id": print_job['id']}), 201

if __name__ == '__main__':
    app.run(debug=True)
