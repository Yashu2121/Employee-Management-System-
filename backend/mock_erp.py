import json
from datetime import datetime, date
from typing import Optional
from fastapi import FastAPI, Header, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Mock ERPNext API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock Credentials
API_KEY = "mock_api_key_123"
API_SECRET = "mock_api_secret_456"
EXPECTED_TOKEN = f"token {API_KEY}:{API_SECRET}"

# In-memory Mock Data
mock_salaries = {
    "EMP-0002": [
        {
            "name": "SAL-2026-05-0001",
            "employee": "EMP-0002",
            "employee_name": "Yash Shinde",
            "posting_date": "2026-05-01",
            "gross_pay": 75000.0,
            "total_deduction": 5000.0,
            "net_pay": 70000.0,
            "status": "Submitted"
        },
        {
            "name": "SAL-2026-04-0001",
            "employee": "EMP-0002",
            "employee_name": "Yash Shinde",
            "posting_date": "2026-04-01",
            "gross_pay": 75000.0,
            "total_deduction": 4500.0,
            "net_pay": 70500.0,
            "status": "Submitted"
        }
    ],
    "EMP-0003": [
        {
            "name": "SAL-2026-05-0002",
            "employee": "EMP-0003",
            "employee_name": "Jane Smith",
            "posting_date": "2026-05-01",
            "gross_pay": 95000.0,
            "total_deduction": 7000.0,
            "net_pay": 88000.0,
            "status": "Submitted"
        }
    ],
    "EMP-0004": [
        {
            "name": "SAL-2026-05-0003",
            "employee": "EMP-0004",
            "employee_name": "Alice Johnson",
            "posting_date": "2026-05-01",
            "gross_pay": 80000.0,
            "total_deduction": 6000.0,
            "net_pay": 74000.0,
            "status": "Submitted"
        }
    ],
    "EMP-0005": [
        {
            "name": "SAL-2026-05-0004",
            "employee": "EMP-0005",
            "employee_name": "Robert Davis",
            "posting_date": "2026-05-01",
            "gross_pay": 120000.0,
            "total_deduction": 10000.0,
            "net_pay": 110000.0,
            "status": "Submitted"
        }
    ]
}

mock_attendance = [
    {
        "name": "ATT-2026-05-001",
        "employee": "EMP-0002",
        "employee_name": "Yash Shinde",
        "attendance_date": "2026-05-20",
        "status": "Present",
        "in_time": "2026-05-20 09:05:00",
        "out_time": "2026-05-20 18:00:00"
    },
    {
        "name": "ATT-2026-05-002",
        "employee": "EMP-0002",
        "employee_name": "Yash Shinde",
        "attendance_date": "2026-05-21",
        "status": "Present",
        "in_time": "2026-05-21 08:55:00",
        "out_time": "2026-05-21 18:05:00"
    },
    {
        "name": "ATT-2026-05-003",
        "employee": "EMP-0002",
        "employee_name": "Yash Shinde",
        "attendance_date": "2026-05-22",
        "status": "Present",
        "in_time": "2026-05-22 09:12:00",
        "out_time": "2026-05-22 17:58:00"
    },
    {
        "name": "ATT-2026-05-004",
        "employee": "EMP-0003",
        "employee_name": "Jane Smith",
        "attendance_date": "2026-05-22",
        "status": "Present",
        "in_time": "2026-05-22 09:00:00",
        "out_time": "2026-05-22 18:00:00"
    },
    {
        "name": "ATT-2026-05-005",
        "employee": "EMP-0004",
        "employee_name": "Alice Johnson",
        "attendance_date": "2026-05-22",
        "status": "Present",
        "in_time": "2026-05-22 08:45:00",
        "out_time": "2026-05-22 17:30:00"
    }
]

# Helper to verify Token
def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization or authorization != EXPECTED_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid or missing Authorization header")
    return authorization

class PunchRequest(BaseModel):
    employee: str
    employee_name: str
    status: str  # Present, Absent, Half Day
    in_time: str
    out_time: Optional[str] = None

@app.get("/api/resource/Salary Slip")
def get_salary_slips(request: Request, authorization: str = Depends(verify_token)):
    filters_param = request.query_params.get("filters")
    employee_id = None
    
    if filters_param:
        try:
            filters = json.loads(filters_param)
            if isinstance(filters, dict):
                employee_id = filters.get("employee")
            elif isinstance(filters, list):
                # Handle nested lists like [["Salary Slip", "employee", "=", "EMP-0002"]]
                for f in filters:
                    if len(f) >= 4 and f[1] == "employee":
                        employee_id = f[3]
        except Exception:
            # Fallback for simple key=value parsing if JSON fails
            pass
            
    if not employee_id:
        # Return all salaries if no filter
        all_salaries = []
        for slips in mock_salaries.values():
            all_salaries.extend(slips)
        return {"data": all_salaries}
        
    return {"data": mock_salaries.get(employee_id, [])}

@app.get("/api/resource/Attendance")
def get_attendance(request: Request, authorization: str = Depends(verify_token)):
    filters_param = request.query_params.get("filters")
    employee_id = None
    
    if filters_param:
        try:
            filters = json.loads(filters_param)
            if isinstance(filters, dict):
                employee_id = filters.get("employee")
            elif isinstance(filters, list):
                for f in filters:
                    if len(f) >= 4 and f[1] == "employee":
                        employee_id = f[3]
        except Exception:
            pass

    limit = request.query_params.get("limit_page_length")
    try:
        limit = int(limit) if limit else None
    except ValueError:
        limit = None
        
    results = mock_attendance
    if employee_id:
        results = [att for att in mock_attendance if att["employee"] == employee_id]
        
    # Sort by date desc
    results = sorted(results, key=lambda x: x["attendance_date"], reverse=True)
    
    if limit:
        results = results[:limit]
        
    return {"data": results}

@app.post("/api/resource/Attendance")
def create_attendance(payload: PunchRequest, authorization: str = Depends(verify_token)):
    # Check if there is already an entry for this employee and date
    today_str = datetime.now().strftime("%Y-%m-%d")
    existing = None
    for att in mock_attendance:
        if att["employee"] == payload.employee and att["attendance_date"] == today_str:
            existing = att
            break
            
    if existing:
        # If already punched in, update the out_time (punch out)
        if payload.out_time:
            existing["out_time"] = payload.out_time
            existing["status"] = payload.status
            return {"data": existing}
        else:
            raise HTTPException(status_code=400, detail="Employee already punched in for today.")
    else:
        new_att = {
            "name": f"ATT-2026-05-{len(mock_attendance) + 1:03d}",
            "employee": payload.employee,
            "employee_name": payload.employee_name,
            "attendance_date": today_str,
            "status": payload.status,
            "in_time": payload.in_time,
            "out_time": payload.out_time
        }
        mock_attendance.append(new_att)
        return {"data": new_att}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
