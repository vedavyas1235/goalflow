import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import crypto from 'crypto';

const router = Router();
const prisma = new PrismaClient();

// Simple but secure hash using built-in Node crypto (no extra package needed)
function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password + 'goalflow_salt_2024').digest('hex');
}

function verifyPassword(inputPassword: string, storedHash: string): boolean {
  return hashPassword(inputPassword) === storedHash;
}

// POST /api/auth/register
router.post('/register', async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, name, password } = req.body;

    if (!email || !name || !password) {
      res.status(400).json({ error: 'Name, email, and password are required' });
      return;
    }

    if (password.length < 6) {
      res.status(400).json({ error: 'Password must be at least 6 characters' });
      return;
    }

    // Check if user already exists
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      res.status(400).json({ error: 'An account with this email already exists' });
      return;
    }

    // Hash password before storing
    const hashedPassword = hashPassword(password);

    const user = await prisma.user.create({
      data: { email, name, password: hashedPassword },
      select: { id: true, name: true, email: true, createdAt: true }, // Never return password
    });

    res.status(201).json({ message: 'Registration successful', user });
  } catch (error) {
    console.error('Registration Error:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

// POST /api/auth/login
router.post('/login', async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ error: 'Email and password are required' });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      res.status(401).json({ error: 'No account found with this email' });
      return;
    }

    // If user has no password (legacy account), require re-registration
    if (!user.password) {
      res.status(401).json({ error: 'Please register again to set your password' });
      return;
    }

    // Verify password
    if (!verifyPassword(password, user.password)) {
      res.status(401).json({ error: 'Incorrect password' });
      return;
    }

    // Login success — never return the password hash
    const { password: _, ...safeUser } = user;
    res.status(200).json({ message: 'Login successful', user: safeUser });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

export default router;
