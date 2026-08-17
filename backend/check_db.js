const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkDatabase() {
  console.log("Checking Users...");
  const users = await prisma.user.findMany();
  console.log(`Found ${users.length} users:`, users.map(u => u.email));

  console.log("\nChecking Goal Blueprints...");
  const blueprints = await prisma.goalBlueprint.findMany();
  console.log(`Found ${blueprints.length} blueprints.`);
  if (blueprints.length > 0) {
    console.log("Latest blueprint generating status:", blueprints[blueprints.length-1].fullJson?.isGenerating);
  }

  console.log("\nChecking Goals...");
  const goals = await prisma.goal.findMany({ include: { actions: true } });
  console.log(`Found ${goals.length} goals.`);
  
  if (goals.length > 0) {
    console.log(`Latest Goal: "${goals[goals.length-1].title}" by User ID: ${goals[goals.length-1].userId}`);
    console.log(`Total Actions for latest goal: ${goals[goals.length-1].actions.length}`);
    if (goals[goals.length-1].actions.length > 0) {
        console.log(`Sample Action: ${goals[goals.length-1].actions[0].title}`);
    }
  }

  await prisma.$disconnect();
}

checkDatabase().catch(console.error);
