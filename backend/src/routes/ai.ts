import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Helper to call OpenRouter
async function callOpenRouter(prompt: string) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : (process.env.APP_URL || "https://goalflow-opal.vercel.app"),
      "X-Title": "GoalFlow",
    },
    body: JSON.stringify({
      model: "cohere/north-mini-code:free",
      messages: [{ role: "user", content: prompt }]
    })
  });
  const data = await response.json();
  if (data.choices && data.choices.length > 0) {
    return data.choices[0].message.content;
  }
  throw new Error("Invalid response from OpenRouter: " + JSON.stringify(data));
}

// Background function to generate the massive 30-day blueprint
async function generateBlueprintInBackground(blueprintId: string, goalId: string, title: string, description: string, detailedDescription: string, timeframe: string, category: string, priority: string, routine: any, personalization: any, userId: string) {
  try {
    const prompt = `
You are the intelligence engine for GoalFlow.
Goal: "${title}"
Main Objective: "${description}"
Detailed Motivation: "${detailedDescription}"
Timeframe: ${timeframe}
Category: ${category}
Priority: ${priority}

USER ROUTINE & SCHEDULE:
Preferred Time: ${routine?.preferredTime || 'Any'}
Duration per session: ${routine?.targetDuration || '30 mins'}
Frequency: ${routine?.workingFrequency || 'Flexible'}
Preferred Days: ${routine?.preferredDays || 'Any'}

PERSONAL CONSTRAINTS & STYLE:
Constraints: ${personalization?.constraints || 'None'}
Tracking Style: ${personalization?.progressStyle || 'Flexible'}
Reminder Preference: ${personalization?.reminderPref || 'Standard'}

TASK: 30-DAY ACTION PLAN
Generate exactly 30 action items for the first 30 days. You MUST output ONLY a raw JSON array of objects. Do NOT wrap it in markdown. Do not include any other text. 
Ensure the tasks align with their constraints, preferred days, and available duration.
[
  { "day": 1, "title": "...", "durationMinutes": 30 },
  ...
]
`;

    const aiText = await callOpenRouter(prompt);
    
    // Parse the JSON array
    let actionsArray = [];
    try {
      const startIndex = aiText.indexOf('[');
      const endIndex = aiText.lastIndexOf(']');
      if (startIndex !== -1 && endIndex !== -1) {
        actionsArray = JSON.parse(aiText.substring(startIndex, endIndex + 1));
      } else {
        actionsArray = JSON.parse(aiText);
      }
    } catch (e) {
      console.warn("Failed to parse AI action items JSON:", e);
    }
    

    // Create the Action Items for this Goal
    if (actionsArray.length > 0) {
      const actionData = actionsArray.map((action: any, index: number) => {
        const actionDate = new Date();
        const parsedDay = parseInt(action.day);
        const dayOffset = isNaN(parsedDay) ? index : (parsedDay - 1);
        actionDate.setDate(actionDate.getDate() + dayOffset);
        return {
          goalId: goalId,
          title: action.title || `Day ${index + 1} task`,
          status: 'pending',
          dueDate: actionDate,
        };
      });
      await prisma.actionItem.createMany({ data: actionData });
    }
    
    // Update Blueprint to false
    const existingBlueprint = await prisma.goalBlueprint.findUnique({ where: { id: blueprintId } });
    if (existingBlueprint) {
      await prisma.goalBlueprint.update({
        where: { id: blueprintId },
        data: {
          fullJson: { 
            ...(existingBlueprint.fullJson as any),
            generatedText: aiText,
            isGenerating: false 
          }
        }
      });
    }
    console.log(`[BACKGROUND] Real Goal generated for Blueprint ${blueprintId}`);
  } catch (err) {
    console.error(`[BACKGROUND] Failed to generate blueprint for ID ${blueprintId}:`, err);
  }
}

