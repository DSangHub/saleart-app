'use client';

import { useState } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || '',
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''
);

export default function Home() {
  const [text, setText] = useState('SALE');
  const [status, setStatus] = useState('');

  async function sendMessage() {
    setStatus('Saving...');
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setStatus('Please sign in first');
      return;
    }

    // Example: insert message (device_id would come from selected device)
    const { error } = await supabase.from('messages').insert({
      user_id: user.id,
      text,
      status: 'pending',
    });

    setStatus(error ? error.message : 'Message saved. Ready to push to sign.');
  }

  return (
    <main style={{ fontFamily: 'system-ui', padding: '2rem', maxWidth: 600, margin: '0 auto' }}>
      <h1>SaleArt.app</h1>
      <p>Type a message for your e-ink sign.</p>
      <input
        value={text}
        onChange={(e) => setText(e.target.value)}
        style={{ fontSize: '1.5rem', padding: '0.5rem', width: '100%', margin: '1rem 0' }}
        maxLength={20}
      />
      <button onClick={sendMessage} style={{ padding: '0.75rem 1.5rem', fontSize: '1rem' }}>
        Save & Prepare Update
      </button>
      <p>{status}</p>
      <p style={{ color: '#666', marginTop: '2rem' }}>
        Connect Supabase env vars, then pair a device and push via NFC/BLE.
      </p>
    </main>
  );
}
