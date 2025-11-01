-- ============================================
-- SUGGESTIONS SCHEMA
-- ============================================
-- Run these SQL queries in your Supabase SQL Editor
-- ============================================

-- ==================== SUGGESTIONS TABLE ====================
CREATE TABLE IF NOT EXISTS suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;

-- Policies for suggestions
DROP POLICY IF EXISTS "Anyone can view suggestions" ON suggestions;
CREATE POLICY "Anyone can view suggestions"
  ON suggestions FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create suggestions" ON suggestions;
CREATE POLICY "Authenticated users can create suggestions"
  ON suggestions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own suggestions" ON suggestions;
CREATE POLICY "Users can update their own suggestions"
  ON suggestions FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own suggestions" ON suggestions;
CREATE POLICY "Users can delete their own suggestions"
  ON suggestions FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== TRIGGER ====================
-- Trigger to update updated_at
DROP TRIGGER IF EXISTS update_suggestions_updated_at ON suggestions;
CREATE TRIGGER update_suggestions_updated_at 
  BEFORE UPDATE ON suggestions
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

