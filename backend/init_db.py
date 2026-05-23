import hashlib
from db import Base, engine, SessionLocal, User

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

def init_database():
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # Check if users already exist
        if db.query(User).count() == 0:
            print("Seeding initial users...")
            
            # Default users to seed
            users_to_seed = [
                User(
                    username="employee",
                    password_hash=hash_password("employee123"),
                    role="employee",
                    employee_id="EMP-0002",
                    name="Yash Shinde",
                    total_leaves=12,
                    remaining_leaves=12
                ),
                User(
                    username="leader",
                    password_hash=hash_password("leader123"),
                    role="team_leader",
                    employee_id="EMP-0003",
                    name="Jane Smith",
                    total_leaves=12,
                    remaining_leaves=12
                ),
                User(
                    username="hr",
                    password_hash=hash_password("hr123"),
                    role="hr",
                    employee_id="EMP-0004",
                    name="Alice Johnson",
                    total_leaves=12,
                    remaining_leaves=12
                ),
                User(
                    username="director",
                    password_hash=hash_password("director123"),
                    role="director",
                    employee_id="EMP-0005",
                    name="Robert Davis",
                    total_leaves=12,
                    remaining_leaves=12
                )
            ]
            
            db.bulk_save_objects(users_to_seed)
            db.commit()
            print("Initial users seeded successfully.")
        else:
            print("Database already contains users. Skipping seed.")
    except Exception as e:
        print(f"Error initializing database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_database()
