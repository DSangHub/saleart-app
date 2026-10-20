import { NextResponse } from 'next/server';

// Simple payload generator for e-ink signs
// Call with: POST /api/payload { text, font, color }
export async function POST(request) {
  try {
    const body = await request.json();
    const { text = 'SALE', font = 'bold', color = 'black' } = body;

    // Compact payload the PWA or device can consume
    const payload = {
      text: String(text).slice(0, 20).toUpperCase(),
      font,
      color,
      timestamp: new Date().toISOString(),
      version: 1,
    };

    return NextResponse.json({ ok: true, payload });
  } catch (err) {
    return NextResponse.json({ ok: false, error: err.message }, { status: 400 });
  }
}

export async function GET() {
  return NextResponse.json({ status: 'SaleArt payload endpoint ready' });
}
