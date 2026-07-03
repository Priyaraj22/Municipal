# Rajapalayam Municipality — Family Survey System
## Complete End-to-End Project

---

## Project Layout

```
rpm_complete/
├── backend/                    ← Node.js / Express / PostgreSQL API
│   ├── server.js
│   ├── package.json
│   ├── .env.example            ← copy to .env and fill in
│   ├── config/db.js
│   ├── database/schema.sql     ← run this once to create all tables
│   ├── middleware/
│   ├── models/
│   ├── controllers/
│   ├── routes/
│   └── services/
│
└── flutter_app/                ← Flutter mobile app (Android / iOS)
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart           ← SET YOUR SERVER IP HERE
    │   ├── models/
    │   ├── services/
    │   ├── theme/
    │   ├── widgets/
    │   └── screens/
    └── assets/images/
```

---

## Step 1 — Set Up PostgreSQL

### Install PostgreSQL (if not installed)
```bash
# Ubuntu / Debian
sudo apt install postgresql postgresql-contrib

# macOS (Homebrew)
brew install postgresql@15
```

### Create database and user
```bash
sudo -u postgres psql
```
```sql
CREATE DATABASE rajapalayam_survey;
CREATE USER rpm_user WITH ENCRYPTED PASSWORD 'your_strong_password';
GRANT ALL PRIVILEGES ON DATABASE rajapalayam_survey TO rpm_user;
\q
```

### Run the schema (creates tables + seeds 42 wards + admin account)
```bash
psql -U rpm_user -d rajapalayam_survey -f backend/database/schema.sql
```

Default admin password is **admin123** — change it after first login via:
```sql
UPDATE admins SET password_hash = '$2b$10$...' WHERE username='admin';
-- generate a new hash: node -e "console.log(require('bcryptjs').hashSync('newpassword', 10))"
```

---

## Step 2 — Configure and Start the Backend

```bash
cd backend

# Install dependencies
npm install

# Copy and edit environment file
cp .env.example .env
nano .env
```

Edit `.env`:
```
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=rajapalayam_survey
DB_USER=rpm_user
DB_PASSWORD=your_strong_password
JWT_SECRET=a_very_long_random_secret_change_this
JWT_EXPIRES_IN=12h
```

### Start the server
```bash
# Development (auto-restart on file changes)
npm run dev

# Production
npm start
```

You should see:
```
✅ PostgreSQL connected at 2024-...
🚀 Rajapalayam Survey System running on http://0.0.0.0:3000
```

### Find your machine's IP address (for the Flutter app)
```bash
# Linux / macOS
ip addr show | grep 'inet ' | grep -v '127.0.0.1'
# or
hostname -I

# Windows
ipconfig
```
Note the LAN IP, e.g. `192.168.1.100`

### Test the API
```bash
curl http://localhost:3000/api/health
# → {"status":"ok","timestamp":"..."}

curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"role":"admin","password":"admin123"}'
# → {"token":"...","user":{...}}
```

---

## Step 3 — Configure and Build the Flutter App

### Prerequisites
- Flutter SDK ≥ 3.0.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio (for Android) or Xcode (for iOS)
- A real Android phone or emulator

### Set the server IP

Open `flutter_app/lib/main.dart` and change:
```dart
ApiService.baseUrl = 'http://YOUR_SERVER_IP:3000/api';
```
to:
```dart
ApiService.baseUrl = 'http://192.168.1.100:3000/api';  // ← your actual IP
```

⚠️ **The phone and server must be on the same Wi-Fi network.**

### Install Flutter dependencies
```bash
cd flutter_app
flutter pub get
```

### Run on a connected Android phone
```bash
# Enable USB Debugging on the phone first
flutter run
```

### Build a release APK
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

Transfer the APK to the phone and install it, or use:
```bash
flutter install   # installs directly to connected phone
```

---

## API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/login` | — | Collector or admin login |
| GET | `/api/wards` | ✅ | List all 42 wards |
| GET | `/api/wards/progress` | ✅ | Family count per ward |
| GET | `/api/surveys` | ✅ | List surveys (filter: ?ward=, ?collector=) |
| POST | `/api/surveys` | ✅ | Submit new survey |
| DELETE | `/api/surveys/:id` | ✅ | Delete one survey |
| DELETE | `/api/surveys` | Admin | Delete all surveys |
| GET | `/api/dashboard` | ✅ | Stats + chart counts |
| GET | `/api/indicators` | ✅ | Health indicators (filter: ?ward=) |
| GET | `/api/export/excel` | ✅ | Download Excel (3 sheets) |

---

## App Roles & Screens

| Role | Screens |
|------|---------|
| **Collector** | New Survey (4-step wizard), My Records |
| **Admin** | Dashboard (charts), Indicators, Ward Progress, All Records |

---

## Troubleshooting

**"Network error" on phone:**
- Confirm the server IP in `main.dart` matches `hostname -I`
- Both devices must be on the **same Wi-Fi**
- Run `curl http://<YOUR_IP>:3000/api/health` from another terminal to verify

**PostgreSQL connection failed:**
- Check `DB_PASSWORD` in `.env`
- Ensure PostgreSQL is running: `sudo systemctl status postgresql`

**APK installs but crashes:**
- Check `flutter logs` or `adb logcat` for errors
- Most common: wrong server IP

**Survey submission fails:**
- The member `dob` field is required in the DB — ensure at least one member has a date of birth set
