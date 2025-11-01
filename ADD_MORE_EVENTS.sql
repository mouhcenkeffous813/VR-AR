-- ============================================
-- ADD MORE EVENTS TO CATEGORIES
-- ============================================
-- Run this SQL in your Supabase SQL Editor
-- This adds more events to all categories
-- ============================================

-- ==================== SPORT ACTIVITIES EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Football Championship', 'Annual youth football tournament with teams from different regions', 
       CURRENT_DATE + INTERVAL '7 days', '14:00:00', '#10B981'
FROM categories WHERE name = 'Sport Activities'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Swimming Techniques', 'Learn advanced swimming techniques and safety', 
       CURRENT_DATE + INTERVAL '6 days', '16:00:00', '#06B6D4'
FROM categories WHERE name = 'Sport Activities'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Sports Nutrition', 'Learn about proper nutrition for athletes and active youth', 
       CURRENT_DATE + INTERVAL '8 days', '15:00:00', '#F59E0B'
FROM categories WHERE name = 'Sport Activities'
ON CONFLICT DO NOTHING;

-- ==================== DIGITAL DESIGN LAB EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Adobe Photoshop Masterclass', 'Master photo editing and digital design with Photoshop', 
       CURRENT_DATE + INTERVAL '5 days', '10:00:00', '#8B5CF6'
FROM categories WHERE name = 'Digital Design Lab'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Figma Design Workshop', 'Create beautiful interfaces using Figma design tools', 
       CURRENT_DATE + INTERVAL '6 days', '14:00:00', '#EC4899'
FROM categories WHERE name = 'Digital Design Lab'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Design Thinking Process', 'Learn the design thinking methodology for creative problem solving', 
       CURRENT_DATE + INTERVAL '9 days', '11:00:00', '#6366F1'
FROM categories WHERE name = 'Digital Design Lab'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Design Portfolio Review', 'Get feedback on your design portfolio from industry experts', 
       CURRENT_DATE + INTERVAL '10 days', '13:00:00', '#A855F7'
FROM categories WHERE name = 'Digital Design Lab'
ON CONFLICT DO NOTHING;

-- ==================== ROBOTICS GARAGE EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Arduino Basics', 'Introduction to Arduino programming and robotics', 
       CURRENT_DATE + INTERVAL '5 days', '09:00:00', '#14B8A6'
FROM categories WHERE name = 'Robotics Garage'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Robot Building Challenge', 'Build and program your own robot in this hands-on workshop', 
       CURRENT_DATE + INTERVAL '7 days', '10:00:00', '#0D9488'
FROM categories WHERE name = 'Robotics Garage'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'AI and Machine Learning Intro', 'Introduction to artificial intelligence and machine learning concepts', 
       CURRENT_DATE + INTERVAL '8 days', '15:00:00', '#0891B2'
FROM categories WHERE name = 'Robotics Garage'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Robotics Competition', 'Competition to build the best autonomous robot', 
       CURRENT_DATE + INTERVAL '12 days', '10:00:00', '#06B6D4'
FROM categories WHERE name = 'Robotics Garage'
ON CONFLICT DO NOTHING;

-- ==================== DEV ROOM EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Web Development Bootcamp', 'Learn HTML, CSS, and JavaScript fundamentals', 
       CURRENT_DATE + INTERVAL '6 days', '10:00:00', '#194CBF'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'React.js Workshop', 'Build modern web applications with React', 
       CURRENT_DATE + INTERVAL '7 days', '14:00:00', '#3B82F6'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Backend Development with Node.js', 'Learn server-side development with Node.js and Express', 
       CURRENT_DATE + INTERVAL '9 days', '16:00:00', '#2563EB'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Python Programming Basics', 'Start your coding journey with Python', 
       CURRENT_DATE + INTERVAL '5 days', '11:00:00', '#1E40AF'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Hackathon Competition', '48-hour coding competition to build innovative solutions', 
       CURRENT_DATE + INTERVAL '14 days', '09:00:00', '#1D4ED8'
FROM categories WHERE name = 'Dev Room'
ON CONFLICT DO NOTHING;

-- ==================== INNOVATION SPACE EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Startup Idea Validation', 'Learn how to validate your startup idea before building', 
       CURRENT_DATE + INTERVAL '6 days', '10:00:00', '#F59E0B'
