import os
import hashlib
import json
from datetime import datetime, date, timedelta
from typing import List, Optional
import requests
from fastapi import FastAPI, Depends, HTTPException, status, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
import jwt
from pydantic import BaseModel

from db import get_db, User, Leave

app = FastAPI(title="Employee Management Middle-Layer App")

# Enable CORS for Flutter web-app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# JWT Details
JWT_SECRET = "jwt_secret_key_987654321_abc_xyz"
JWT_ALGORITHM = "HS256"

# ERPNext integration configuration
ERP_URL = os.getenv("ERP_URL", "http://localhost:8000")
ERP_KEY = os.getenv("ERP_KEY", "mock_api_key_123")
ERP_SECRET = os.getenv("ERP_SECRET", "mock_api_secret_456")
ERP_HEADERS = {
    "Authorization": f"token {ERP_KEY}:{ERP_SECRET}"
}

security = HTTPBearer()

# Pydantic Schemas
class LoginRequest(BaseModel):
    username: str
    password: str

class LeaveApplyRequest(BaseModel):
    start_date: str
    end_date: str
    reason: str

class LeaveActionRequest(BaseModel):
    leave_id: int
    action: str  # approve or reject

class UserCreateRequest(BaseModel):
    username: str
    password: str
    role: str  # employee, team_leader, hr, director
    employee_id: str
    name: str
    total_leaves: int = 12

class PunchRequest(BaseModel):
    status: str
    in_time: str
    out_time: Optional[str] = None

# Helper functions
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

def create_jwt_token(user: User) -> str:
    payload = {
        "id": user.id,
        "username": user.username,
        "role": user.role,
        "employee_id": user.employee_id,
        "name": user.name,
        "exp": datetime.utcnow() + timedelta(days=7)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        username: str = payload.get("username")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        
        user = db.query(User).filter(User.username == username).first()
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Could not validate credentials")

# Endpoints

# 1. Login
@app.post("/api/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    hashed_pwd = hash_password(payload.password)
    user = db.query(User).filter(User.username == payload.username, User.password_hash == hashed_pwd).first()
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    
    token = create_jwt_token(user)
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "username": user.username,
            "role": user.role,
            "employee_id": user.employee_id,
            "name": user.name,
            "total_leaves": user.total_leaves,
            "remaining_leaves": user.remaining_leaves
        }
    }

# 2. Get User Profile (Self)
@app.get("/api/users/me")
def get_me(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "username": current_user.username,
        "role": current_user.role,
        "employee_id": current_user.employee_id,
        "name": current_user.name,
        "total_leaves": current_user.total_leaves,
        "remaining_leaves": current_user.remaining_leaves
    }

