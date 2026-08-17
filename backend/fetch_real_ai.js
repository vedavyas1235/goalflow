const fs = require('fs');
require('dotenv').config();

async function run() {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    console.error("No OPENROUTER_API_KEY found in .env");
    return;
  }

  const prompt = `You are the intelligence engine for GoalFlow.
A user has submitted the following goal:
Goal: "Build a functioning solar-powered remote control airplane from scratch."
Description: "I want to learn aerodynamics and electronics to build a sustainable RC plane."
Timeframe: 5 months
Category: Engineering

TASK 1: ONBOARDING SLIDES
Generate the data for the 3 onboarding swipeable slides in strict JSON format.
{
  "slide1": { "title": "Achievability", "content": "..." },
  "slide2": { "title": "Statistics & Effort", "content": "..." },
  "slide3": { "title": "Your Journey Overview", "content": "..." }
}

TASK 2: THE MASTER BLUEPRINT
Generate a day-by-day plan. Provide a high-level summary of all months, but give a strict DAY-BY-DAY breakdown for ONLY the first 30 days to avoid token limits.
Format cleanly.`;

  console.log("Fetching from OpenRouter...");
  try {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:3000",
        "X-Title": "GoalFlow",
      },
      body: JSON.stringify({
        model: "cohere/north-mini-code:free",
        messages: [{ role: "user", content: prompt }]
      })
    });
    
    const data = await response.json();
    console.log("Response received!");
    
    let mdContent = `# Real OpenRouter Output\n\n`;
    if (data.error) {
      mdContent += `## API Error:\n\n\`\`\`json\n${JSON.stringify(data.error, null, 2)}\n\`\`\``;
    } else {
      mdContent += `## Generated Response:\n\n\`\`\`text\n${data.choices[0].message.content}\n\`\`\``;
    }
    
    fs.writeFileSync('C:\\Users\\vedav\\.gemini\\antigravity-ide\\brain\\fa8a56bd-f470-454b-838d-46d6c82025c4\\cohere_test_output.md', mdContent);
    console.log("Saved to cohere_test_output.md");
  } catch (err) {
    console.error("Fetch failed:", err);
  }
}

run();