FROM categories WHERE name = 'Innovation Space'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Innovation in Algeria', 'Discussion on innovation ecosystem and opportunities in Algeria', 
       CURRENT_DATE + INTERVAL '8 days', '14:00:00', '#F97316'
FROM categories WHERE name = 'Innovation Space'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Prototyping Your Ideas', 'Learn rapid prototyping techniques to bring ideas to life', 
       CURRENT_DATE + INTERVAL '9 days', '15:00:00', '#EA580C'
FROM categories WHERE name = 'Innovation Space'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Innovation Pitch Day', 'Pitch your innovative ideas to a panel of judges', 
       CURRENT_DATE + INTERVAL '11 days', '13:00:00', '#DC2626'
FROM categories WHERE name = 'Innovation Space'
ON CONFLICT DO NOTHING;

-- ==================== STARTUP CORNER EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Business Model Canvas', 'Learn how to create a business model for your startup', 
       CURRENT_DATE + INTERVAL '7 days', '10:00:00', '#7C3AED'
FROM categories WHERE name = 'Startup Corner'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Funding Strategies', 'Understanding different funding options for startups', 
       CURRENT_DATE + INTERVAL '8 days', '15:00:00', '#9333EA'
FROM categories WHERE name = 'Startup Corner'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Marketing for Startups', 'Learn cost-effective marketing strategies for early-stage startups', 
       CURRENT_DATE + INTERVAL '10 days', '11:00:00', '#A855F7'
FROM categories WHERE name = 'Startup Corner'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Startup Networking Event', 'Meet fellow entrepreneurs and potential co-founders', 
       CURRENT_DATE + INTERVAL '13 days', '17:00:00', '#C084FC'
FROM categories WHERE name = 'Startup Corner'
ON CONFLICT DO NOTHING;

-- ==================== LIBRARY EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Reading Club Session', 'Discuss this month''s selected book with fellow readers', 
       CURRENT_DATE + INTERVAL '5 days', '16:00:00', '#059669'
FROM categories WHERE name = 'Library'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Research Skills Workshop', 'Learn effective research techniques and academic writing', 
       CURRENT_DATE + INTERVAL '6 days', '14:00:00', '#10B981'
FROM categories WHERE name = 'Library'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Algerian Literature Discussion', 'Exploring contemporary Algerian literature', 
       CURRENT_DATE + INTERVAL '9 days', '15:00:00', '#34D399'
FROM categories WHERE name = 'Library'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Book Exchange Day', 'Bring books to exchange and discover new reading material', 
       CURRENT_DATE + INTERVAL '11 days', '13:00:00', '#6EE7B7'
FROM categories WHERE name = 'Library'
ON CONFLICT DO NOTHING;

-- ==================== CREATIVE MEDIA EVENTS ====================
INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Video Editing with Premiere Pro', 'Master video editing techniques using Adobe Premiere Pro', 
       CURRENT_DATE + INTERVAL '5 days', '10:00:00', '#DC2626'
FROM categories WHERE name = 'Creative Media'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Photography Basics', 'Learn photography fundamentals and camera settings', 
       CURRENT_DATE + INTERVAL '7 days', '14:00:00', '#EF4444'
FROM categories WHERE name = 'Creative Media'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Lecture', 'Content Creation for Social Media', 'Learn how to create engaging content for social platforms', 
       CURRENT_DATE + INTERVAL '8 days', '16:00:00', '#F87171'
FROM categories WHERE name = 'Creative Media'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Workshop', 'Podcast Production', 'Learn how to start and produce your own podcast', 
       CURRENT_DATE + INTERVAL '10 days', '11:00:00', '#FB7185'
FROM categories WHERE name = 'Creative Media'
ON CONFLICT DO NOTHING;

INSERT INTO events (category_id, type, name, description, event_date, event_time, color)
SELECT id, 'Event', 'Short Film Screening', 'Screening of youth-created short films followed by Q&A', 
       CURRENT_DATE + INTERVAL '15 days', '18:00:00', '#FCA5A5'
FROM categories WHERE name = 'Creative Media'
ON CONFLICT DO NOTHING;

