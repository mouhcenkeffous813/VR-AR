-- ============================================
-- SUPABASE DATABASE SCHEMA
-- ============================================
-- Run these SQL queries in your Supabase SQL Editor
-- ============================================

-- ==================== USER PROFILES TABLE ====================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  email TEXT NOT NULL,
  full_name TEXT,
  username TEXT,
  avatar_url TEXT,
  points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policies for user_profiles
CREATE POLICY "Users can view all profiles"
  ON user_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- ==================== OPPORTUNITIES TABLE ====================
CREATE TABLE IF NOT EXISTS opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company TEXT NOT NULL,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Exchange Programs', 'Internships', 'Volunteering', 'Projects')),
  tags TEXT[] DEFAULT '{}',
  image TEXT,
  description TEXT,
  logo_color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

-- Policies for opportunities
CREATE POLICY "Anyone can view opportunities"
  ON opportunities FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create opportunities"
  ON opportunities FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update opportunities"
  ON opportunities FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete opportunities"
  ON opportunities FOR DELETE
  USING (auth.role() = 'authenticated');

-- ==================== PROJECTS TABLE ====================
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  collaborators TEXT DEFAULT '0/0 Collaborators',
  image_path TEXT,
  location TEXT,
  duration TEXT,
  start_date TEXT,
  skills_required TEXT[] DEFAULT '{}',
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Policies for projects
CREATE POLICY "Anyone can view projects"
  ON projects FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create projects"
  ON projects FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Project creators can update their projects"
  ON projects FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Project creators can delete their projects"
  ON projects FOR DELETE
  USING (auth.uid() = created_by);

-- ==================== PROJECT PARTICIPANTS TABLE ====================
CREATE TABLE IF NOT EXISTS project_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE project_participants ENABLE ROW LEVEL SECURITY;

-- Policies for project_participants
CREATE POLICY "Anyone can view project participants"
  ON project_participants FOR SELECT
  USING (true);

CREATE POLICY "Users can join projects"
  ON project_participants FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave projects"
  ON project_participants FOR DELETE
  USING (auth.uid() = user_id);
-- ==================== BOOKMARKS TABLE ====================
CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  opportunity_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, opportunity_id)
);

-- Enable Row Level Security
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

-- Policies for bookmarks
CREATE POLICY "Users can view their own bookmarks"
  ON bookmarks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookmarks"
  ON bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bookmarks"
  ON bookmarks FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== FUNCTION TO UPDATE UPDATED_AT ====================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to automatically update updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_opportunities_updated_at BEFORE UPDATE ON opportunities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==================== FUNCTION TO CREATE USER PROFILE ON SIGNUP ====================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, points)
  VALUES (NEW.id, NEW.email, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==================== INSERT SAMPLE DATA (OPTIONAL) ====================
-- You can run this to insert sample opportunities

INSERT INTO opportunities (company, title, location, type, tags, image, description, logo_color) VALUES
('Yassir', 'Marketing Intern', 'Algiers, Algeria', 'Internships', ARRAY['Remote', 'Part-time', 'Paid'], 'images/yassir.jpeg', 'Join our marketing team and gain valuable experience', '#1B5E20'),
('The University of Tokyo', 'Master in Computer Science', 'Japan, Tokyo', 'Exchange Programs', ARRAY['On-site', 'Full-time', 'Paid'], NULL, 'Pursue your masters degree at one of the top universities', '#1976D2'),
('Ooredoo', 'Community Manager Volunteer', 'Oran, Algeria', 'Volunteering', ARRAY['On-site', 'Volunteering'], 'images/ooredo.jpeg', 'Help manage our community and make a difference', NULL),
('Djezzy', 'Frontend Developer Project', 'Remote', 'Projects', ARRAY['Collaboration', 'React', 'Portfolio'], 'images/djezzy.jpeg', 'Work on exciting frontend projects and build your portfolio', '#1B5E20'),
('Algerie telecom', 'Backend Developer Project', 'Constantine, Algeria', 'Projects', ARRAY['Remote', 'Node.js', 'Portfolio'], 'images/algerietelc.jpeg', 'Develop backend solutions and enhance your skills', '#7B1FA2')
ON CONFLICT DO NOTHING;