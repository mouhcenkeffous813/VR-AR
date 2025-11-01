-- ============================================
-- FIX BOOKMARKS TABLE - Run this in Supabase SQL Editor
-- ============================================
-- This will change opportunity_id from UUID to TEXT
-- so it can accept both numeric IDs and UUIDs

-- Step 1: Drop the table if it exists and recreate it
DROP TABLE IF EXISTS bookmarks CASCADE;

-- Step 2: Create bookmarks table with TEXT for opportunity_id
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  opportunity_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, opportunity_id)
);

-- Step 3: Enable Row Level Security
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

-- Step 4: Create policies
CREATE POLICY "Users can view their own bookmarks"
  ON bookmarks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookmarks"
  ON bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bookmarks"
  ON bookmarks FOR DELETE
  USING (auth.uid() = user_id);
