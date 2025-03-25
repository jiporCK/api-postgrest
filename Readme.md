# PostgREST API Setup

This repository provides a **RESTful API** using [PostgREST](https://postgrest.org/). It automatically generates a REST API from a **PostgreSQL database**, allowing secure and scalable API development.

---

## 🚀 Quick Start

### **1️⃣ Install Dependencies**
Ensure you have **Docker** and **Docker Compose** installed.

```sh
# Install Docker (if not installed)
sudo apt install docker docker-compose
```

### **2️⃣ Clone the Repository**
```sh
git clone https://github.com/your-repo/postgrest-api.git
cd postgrest-api
```

### **3️⃣ Start the API**
Run the database and PostgREST service using **Docker Compose**:
```sh
docker-compose up -d
```
This starts **PostgreSQL** on port `5432` and **PostgREST** on port `3000`.

### **4️⃣ Verify the API**
Check if PostgREST is running:
```sh
curl http://localhost:3000/
```
It should return a JSON response listing available tables.

---

## 📂 Project Structure
```
postgrest-api/
│── docker-compose.yml       # Defines PostgREST & PostgreSQL services
│── init.sql                 # Database schema & role setup
│── README.md                # Documentation
```

---

## 🔧 Configuration
PostgREST uses environment variables to connect to the database. Modify `docker-compose.yml` if needed:
```yaml
  postgrest:
    environment:
      PGRST_DB_URI: "postgres://myuser:mypassword@db:5432/mydb"
      PGRST_DB_SCHEMA: "api"
      PGRST_DB_ANON_ROLE: "web_anon"
      PGRST_JWT_SECRET: "supersecretjwtkey"
```

---

## 📌 Database Schema (`init.sql`)
The database is initialized with **users** and **posts** tables:
```sql
CREATE SCHEMA api;
CREATE TABLE api.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

CREATE TABLE api.posts (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES api.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL
);

-- Roles & Permissions
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT SELECT ON api.users, api.posts TO web_anon;
```

---

## 🔒 Authentication & Security
PostgREST supports **JWT authentication** for securing endpoints. Example policy:
```sql
ALTER TABLE api.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_can_see_own_posts ON api.posts
FOR SELECT USING (user_id = current_setting('request.jwt.claims', true)::json->>'user_id');
```
To access **protected routes**, generate a JWT and include it in the request:
```sh
curl -H "Authorization: Bearer <your_token>" http://localhost:3000/posts
```

---

## 🛠️ Updating the Database
For schema changes, use `ALTER TABLE` instead of modifying `init.sql` directly:
```sql
ALTER TABLE api.users ADD COLUMN phone VARCHAR(20);
```

---

## 🚀 Deployment & Scaling
For production, consider:
- **PgBouncer** for connection pooling
- **Nginx** for reverse proxy & rate limiting
- **Automated backups** with `pg_dump`
- **Kubernetes/Docker Swarm** for scaling

---

## ✅ API Usage Examples
Fetch all posts:
```sh
curl http://localhost:3000/posts
```
Create a new post:
```sh
curl -X POST http://localhost:3000/posts \
     -H "Content-Type: application/json" \
     -d '{"title": "New Post", "content": "Post content"}'
```

---

## 📜 License
This project is licensed under the MIT License.

---

## 📩 Contact
For questions, contact **srengchipor99@gmail.com**.

