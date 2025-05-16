import json
import boto3
import requests
import re
import os
from email.parser import BytesParser
from email.policy import default
from pathlib import Path

def sanitize_filename(filename):
    """Sanitize filename to prevent path traversal and other security issues."""
    if not filename:
        return "document.pdf"
    
    # Get just the filename without path
    filename = os.path.basename(filename)
    
    # Remove any non-alphanumeric chars except -._
    filename = re.sub(r'[^a-zA-Z0-9-._]', '_', filename)
    
    # Ensure it ends with .pdf
    if not filename.lower().endswith('.pdf'):
        filename += '.pdf'
    
    # Limit length
    max_length = 255 - len('.pdf')
    if len(filename) > max_length:
        base = filename[:-4]  # remove .pdf
        filename = base[:max_length] + '.pdf'
    
    # Ensure filename doesn't start with . or -
    if filename.startswith(('.', '-')):
        filename = 'f' + filename
    
    return filename

def lambda_handler(event, context):
    """Simplified Lambda handler to process S3 events from SES and forward PDFs."""
    try:
        # Extract S3 details from event
        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Get email from S3
        s3 = boto3.client('s3')
        email_data = s3.get_object(Bucket=bucket, Key=key)['Body'].read()
        
        # Parse email
        msg = BytesParser(policy=default).parsebytes(email_data)
        sender = msg.get('From', '')
        receiver = msg.get('To', '')
        
        # Find PDF attachment
        for part in msg.walk():
            if part.get_content_type() == 'application/pdf' or (part.get_filename() and part.get_filename().lower().endswith('.pdf')):
                # Get and sanitize filename
                original_filename = part.get_filename() or 'document.pdf'
                safe_filename = sanitize_filename(original_filename)
                
                print(f"Processing attachment: {original_filename} -> {safe_filename}")
                
                # Forward to print job app
                files = {'file': (safe_filename, part.get_payload(decode=True), 'application/pdf')}
                data = {
                    'sender': sender.strip(),
                    'receiver': receiver.strip()
                }
                
                response = requests.post(
                    'https://pettan-test.fun/api/pushPrintJob',
                    files=files,
                    data=data,
                    timeout=2.5  # Set timeout to avoid Lambda timeout
                )
                
                return {
                    'statusCode': response.status_code,
                    'body': response.text
                }
        
        return {
            'statusCode': 400,
            'body': 'No PDF attachment found'
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': str(e)
        }