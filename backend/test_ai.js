require('dotenv').config();

async function testGemma() {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    console.error("No OPENROUTER_API_KEY found in .env");
    return;
  }

  const prompt = `
You are the intelligence engine for GoalFlow, an advanced productivity app.
A user has submitted the following complex goal during onboarding:
Goal: "Build a functioning solar-powered remote control airplane from scratch."
Timeframe: 5 months
Experience Level: Beginner

TASK 1: ONBOARDING SLIDES
Generate the data for the 3 onboarding swipeable slides in strict JSON format:
{
  "slide1": { "title": "Achievability", "content": "..." },
  "slide2": { "title": "Statistics & Effort", "content": "..." },
  "slide3": { "title": "Your Journey Overview", "content": "..." }
}

TASK 2: THE 5-MONTH BLUEPRINT
Generate a day-by-day plan for the entire 5 months (approx 150 days). 
Due to token limits, provide a high-level summary of Months 1-4, but give a strict DAY-BY-DAY breakdown for the first 2 weeks (Days 1-14) to prove you can generate daily actionable tasks.

Format your entire response cleanly.
`;

  console.log("# AI Answer Goal - Gemma Model Evaluation\n");
  console.log("## The Strict Prompt Sent:\n```text\n" + prompt + "\n```\n");
  console.log("## Model Response:\n");

  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "google/gemma-4-26b-a4b-it:free",
        messages: [{ role: "user", content: prompt }]
      })
    });

    const data = await response.json();
    if (data.choices && data.choices.length > 0) {
      console.log(data.choices[0].message.content);
    } else {
      console.error("Error from OpenRouter:", JSON.stringify(data, null, 2));
    }
  } catch (err) {
    console.error("Fetch error:", err);
  }
}

testGemma();
