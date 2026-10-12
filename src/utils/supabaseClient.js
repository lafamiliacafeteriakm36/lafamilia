import { createClient } from '@supabase/supabase-js';

// Credenciales exclusivas para LA FAMILIA
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://bhqauxajwpcrfznxatzz.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJocWF1eGFqd3BjcmZ6bnhhdHp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4MzQ2MjgsImV4cCI6MjEwNzQxMDYyOH0.5fk5dzIKVF3YyewKISwSZLNefTY_9ItZRCYLAcyiPy0';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export const safeStorageSet = (key, value) => {
    try {
        localStorage.setItem(key, value);
    } catch (e) {
        console.warn(`[SafeStorage] Quota exceeded for ${key}`, e);
    }
};