// POST /api/ai/generate-onboarding
// Generates the 3 slides instantly, and kicks off the background task for the massive breakdown.
router.post('/generate-onboarding', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, title, description, detailedDescription, timeframe, category, priority, routine, personalization } = req.body;

    if (!title || !description) {
      res.status(400).json({ error: 'Title and description are required.' });
      return;
    }

    // 1. Permanently save the user's Goal to the Database immediately
    const newGoal = await prisma.goal.create({
      data: {
        userId,
        title,
        description,
        category,
        priority: priority || 'medium',
        startDate: new Date(),
      }
    });

    const prompt = `
You are the intelligence engine for GoalFlow.
Goal: "${title}"
Description: "${description}"

TASK 1: ONBOARDING SLIDES
Generate the data for the 3 onboarding swipeable slides in strict JSON format. Do not include markdown formatting or any other text.
{
  "slide1": { "title": "Achievability", "content": "..." },
  "slide2": { "title": "Statistics & Effort", "content": "..." },
  "slide3": { "title": "Your Journey Overview", "content": "..." }
}
`;

    const rawAiText = await callOpenRouter(prompt);
    
    // Safely extract the JSON block
    let slidesData = null;
    try {
      const startIndex = rawAiText.indexOf('{');
      const endIndex = rawAiText.lastIndexOf('}');
      if (startIndex !== -1 && endIndex !== -1) {
        const jsonStr = rawAiText.substring(startIndex, endIndex + 1);
        slidesData = JSON.parse(jsonStr);
      } else {
        slidesData = JSON.parse(rawAiText);
      }
    } catch (e) {
      console.warn("Failed to parse JSON slides cleanly, returning raw object");
      slidesData = { error: "Parse failed", raw: rawAiText };
    }

    // Save this empty/loading blueprint in the DB
    const blueprint = await prisma.goalBlueprint.create({
      data: {
        userId: userId,
        fullJson: { 
          isGenerating: true,
          slides: slidesData
        }, 
      },
    });

    // 🚀 Fire and Forget: Start the massive 3-minute background task!
    generateBlueprintInBackground(blueprint.id, newGoal.id, title, description, detailedDescription, timeframe, category, priority, routine, personalization, userId);

    // ⚡ Instantly return the slides to the Flutter app!
    res.status(200).json({ success: true, data: blueprint, slides: slidesData });
  } catch (error: any) {
    console.error(error);
    res.status(500).json({ error: 'Failed to generate onboarding flow.', details: error.message || String(error) });
  }
});

// POST /api/ai/generate-next-month
// Uses Context Injection to perfectly generate Month 2+
router.post('/generate-next-month', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, goalId, nextMonthNumber } = req.body;

    // 1. Fetch the Master Blueprint
    const blueprint = await prisma.goalBlueprint.findFirst({
      where: { userId: userId },
      orderBy: { createdAt: 'desc' }
    });

    // 2. Fetch completed actions from the previous month
    const completedActions = await prisma.actionItem.findMany({
      where: { goalId: goalId, status: 'completed' },
      select: { title: true }
    });

    const completedTitles = completedActions.map(a => a.title).join(", ");

    // 3. The MEGA-PROMPT (Context Injection)
    const prompt = `
You are a coaching AI. The user is currently executing their goal.
Here is the Master Blueprint we agreed on:
${JSON.stringify(blueprint?.fullJson)}

Here are the exact tasks the user has already completed successfully:
[${completedTitles}]

Based ONLY on this context, please generate the daily tasks for Month ${nextMonthNumber} (the next 30 days) without repeating any tasks they have already completed.
`;

    const newMonthData = await callOpenRouter(prompt);

    res.status(200).json({ success: true, newMonthData });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to generate next month.' });
  }
});

