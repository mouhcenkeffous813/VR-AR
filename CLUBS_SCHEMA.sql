-- ============================================
-- CLUBS AND CLUB MEMBERSHIPS SCHEMA
-- ============================================

-- Drop existing tables if they exist (for idempotency)
DROP TABLE IF EXISTS public.club_memberships CASCADE;
DROP TABLE IF EXISTS public.clubs CASCADE;

-- Create clubs table
CREATE TABLE public.clubs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL, -- Store icon identifier (e.g., 'code', 'palette_outlined', 'music_note')
    color TEXT NOT NULL, -- Store color as hex string (e.g., '#194CBF')
    member_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create club_memberships table
CREATE TABLE public.club_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id UUID NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(club_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_club_memberships_club_id ON public.club_memberships(club_id);
CREATE INDEX idx_club_memberships_user_id ON public.club_memberships(user_id);

-- Create function to update member_count
CREATE OR REPLACE FUNCTION update_club_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.clubs 
        SET member_count = member_count + 1 
        WHERE id = NEW.club_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.clubs 
        SET member_count = GREATEST(member_count - 1, 0) 
        WHERE id = OLD.club_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update member_count
DROP TRIGGER IF EXISTS trigger_update_club_member_count ON public.club_memberships;
CREATE TRIGGER trigger_update_club_member_count
    AFTER INSERT OR DELETE ON public.club_memberships
    FOR EACH ROW
    EXECUTE FUNCTION update_club_member_count();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_clubs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS trigger_update_clubs_updated_at ON public.clubs;
CREATE TRIGGER trigger_update_clubs_updated_at
    BEFORE UPDATE ON public.clubs
    FOR EACH ROW
    EXECUTE FUNCTION update_clubs_updated_at();

-- Enable Row Level Security
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_memberships ENABLE ROW LEVEL SECURITY;

-- RLS Policies for clubs table
DROP POLICY IF EXISTS "Clubs are viewable by everyone" ON public.clubs;
CREATE POLICY "Clubs are viewable by everyone"
    ON public.clubs FOR SELECT
    USING (true);

-- RLS Policies for club_memberships table
DROP POLICY IF EXISTS "Users can view their own memberships" ON public.club_memberships;
CREATE POLICY "Users can view their own memberships"
    ON public.club_memberships FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view all memberships" ON public.club_memberships;
CREATE POLICY "Users can view all memberships"
    ON public.club_memberships FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can join clubs" ON public.club_memberships;
CREATE POLICY "Users can join clubs"
    ON public.club_memberships FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can leave clubs" ON public.club_memberships;
CREATE POLICY "Users can leave clubs"
    ON public.club_memberships FOR DELETE
    USING (auth.uid() = user_id);

-- Insert default clubs
INSERT INTO public.clubs (name, description, icon_name, color, member_count) VALUES
    ('Tech Club', 'Programming, app development, and tech discussions', 'code', '#194CBF', 125),
    ('Art & Design', 'Creative projects, design workshops, and exhibitions', 'palette_outlined', '#61A1FF', 89),
    ('Music Club', 'Jam sessions, performances, and music production', 'music_note', '#4CAF50', 67),
    ('Sports Club', 'Organize games, tournaments, and fitness activities', 'sports_soccer', '#FF9800', 142),
    ('Book Club', 'Book discussions, reading circles, and literary events', 'menu_book', '#2196F3', 54);

