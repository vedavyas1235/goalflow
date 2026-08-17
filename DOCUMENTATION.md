# 📖 GoalFlow Documentation

## 1. Overview
**GoalFlow** is an intelligent, AI-powered goal tracking and habit-building mobile application. It acts as a personalized digital coach, helping users break down ambitious, complex goals into manageable, 30-day actionable roadmaps. By leveraging advanced generative AI, GoalFlow provides structured daily tasks, motivation, and weekly synthesized reflections to keep users accountable and on track.

---

## 2. Technology Stack

### 📱 Frontend (Mobile App)
*   **Framework**: Flutter (Dart)
*   **Architecture**: Cross-platform (Android/iOS)
*   **State Management**: `provider`
*   **Navigation**: `go_router`
*   **Local Storage**: `shared_preferences` (for caching drafts and user session data)
*   **UI/UX**: Custom themed UI with glowing squircle components, ambient watercolor backgrounds, and responsive layouts.

### ⚙️ Backend (API)
*   **Environment**: Node.js with Express.js
*   **Language**: TypeScript
*   **Hosting**: Vercel (Serverless Functions)
*   **Architecture**: RESTful API design

### 🗄️ Database & ORM
*   **Database**: PostgreSQL (Hosted on Supabase)
*   **ORM**: Prisma Client (Type-safe database access)
*   **Connection**: Supabase Connection Pooler for serverless compatibility

### 🧠 AI Integration
*   **Provider**: OpenRouter API
*   **Primary Model**: `cohere/north-mini-code:free` (Cohere)
*   **Functionality**: Prompt engineering to generate structured JSON outputs for onboarding slides, 30-day action plans, and weekly reflection syntheses.

---

## 3. How It Works (Core Mechanics)

GoalFlow operates on a core loop of **Intention $\rightarrow$ AI Structuring $\rightarrow$ Execution $\rightarrow$ Reflection**.

1.  **Context Gathering**: The app collects deep context about the user's life, schedule, and motivations through a highly structured 5-step onboarding process.
2.  **AI Analysis & Structuring**: The backend compiles this data into a comprehensive prompt. The AI engine processes the constraints and goals to output a strict JSON structure containing personalized coaching slides and a day-by-day 30-day task list.
3.  **Database Persistence**: The generated roadmap is securely saved to the PostgreSQL database, linking specific action items to the user's core goal.
4.  **Daily Execution**: Users interact with the app daily, completing micro-tasks that contribute to the macro-goal.
5.  **AI Synthesis**: Weekly reflections are fed back into the AI to provide a "Journey Echo"—a synthesized summary of their progress, hurdles, and strategies for the upcoming week.

---

## 4. User Workflow

### Phase 1: Authentication
*   Users register or log in using email and password authentication securely handled via the backend and Supabase.

### Phase 2: The 5-Step Onboarding Pipeline
1.  **Digital Identity**: Users select an avatar persona (e.g., Achiever, Pioneer) and define their core life objective.
2.  **Goal Blueprint**: Users define the specific goal title, category (e.g., Learning, Health), timeframe, and priority level.
3.  **Detailed Description**: A multi-line input where users explain *why* they want to achieve this goal. (Mandatory step to ensure high-quality AI output).
4.  **Schedule & Routine**: Users define their ideal focus window (Morning, Evening), session duration (e.g., 30 mins), frequency, and active days of the week.
5.  **Personalization**: Users input life constraints (e.g., "busy on weekends"), select an accountability style (Strict vs. Flexible), and set reminder preferences.

### Phase 3: AI Roadmap Generation
*   Upon submission, the user sees a loading screen while the backend communicates with the AI. 
*   The AI generates 3 personalized coaching slides (Achievability, Effort Required, Milestone Overview) and exactly 30 daily action items.

### Phase 4: Dashboard & Daily Execution
*   The Dashboard displays the active goal and a circular progress gauge.
*   Users see a scrollable list of 30 days. They tap to view AI-generated briefings for each task and check them off upon completion.

### Phase 5: Weekly Reflection
*   Users answer 3 core questions:
    1. *What went well this week?*
    2. *What made things difficult?*
    3. *What would you like to improve next week?*
*   The AI synthesizes these answers into a profound, encouraging "Journey Echo" log.

---

## 5. User Personas
GoalFlow is designed for:
*   **Ambitious Professionals**: Looking to upskill or transition careers (e.g., learning a new programming stack) with limited time.
*   **Students**: Needing structured study plans and accountability to avoid procrastination.
*   **Self-Improvement Enthusiasts**: Individuals pursuing personal goals (fitness, language learning, habits) who struggle with breaking down large tasks into daily steps.

---

## 6. Future Improvements

To further enhance GoalFlow, the following features are slated for future development:

1.  **Push Notifications & OS Integration**: Implement native push notifications for daily reminders and integrate with Google/Apple Calendar to block out focus times automatically.
2.  **Dynamic AI Course Correction**: Allow the AI to dynamically restructure the remaining 30-day plan based on the weekly reflection (e.g., if a user falls behind, the AI recalibrates the task difficulty).
3.  **Social Accountability**: Introduce a "Squads" feature where users can share milestones, streaks, and Journey Echos with friends for mutual accountability.
4.  **Gamification Engine**: Add a robust streak system, experience points (XP), and visual badges to reward consistency.
5.  **Offline-First Architecture**: Integrate a local database (like Isar or Hive) to allow users to check off tasks offline, syncing automatically with the Postgres backend when connectivity is restored.
6.  **Advanced Analytics**: Provide users with deep insights into their productivity patterns (e.g., "You complete 80% of tasks on Tuesday mornings, but only 20% on Friday evenings").
