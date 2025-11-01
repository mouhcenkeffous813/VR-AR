-- ============================================
-- PROFILE UPDATE SCHEMA
-- Add bio, location, portfolio, and settings fields
-- ============================================

-- Add new columns to user_profiles table
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS location TEXT,
ADD COLUMN IF NOT EXISTS portfolio TEXT,
ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}'::jsonb;

-- Update comment for documentation
COMMENT ON COLUMN public.user_profiles.bio IS 'User biography or description';
COMMENT ON COLUMN public.user_profiles.location IS 'User location (e.g., Algiers, Algeria)';
COMMENT ON COLUMN public.user_profiles.portfolio IS 'User portfolio website URL';
COMMENT ON COLUMN public.user_profiles.settings IS 'User settings stored as JSON';

