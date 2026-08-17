import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// CREATE a new goal (with optional milestones and actions)
router.post('/', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, title, description, category, priority, startDate, targetDate, routine } = req.body;

    if (!userId || !title || !description || !category || !startDate) {
      res.status(400).json({ error: 'Missing required fields' });
      return;
    }

    const newGoal = await prisma.goal.create({
      data: {
        userId,
        title,
        description,
        category,
        priority: priority || 'medium',
        startDate: new Date(startDate),
        targetDate: targetDate ? new Date(targetDate) : null,
        routine: routine || null,
      },
      include: {
        milestones: true,
        actions: true,
      }
    });

    res.status(201).json(newGoal);
  } catch (error) {
    console.error("Error creating goal:", error);
    res.status(500).json({ error: 'Failed to create goal' });
  }
});

// GET all goals for a specific user
router.get('/user/:userId', async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;

    const goals = await prisma.goal.findMany({
      where: { userId },
      include: {
        milestones: {
          include: {
            actions: {
              orderBy: [{ dueDate: 'asc' }, { createdAt: 'asc' }]
            }
          },
          orderBy: { createdAt: 'asc' }
        },
        actions: {
          where: { milestoneId: null },
          orderBy: [{ dueDate: 'asc' }, { createdAt: 'asc' }]
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json(goals);
  } catch (error) {
    console.error("Error fetching goals:", error);
    res.status(500).json({ error: 'Failed to fetch goals' });
  }
});

// GET a specific goal by ID
router.get('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    const goal = await prisma.goal.findUnique({
      where: { id },
      include: {
        milestones: {
          include: { actions: true }
        },
        actions: {
          where: { milestoneId: null } 
        }
      }
    });

    if (!goal) {
      res.status(404).json({ error: 'Goal not found' });
      return;
    }

    res.status(200).json(goal);
  } catch (error) {
    console.error("Error fetching goal:", error);
    res.status(500).json({ error: 'Failed to fetch goal' });
  }
});

// UPDATE a goal
router.put('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Convert date strings to Date objects if provided
    if (updateData.startDate) updateData.startDate = new Date(updateData.startDate);
    if (updateData.targetDate) updateData.targetDate = new Date(updateData.targetDate);

    const updatedGoal = await prisma.goal.update({
      where: { id },
      data: updateData,
    });

    res.status(200).json(updatedGoal);
  } catch (error) {
    console.error("Error updating goal:", error);
    res.status(500).json({ error: 'Failed to update goal' });
  }
});

// DELETE a goal (Cascade will delete milestones and actions automatically)
router.delete('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;

    await prisma.goal.delete({
      where: { id },
    });

    res.status(200).json({ message: 'Goal deleted successfully' });
  } catch (error) {
    console.error("Error deleting goal:", error);
    res.status(500).json({ error: 'Failed to delete goal' });
  }
});

// PATCH /:id (for /api/actions/:id) and PATCH /actions/:id (for /api/goals/actions/:id)
router.patch('/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      res.status(400).json({ error: 'Status is required' });
      return;
    }

    const updated = await prisma.actionItem.update({
      where: { id },
      data: { status },
    });

    console.log(`[ACTION UPDATED] ID ${id} -> status: ${status}`);
    res.status(200).json(updated);
  } catch (error) {
    console.error("Error updating action status:", error);
    res.status(500).json({ error: 'Failed to update action status' });
  }
});

router.patch('/actions/:id', async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      res.status(400).json({ error: 'Status is required' });
      return;
    }

    const updated = await prisma.actionItem.update({
      where: { id },
      data: { status },
    });

    console.log(`[ACTION UPDATED] ID ${id} -> status: ${status}`);
    res.status(200).json(updated);
  } catch (error) {
    console.error("Error updating action status:", error);
    res.status(500).json({ error: 'Failed to update action status' });
  }
});

// POST /api/goals/:goalId/milestones — Create a milestone for a goal
router.post('/:goalId/milestones', async (req: Request, res: Response): Promise<void> => {
  try {
    const { goalId } = req.params;
    const { title } = req.body;

    if (!title) {
      res.status(400).json({ error: 'Title is required' });
      return;
    }

    const milestone = await prisma.milestone.create({
      data: { goalId, title },
    });

    res.status(201).json(milestone);
  } catch (error) {
    console.error("Error creating milestone:", error);
    res.status(500).json({ error: 'Failed to create milestone' });
  }
});

// POST /api/goals/:goalId/actions — Create a manual action for a goal
router.post('/:goalId/actions', async (req: Request, res: Response): Promise<void> => {
  try {
    const { goalId } = req.params;
    const { title, priority, milestoneId } = req.body;

    if (!title) {
      res.status(400).json({ error: 'Title is required' });
      return;
    }

    const action = await prisma.actionItem.create({
      data: {
        goalId,
        title,
        priority: priority || 'medium',
        status: 'upcoming',
        ...(milestoneId ? { milestoneId } : {}),
      },
    });

    res.status(201).json(action);
  } catch (error) {
    console.error("Error creating action:", error);
    res.status(500).json({ error: 'Failed to create action' });
  }
});

export default router;
