# VoxCivica — AI-Powered Civic Voice Translator

> **Google Solution Challenge 2025**

---

## 🎯 Problem

Billions of citizens in democracies cannot effectively file government complaints due to:
- **Language barriers** — most government portals only accept formal English
- **Format complexity** — citizens don't know how to write official petitions
- **No collective voice** — individual complaints are easily ignored

## 💡 Solution

**VoxCivica** lets citizens speak or type their complaint *informally*, in *any language*. Google Gemini AI instantly transforms it into a **formal government petition** addressed to the correct department — in seconds.

Nearby complaints are automatically **clustered into collective petitions**, giving communities a unified, powerful voice.

---

## 🔧 Google Technology Used

| Technology | Usage |
|---|---|
| **Gemini 2.0 Flash API** | Text-to-petition generation, multilingual support |
| **Gemini Vision** | Photo-based civic issue detection |
| **Gemini Collective** | Multi-complaint petition merging |

---

## 🌍 UN SDGs Addressed

- 🏛️ **SDG 16** — Peace, Justice and Strong Institutions
- ⚖️ **SDG 10** — Reduced Inequalities
- 🌆 **SDG 11** — Sustainable Cities and Communities

---

## 🎬 Demo Flow

1. **Speak or type** a civic complaint (pothole, broken light, waterlogging)
2. **Choose language** — English, Tamil, Hindi, Telugu
3. **Choose tone** — Polite / Firm / Formal
4. Gemini generates a **formal petition** addressed to the right department
5. Open the **Community Map** — see all nearby complaints as pins
6. Tap a pin → **Join Collective Petition** → Gemini merges all into one powerful petition

---

## 🏗️ Architecture

```
Flutter App (Web/Android)
        │
        ▼ HTTPS (ngrok tunnel for demo)
FastAPI Backend (localhost:8000)
        │
        ├── /generate-petition  ──► Gemini 2.0 Flash (text)
        ├── /analyze-photo      ──► Gemini 2.0 Flash (vision)
        ├── /cluster-petition   ──► Gemini 2.0 Flash (collective)
        ├── /save-complaint     ──► db.json (local JSON store)
        └── /get-complaints     ──► db.json
```

---

## 🚀 How to Run Locally

### Prerequisites
- Python 3.10+
- Flutter 3.x
- ngrok account (free) — ngrok.com

### 1. Start the Backend

```bash
cd voxcivica/backend
venv\Scripts\activate          # Windows
pip install -r requirements.txt

# Add your Gemini API key to .env
echo "GEMINI_API_KEY=your_key_here" > .env

uvicorn main:app --reload --port 8000
```

### 2. Start ngrok

```bash
ngrok config add-authtoken YOUR_NGROK_TOKEN
ngrok http 8000
# Copy the https://xxxx.ngrok-free.app URL
```

### 3. Update Flutter API URL

In `voxcivica_app/lib/api_service.dart`, update:
```dart
const String baseUrl = 'https://YOUR-NGROK-URL.ngrok-free.app';
```

### 4. Run Flutter App

```bash
cd voxcivica/voxcivica_app
flutter pub get
flutter run -d chrome
```

---

## 📁 Project Structure

```
voxcivica/
├── backend/
│   ├── main.py          # FastAPI server + Gemini integration
│   ├── db.json          # Local JSON database (3 seeded complaints)
│   ├── requirements.txt
│   └── .env             # GEMINI_API_KEY (never commit this!)
└── voxcivica_app/
    └── lib/
        ├── main.dart
        ├── api_service.dart
        └── screens/
            ├── home_screen.dart     # Report issue + voice input
            ├── petition_screen.dart # Petition preview + submit
            └── map_screen.dart      # Community complaint map
```

---

## ⚠️ Security Notes

- `.env` and `db.json` are in `.gitignore` — API keys are never committed
- For production: replace JSON store with Firestore, use proper auth

---