// POST /api/ai/generate-notification
// Analyzes user's preferred routine time, checks if today's task is completed, and generates intelligent contextual pushes
router.post('/generate-notification', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, timeSlot, phase } = req.body; 
    // timeSlot: 'morning' | 'afternoon' | 'evening'
    // phase: 'start' (6 AM / 12 PM), 'midpoint' (9 AM / 2 PM), 'window_closing' (11 AM / 4 PM), 'evening_overdue' (6 PM / 7 PM)

    // 1. Fetch user's active goals and actions
    const goals = await prisma.goal.findMany({
      where: { userId: userId || undefined },
      include: {
        actions: { orderBy: [{ dueDate: 'asc' }, { createdAt: 'asc' }] },
        milestones: { 
          include: { 
            actions: { orderBy: [{ dueDate: 'asc' }, { createdAt: 'asc' }] } 
          },
          orderBy: { createdAt: 'asc' }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 1
    });

    const activeGoal = goals[0];
    const goalTitle = activeGoal ? activeGoal.title : 'Personal Goal';
    const allActions = activeGoal ? [...activeGoal.actions, ...activeGoal.milestones.flatMap(m => m.actions)] : [];
    const completedCount = allActions.filter(a => a.status === 'completed').length;
    const totalCount = allActions.length;

    // Check today's action
    const now = new Date();
    const todayAction = allActions.find(a => {
      if (!a.dueDate) return true;
      const d = new Date(a.dueDate);
      return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate() === now.getDate();
    }) || allActions.find(a => a.status === 'pending') || allActions[0];

    const isTodayActionCompleted = todayAction ? todayAction.status === 'completed' : false;
    const actionTitle = todayAction ? todayAction.title : 'Focus on your daily goal';

    // Parse user's preferred time from routine
    let userPreferredTime = 'morning';
    if (activeGoal && activeGoal.routine) {
      try {
        const routineObj = typeof activeGoal.routine === 'string' ? JSON.parse(activeGoal.routine) : activeGoal.routine;
        const pref = (routineObj.preferredTime || '').toLowerCase();
        if (pref.includes('afternoon') || pref.includes('noon')) userPreferredTime = 'afternoon';
        else if (pref.includes('evening') || pref.includes('night')) userPreferredTime = 'evening';
      } catch (_) {}
    }

    const effectiveSlot = timeSlot || userPreferredTime;
    const currentPhase = phase || (timeSlot === 'midday' ? 'midpoint' : timeSlot === 'evening' ? 'evening_overdue' : 'start');

    // If already completed and user is in midday/closing/evening, send celebratory acknowledgement and stop reminders
    if (isTodayActionCompleted && currentPhase !== 'start') {
      res.status(200).json({
        success: true,
        notification: {
          title: `GoalFlow • Completed for Today!`,
          body: `Awesome work! You've already completed today's action for "${goalTitle}". Rest up and stay ready for tomorrow!`,
          timeSlot: effectiveSlot,
          timeLabel: 'Goal Completed',
          isCompleted: true,
          suppressFurtherPushes: true,
        }
      });
      return;
    }

    const phaseDescriptions: Record<string, string> = {
      start: 'Kickoff at start of preferred focus window (e.g. 6:00 AM / 12:00 PM)',
      midpoint: 'Mid-session momentum nudge (e.g. 9:00 AM / 2:00 PM)',
      window_closing: 'Final 1 hour warning before focus window closes (e.g. 11:00 AM / 4:30 PM)',
      evening_overdue: 'Overdue evening check-in (e.g. 6:00 PM / 7:00 PM) if task is still incomplete',
    };

    const prompt = `
You are the AI Coach for GoalFlow.
User's Goal: "${goalTitle}"
Today's Target Action: "${actionTitle}"
Today's Action Status: ${isTodayActionCompleted ? 'COMPLETED' : 'INCOMPLETE / PENDING'}
Overall Progress: ${completedCount} of ${totalCount} actions completed.
Notification Phase: ${phaseDescriptions[currentPhase] || currentPhase} (Focus Routine: ${effectiveSlot.toUpperCase()})

Task: Write a 1-to-2 sentence personalized push notification for this specific phase and completion status.
- If status is INCOMPLETE, create urgency and encouragement to complete "${actionTitle}".
- If phase is evening_overdue, remind them to take 15 minutes tonight to not break their streak.

Return strict JSON ONLY:
{
  "title": "GoalFlow • ${currentPhase === 'evening_overdue' ? 'Overdue Action Reminder' : (currentPhase === 'window_closing' ? 'Window Closing Soon' : (currentPhase === 'midpoint' ? 'Midday Momentum' : 'Morning Kickoff'))}",
  "body": "Your 1-2 sentence message here",
  "timeSlot": "${effectiveSlot}",
  "timeLabel": "${currentPhase === 'start' ? '6:00 AM Kickoff' : (currentPhase === 'midpoint' ? '9:00 AM Nudge' : (currentPhase === 'window_closing' ? '11:00 AM Alert' : '6:00 PM Wrap-up'))}",
  "isCompleted": ${isTodayActionCompleted},
  "suppressFurtherPushes": ${isTodayActionCompleted}
}
`;

    const rawAiText = await callOpenRouter(prompt);
    let notificationData = null;
    try {
      const startIndex = rawAiText.indexOf('{');
      const endIndex = rawAiText.lastIndexOf('}');
      if (startIndex !== -1 && endIndex !== -1) {
        notificationData = JSON.parse(rawAiText.substring(startIndex, endIndex + 1));
      } else {
        notificationData = JSON.parse(rawAiText);
      }
    } catch (_) {
      notificationData = {
        title: `GoalFlow • ${currentPhase.toUpperCase()}`,
        body: isTodayActionCompleted 
          ? `Great job on "${goalTitle}" today! Keep up the great consistency.` 
          : `Friendly nudge: Complete "${actionTitle}" today to maintain your progress on "${goalTitle}".`,
        timeSlot: effectiveSlot,
        timeLabel: currentPhase,
        isCompleted: isTodayActionCompleted,
        suppressFurtherPushes: isTodayActionCompleted
      };
    }

    res.status(200).json({ success: true, notification: notificationData });
  } catch (error: any) {
    console.error("Failed to generate AI notification:", error);
    res.status(500).json({ error: 'Failed to generate notification', details: error.message || String(error) });
  }
});

