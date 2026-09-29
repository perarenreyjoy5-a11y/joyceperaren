import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY } from './supabase-config.js';

export const isSupabaseConfigured =
    SUPABASE_URL.startsWith('https://') &&
    !SUPABASE_URL.includes('PASTE_') &&
    SUPABASE_PUBLISHABLE_KEY.length > 20 &&
    !SUPABASE_PUBLISHABLE_KEY.includes('PASTE_');

export const supabase = isSupabaseConfigured
    ? createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)
    : null;
