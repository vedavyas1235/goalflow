import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

import authRoutes from './routes/auth';
import goalRoutes from './routes/goals';
import aiRoutes from './routes/ai';

// Health Check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', message: 'GoalFlow API is running on Vercel!' });
});
app.get('/api/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', message: 'GoalFlow API is running on Vercel!' });
});

// Root route
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', name: 'GoalFlow Backend API', version: '1.0.0' });
});
app.get('/api', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', name: 'GoalFlow Backend API', version: '1.0.0' });
});

// API Routes (Mounted on both /api and root for any Vercel rewrite configuration)
app.use('/api/auth', authRoutes);
app.use('/api/goals', goalRoutes);
app.use('/api/actions', goalRoutes); // Action endpoints (PATCH /api/actions/:id)
app.use('/api/ai', aiRoutes);

app.use('/auth', authRoutes);
app.use('/goals', goalRoutes);
app.use('/actions', goalRoutes);
app.use('/ai', aiRoutes);

if (process.env.NODE_ENV !== 'production' && !process.env.VERCEL) {
  app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
  });
}

export default app;