// POST /api/ai/synthesize-reflection
// Synthesizes the user's weekly self-reflection answers + goal progress into an intelligent AI Journey Echo
router.post('/synthesize-reflection', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, well, difficult, improve } = req.body;

    // Fetch user's goals & actions for rich context
    const goals = await prisma.goal.findMany({
      where: { userId: userId || undefined },
      include: {
        actions: true,
        milestones: { include: { actions: true } }
      },
      orderBy: { createdAt: 'desc' },
      take: 1
    });

    const activeGoal = goals[0];
    const goalTitle = activeGoal ? activeGoal.title : 'My Personal Goal';
    const category = activeGoal ? activeGoal.category : 'General';
    const allActions = activeGoal ? [...activeGoal.actions, ...activeGoal.milestones.flatMap(m => m.actions)] : [];
    const completedActions = allActions.filter(a => a.status === 'completed');
    const completedTitles = completedActions.map(a => a.title).join(", ") || "Started daily habits";

    const prompt = `
You are the AI Journey Synthesizer and Master Coach for GoalFlow.
Goal: "${goalTitle}" (${category})
Completed Actions This Week: [${completedTitles}]

User's Raw Weekly Reflection:
- Wins & Progress: "${well || 'Maintained routine'}"
- Struggles & Roadblocks: "${difficult || 'Time management and fatigue'}"
- Commitment for Next Week: "${improve || 'Wake up earlier and focus on consistency'}"

TASK:
Synthesize this into a cohesive, deeply insightful 2-paragraph "Journey Echo" written in an encouraging, analytical AI coach voice.
1. In the first paragraph, analyze and celebrate their momentum, referencing their specific wins.
2. In the second paragraph, provide tactical psychological advice to overcome the stated difficulty and formulate an actionable strategy for next week.

Output MUST be strict JSON ONLY with NO markdown formatting:
{
  "summary": "Your synthesized 2-paragraph reflection text here..."
}
`;

    const rawAiText = await callOpenRouter(prompt);
    let summaryText = "";
    try {
      const startIndex = rawAiText.indexOf('{');
      const endIndex = rawAiText.lastIndexOf('}');
      if (startIndex !== -1 && endIndex !== -1) {
        const parsed = JSON.parse(rawAiText.substring(startIndex, endIndex + 1));
        summaryText = parsed.summary || rawAiText;
      } else {
        const parsed = JSON.parse(rawAiText);
        summaryText = parsed.summary || rawAiText;
      }
    } catch (_) {
      summaryText = rawAiText.replace(/^```json\s*/, '').replace(/```$/, '').trim();
    }

    res.status(200).json({ success: true, summary: summaryText });
  } catch (error: any) {
    console.error("Failed to synthesize reflection:", error);
    res.status(500).json({ error: 'Failed to synthesize reflection', details: error.message || String(error) });
  }
});