# 3. Apply Leave (Employee)
@app.post("/api/leaves/apply")
def apply_leave(payload: LeaveApplyRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        start = datetime.strptime(payload.start_date, "%Y-%m-%d").date()
        end = datetime.strptime(payload.end_date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
        
    if start > end:
        raise HTTPException(status_code=400, detail="Start date cannot be after end date")
        
    # Create leave request
    leave = Leave(
        employee_id=current_user.employee_id,
        start_date=start,
        end_date=end,
        reason=payload.reason,
        status="pending"
    )
    db.add(leave)
    db.commit()
    db.refresh(leave)
    return {"message": "Leave applied successfully", "leave": leave}

# 4. View My Leaves (Employee)
@app.get("/api/leaves/my")
def get_my_leaves(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    leaves = db.query(Leave).filter(Leave.employee_id == current_user.employee_id).order_by(Leave.applied_date.desc()).all()
    return leaves

# 5. Team Leader - Get Pending Leaves
@app.get("/api/leaves/pending/tl")
def get_pending_leaves_tl(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role not in ["team_leader", "hr", "director"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # TL sees all pending leaves. We join with User to get details.
    pending_leaves = db.query(Leave, User.name).join(User, User.employee_id == Leave.employee_id).filter(Leave.status == "pending").all()
    
    return [
        {
            "id": leave.id,
            "employee_id": leave.employee_id,
            "employee_name": name,
            "start_date": leave.start_date,
            "end_date": leave.end_date,
            "reason": leave.reason,
            "status": leave.status,
            "applied_date": leave.applied_date
        }
        for leave, name in pending_leaves
    ]

# 6. Team Leader Action (Approve/Reject)
@app.post("/api/leaves/action/tl")
def action_leave_tl(payload: LeaveActionRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "team_leader":
        raise HTTPException(status_code=403, detail="Only Team Leaders can take this action")
        
    leave = db.query(Leave).filter(Leave.id == payload.leave_id, Leave.status == "pending").first()
    if not leave:
        raise HTTPException(status_code=404, detail="Pending leave request not found")
        
    if payload.action == "approve":
        leave.status = "tl_approved"
    elif payload.action == "reject":
        leave.status = "tl_rejected"
    else:
        raise HTTPException(status_code=400, detail="Invalid action. Use 'approve' or 'reject'")
        
    db.commit()
    return {"message": f"Leave status updated to {leave.status}", "leave": leave}

# 7. HR - Get Pending Leaves (Approved by TL)
@app.get("/api/leaves/pending/hr")
def get_pending_leaves_hr(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role not in ["hr", "director"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    pending_leaves = db.query(Leave, User.name).join(User, User.employee_id == Leave.employee_id).filter(Leave.status == "tl_approved").all()
    
    return [
        {
            "id": leave.id,
            "employee_id": leave.employee_id,
            "employee_name": name,
            "start_date": leave.start_date,
            "end_date": leave.end_date,
            "reason": leave.reason,
            "status": leave.status,
            "applied_date": leave.applied_date
        }
        for leave, name in pending_leaves
    ]

# 8. HR Action (Approve/Reject - Final approval and Leave deduction)
@app.post("/api/leaves/action/hr")
def action_leave_hr(payload: LeaveActionRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "hr":
        raise HTTPException(status_code=403, detail="Only HR can take this action")
        
    leave = db.query(Leave).filter(Leave.id == payload.leave_id, Leave.status == "tl_approved").first()
    if not leave:
        raise HTTPException(status_code=404, detail="Leave request (approved by TL) not found")
        
    employee = db.query(User).filter(User.employee_id == leave.employee_id).first()
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
        
    if payload.action == "approve":
        # Calculate applied days
        days = (leave.end_date - leave.start_date).days + 1
        
        # Deduct leaves
        employee.remaining_leaves = max(0, employee.remaining_leaves - days)
        leave.status = "hr_approved"
    elif payload.action == "reject":
        leave.status = "hr_rejected"
    else:
        raise HTTPException(status_code=400, detail="Invalid action. Use 'approve' or 'reject'")
        
    db.commit()
    db.refresh(employee)
    
    return {
        "message": f"Leave status updated to {leave.status}",
        "leave": leave,
        "remaining_leaves": employee.remaining_leaves
    }

# 9. Real-time Salary slip from ERPNext (Proxy)
@app.get("/api/employee/salary/{employee_id}")
def proxy_salary(employee_id: str, current_user: User = Depends(get_current_user)):
    # Restrict employees to only view their own salary
    if current_user.role == "employee" and current_user.employee_id != employee_id:
        raise HTTPException(status_code=403, detail="You can only view your own salary slip")
        
    # Request to mock ERPNext
    url = f"{ERP_URL}/api/resource/Salary Slip?filters={{\"employee\":\"{employee_id}\"}}"
    try:
        response = requests.get(url, headers=ERP_HEADERS)
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": f"Failed to fetch salary, status code: {response.status_code}", "data": []}
    except Exception as e:
        return {"error": f"Connection to ERPNext failed: {str(e)}", "data": []}

# 10. Real-time Attendance from ERPNext (Proxy)
@app.get("/api/employee/attendance/{employee_id}")
def proxy_attendance(employee_id: str, current_user: User = Depends(get_current_user)):
    if current_user.role == "employee" and current_user.employee_id != employee_id:
        raise HTTPException(status_code=403, detail="You can only view your own attendance")
        
    url = f"{ERP_URL}/api/resource/Attendance?filters={{\"employee\":\"{employee_id}\"}}"
    try:
        response = requests.get(url, headers=ERP_HEADERS)
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": f"Failed to fetch attendance, status code: {response.status_code}", "data": []}
    except Exception as e:
        return {"error": f"Connection to ERPNext failed: {str(e)}", "data": []}

# 11. Real-time punch in ERPNext
@app.post("/api/employee/punch")
def proxy_punch(payload: PunchRequest, current_user: User = Depends(get_current_user)):
    url = f"{ERP_URL}/api/resource/Attendance"
    data = {
        "employee": current_user.employee_id,
        "employee_name": current_user.name,
        "status": payload.status,
        "in_time": payload.in_time,
        "out_time": payload.out_time
    }
    try:
        response = requests.post(url, json=data, headers=ERP_HEADERS)
        if response.status_code in [200, 201]:
            return response.json()
        else:
            raise HTTPException(status_code=response.status_code, detail=response.text)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Connection to ERPNext failed: {str(e)}")

# 12. Create User (HR Only)
@app.post("/api/users/create")
def create_user(payload: UserCreateRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "hr":
        raise HTTPException(status_code=403, detail="Only HR can create new users")
        
    # Check if username or employee_id exists
    existing = db.query(User).filter((User.username == payload.username) | (User.employee_id == payload.employee_id)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username or Employee ID already exists")
        
    new_user = User(
        username=payload.username,
        password_hash=hash_password(payload.password),
        role=payload.role,
        employee_id=payload.employee_id,
        name=payload.name,
        total_leaves=payload.total_leaves,
        remaining_leaves=payload.total_leaves
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User created successfully", "user": {
        "username": new_user.username,
        "role": new_user.role,
        "employee_id": new_user.employee_id,
        "name": new_user.name
    }}

# 13. List Users (HR & Director)
@app.get("/api/users/list")
def list_users(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role not in ["hr", "director"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    users = db.query(User).all()
    return [
        {
            "id": u.id,
            "username": u.username,
            "role": u.role,
            "employee_id": u.employee_id,
            "name": u.name,
            "total_leaves": u.total_leaves,
            "remaining_leaves": u.remaining_leaves
        }
        for u in users
    ]

# 14. Director - Summary Dashboard Metrics
@app.get("/api/director/summary")
def get_director_summary(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "director":
        raise HTTPException(status_code=403, detail="Only Directors can view this dashboard summary")
        
    # 1. Total Employees
    total_employees = db.query(User).count()
    
    # 2. Leaves overview
    pending_leaves = db.query(Leave).filter(Leave.status == "pending").count()
    tl_approved_leaves = db.query(Leave).filter(Leave.status == "tl_approved").count()
    approved_leaves = db.query(Leave).filter(Leave.status == "hr_approved").count()
    rejected_leaves = db.query(Leave).filter(Leave.status.in_(["tl_rejected", "hr_rejected"])).count()
    
    # 3. Attendance Summary from ERPNext
    today_str = datetime.now().strftime("%Y-%m-%d")
    url = f"{ERP_URL}/api/resource/Attendance"
    present_today = 0
    total_attendance_records = 0
    
    try:
        response = requests.get(url, headers=ERP_HEADERS)
        if response.status_code == 200:
            records = response.json().get("data", [])
            total_attendance_records = len(records)
            for r in records:
                if r.get("attendance_date") == today_str and r.get("status") == "Present":
                    present_today += 1
    except Exception:
        # If connection fails, return 0 or default
        pass

    return {
        "total_employees": total_employees,
        "leaves": {
            "pending_tl": pending_leaves,
            "pending_hr": tl_approved_leaves,
            "approved": approved_leaves,
            "rejected": rejected_leaves
        },
        "attendance": {
            "present_today": present_today,
            "total_records": total_attendance_records
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=5000)
