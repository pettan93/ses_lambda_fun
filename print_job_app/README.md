# Print Job Manager

Simple web app for managing print jobs via REST API.

## Quick Start

```bash
pip install -r requirements.txt
python app.py
```

App runs at http://localhost:5000

## API

POST `/api/pushPrintJob`
- `sender`: Email
- `receiver`: Email
- `file`: PDF file

## Structure

```
print_job_app/
├── app.py          # Main app
├── templates/      # HTML
├── static/        # Assets
└── upload/        # PDFs
```

## Notes
- In-memory storage (data cleared on restart)
- PDF files only