// POST /api/ai/action-briefing
// Generates a 4-point structured AI briefing and drill guide for today's primary focus action
router.post('/action-briefing', async (req: Request, res: Response): Promise<void> => {
  try {
    const { actionTitle, goalTitle, category, description } = req.body;

    const targetAction = actionTitle || 'Daily Focus Practice';
    const targetGoal = goalTitle || 'Personal Goal Mastery';

    const prompt = `
You are the AI Master Coach for GoalFlow.
Goal: "${targetGoal}" (${category || 'General'})
Today's Primary Focus Task: "${targetAction}"
Context: ${description || 'Daily disciplined skill building'}

Task: Generate a high-impact, actionable 4-point briefing for the user on how to approach and master today's action.
Provide exactly 4 structured, insightful points:
1. 🎯 Purpose & Core Objective: Why this specific task is pivotal today.
2. ⚡ Key Techniques & Observation Points: 2-3 precise physical or cognitive nuances to focus on.
3. 📝 Concrete Practice Drill: A direct 10-15 minute actionable drill to implement right now.
4. 💡 Coach's Pro-Tip: A mental model or mindset trigger to maximize retention.

Output MUST be strict JSON ONLY with NO markdown formatting:
{
  "actionTitle": "${targetAction}",
  "points": [
    "🎯 Purpose & Objective: ...",
    "⚡ Key Techniques: ...",
    "📝 Concrete Practice Drill: ...",
    "💡 Coach's Pro-Tip: ..."
  ]
}
`;

    const rawAiText = await callOpenRouter(prompt);
    let briefingData = null;
    try {
      const startIndex = rawAiText.indexOf('{');
      const endIndex = rawAiText.lastIndexOf('}');
      if (startIndex !== -1 && endIndex !== -1) {
        briefingData = JSON.parse(rawAiText.substring(startIndex, endIndex + 1));
      } else {
        briefingData = JSON.parse(rawAiText);
      }
    } catch (_) {
      briefingData = {
        actionTitle: targetAction,
        points: [
          `🎯 Purpose & Objective: Build foundational muscle memory and habit consistency toward "${targetGoal}".`,
          `⚡ Key Techniques: Focus on deliberate form, eliminating distractions, and tracking your exact completion time.`,
          `📝 Concrete Practice Drill: Dedicate 15 undisturbed minutes to execute "${targetAction}" thoroughly.`,
          `💡 Coach's Pro-Tip: Consistency beats intensity. Focus on completing today's single step with full presence.`
        ]
      };
    }

    res.status(200).json({ success: true, briefing: briefingData });
  } catch (error: any) {
    console.error("Failed to generate action briefing:", error);
    res.status(500).json({ error: 'Failed to generate briefing', details: error.message || String(error) });
  }
});

export default router;
