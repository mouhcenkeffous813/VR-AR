-- ============================================
-- IDEAS EXPO QUESTIONS SCHEMA
-- ============================================
-- Run these SQL queries in your Supabase SQL Editor
-- ============================================

-- ==================== IDEAS EXPO QUESTIONS TABLE ====================
CREATE TABLE IF NOT EXISTS ideas_expo_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  question TEXT NOT NULL,
  replies INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE ideas_expo_questions ENABLE ROW LEVEL SECURITY;

-- Policies for ideas_expo_questions
DROP POLICY IF EXISTS "Anyone can view questions" ON ideas_expo_questions;
CREATE POLICY "Anyone can view questions"
  ON ideas_expo_questions FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create questions" ON ideas_expo_questions;
CREATE POLICY "Authenticated users can create questions"
  ON ideas_expo_questions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own questions" ON ideas_expo_questions;
CREATE POLICY "Users can update their own questions"
  ON ideas_expo_questions FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own questions" ON ideas_expo_questions;
CREATE POLICY "Users can delete their own questions"
  ON ideas_expo_questions FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== TRIGGER ====================
-- Trigger to update updated_at
DROP TRIGGER IF EXISTS update_ideas_expo_questions_updated_at ON ideas_expo_questions;
CREATE TRIGGER update_ideas_expo_questions_updated_at 
  BEFORE UPDATE ON ideas_expo_questions
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- ==================== INSERT SAMPLE DATA (OPTIONAL) ====================
-- You can run this to insert sample questions (replace user_id with actual user IDs)

-- Note: Sample data will be inserted through the app when users create questions

