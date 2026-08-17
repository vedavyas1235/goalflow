import app from '../backend/src/server';

export default function handler(req: any, res: any) {
  try {
    return app(req, res);
  } catch (err: any) {
    res.status(500).json({
      error: 'Serverless Handler Error',
      message: err?.message || String(err),
      stack: err?.stack,
    });
  }
}
