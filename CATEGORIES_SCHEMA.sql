-- ============================================
-- CATEGORIES AND EVENTS SCHEMA
-- ============================================
-- Run these SQL queries in your Supabase SQL Editor
-- ============================================

-- ==================== CATEGORIES TABLE ====================
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  icon_name TEXT NOT NULL,
  icon_color TEXT DEFAULT '#194CBF',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Policies for categories
DROP POLICY IF EXISTS "Anyone can view categories" ON categories;
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create categories" ON categories;
CREATE POLICY "Authenticated users can create categories"
  ON categories FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- ==================== EVENTS TABLE ====================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('Workshop', 'Event', 'Lecture')),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_time TIME NOT NULL,
  color TEXT DEFAULT '#194CBF',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policies for events
DROP POLICY IF EXISTS "Anyone can view events" ON events;
CREATE POLICY "Anyone can view events"
  ON events FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create events" ON events;
CREATE POLICY "Authenticated users can create events"
  ON events FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can update events" ON events;
CREATE POLICY "Authenticated users can update events"
  ON events FOR UPDATE
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can delete events" ON events;
CREATE POLICY "Authenticated users can delete events"
  ON events FOR DELETE
  USING (auth.role() = 'authenticated');

-- ==================== ENROLLMENTS TABLE ====================
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE NOT NULL,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, event_id)
);

-- Enable Row Level Security
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;

-- Policies for enrollments
DROP POLICY IF EXISTS "Users can view their own enrollments" ON enrollments;
CREATE POLICY "Users can view their own enrollments"
  ON enrollments FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view all enrollments" ON enrollments;
CREATE POLICY "Users can view all enrollments"
  ON enrollments FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can create their own enrollments" ON enrollments;
CREATE POLICY "Users can create their own enrollments"
  ON enrollments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own enrollments" ON enrollments;
CREATE POLICY "Users can delete their own enrollments"
  ON enrollments FOR DELETE
  USING (auth.uid() = user_id);

-- ==================== TRIGGERS ====================
-- Trigger to update updated_at for categories
DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at 
  BEFORE UPDATE ON categories
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update updated_at for events
DROP TRIGGER IF EXISTS update_events_updated_at ON events;
CREATE TRIGGER update_events_updated_at 
  BEFORE UPDATE ON events
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- ==================== INSERT CATEGORIES ====================
INSERT INTO categories (name, icon_name, icon_color) VALUES
('Sport Activities', 'sports_soccer', '#194CBF'),
('Digital Design Lab', 'design_services', '#194CBF'),
('Robotics Garage', 'memory', '#194CBF'),
('Dev Room', 'code', '#194CBF'),
('Innovation Space', 'lightbulb', '#194CBF'),
('Startup Corner', 'business', '#194CBF'),
('Library', 'library_books', '#194CBF'),
('Creative Media', 'videocam', '#194CBF')
ON CONFLICT (name) DO NOTHING;

-- ==================== INSERT SAMPLE EVENTS ====================
-- Note: These will be inserted after categories are created
-- You may need to adjust the category_ids based on your actual data

-- Sport Activities Events
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Basketball Tournament', 'Join the annual youth basketball championship', 
       CURRENT_DATE + INTERVAL '5 days', '10:00:00', '#194CBF'
FROM categories WHERE name = 'Sport Activities'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Fitness Training Session', 
       'Learn proper exercise techniques and workout routines',
       CURRENT_DATE + INTERVAL '3 days', '17:00:00', '#10B981'
FROM categories WHERE name = 'Sport Activities'
ON CONFLICT DO NOTHING;

-- Digital Design Lab Events
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'UI/UX Design Basics',
       'Introduction to user interface and experience design',
       CURRENT_DATE + INTERVAL '4 days', '13:00:00', '#8B5CF6'
FROM categories WHERE name = 'Digital Design Lab'
ON CONFLICT DO NOTHING;

-- Dev Room Events
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Flutter Development Bootcamp',
       'Learn mobile app development with Flutter',
       CURRENT_DATE + INTERVAL '4 days', '09:00:00', '#194CBF'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

-- Add more events as needed...

