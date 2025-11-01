-- ============================================
-- VOLUNTEERING OPPORTUNITIES AND ENROLLMENTS SCHEMA
-- ============================================

-- Drop existing tables if they exist (for idempotency)
DROP TABLE IF EXISTS public.volunteering_enrollments CASCADE;
DROP TABLE IF EXISTS public.volunteering_opportunities CASCADE;

-- Create volunteering_opportunities table
CREATE TABLE public.volunteering_opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT NOT NULL,
    icon_name TEXT NOT NULL, -- Store icon identifier (e.g., 'local_hospital_outlined')
    color TEXT NOT NULL, -- Store color as hex string (e.g., '#F44336')
    enrolled_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create volunteering_enrollments table
CREATE TABLE public.volunteering_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES public.volunteering_opportunities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(opportunity_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_volunteering_enrollments_opportunity_id ON public.volunteering_enrollments(opportunity_id);
CREATE INDEX idx_volunteering_enrollments_user_id ON public.volunteering_enrollments(user_id);

-- Create function to update enrolled_count
CREATE OR REPLACE FUNCTION update_volunteering_enrolled_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.volunteering_opportunities 
        SET enrolled_count = enrolled_count + 1 
        WHERE id = NEW.opportunity_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.volunteering_opportunities 
        SET enrolled_count = GREATEST(enrolled_count - 1, 0) 
        WHERE id = OLD.opportunity_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update enrolled_count
DROP TRIGGER IF EXISTS trigger_update_volunteering_enrolled_count ON public.volunteering_enrollments;
CREATE TRIGGER trigger_update_volunteering_enrolled_count
    AFTER INSERT OR DELETE ON public.volunteering_enrollments
    FOR EACH ROW
    EXECUTE FUNCTION update_volunteering_enrolled_count();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_volunteering_opportunities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS trigger_update_volunteering_opportunities_updated_at ON public.volunteering_opportunities;
CREATE TRIGGER trigger_update_volunteering_opportunities_updated_at
    BEFORE UPDATE ON public.volunteering_opportunities
    FOR EACH ROW
    EXECUTE FUNCTION update_volunteering_opportunities_updated_at();

-- Enable Row Level Security
ALTER TABLE public.volunteering_opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.volunteering_enrollments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for volunteering_opportunities table
DROP POLICY IF EXISTS "Volunteering opportunities are viewable by everyone" ON public.volunteering_opportunities;
CREATE POLICY "Volunteering opportunities are viewable by everyone"
    ON public.volunteering_opportunities FOR SELECT
    USING (true);

-- RLS Policies for volunteering_enrollments table
DROP POLICY IF EXISTS "Users can view their own enrollments" ON public.volunteering_enrollments;
CREATE POLICY "Users can view their own enrollments"
    ON public.volunteering_enrollments FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view all enrollments" ON public.volunteering_enrollments;
CREATE POLICY "Users can view all enrollments"
    ON public.volunteering_enrollments FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Users can enroll in opportunities" ON public.volunteering_enrollments;
CREATE POLICY "Users can enroll in opportunities"
    ON public.volunteering_enrollments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can unenroll from opportunities" ON public.volunteering_enrollments;
CREATE POLICY "Users can unenroll from opportunities"
    ON public.volunteering_enrollments FOR DELETE
    USING (auth.uid() = user_id);

-- Insert default volunteering opportunities
INSERT INTO public.volunteering_opportunities (title, description, location, icon_name, color, enrolled_count) VALUES
    ('Healthcare Support', 'Assist in community health programs and clinics', 'Various locations', 'local_hospital_outlined', '#F44336', 0),
    ('Education Tutoring', 'Help students with homework and learning support', 'Youth Center', 'school_outlined', '#194CBF', 0),
    ('Environmental Cleanup', 'Participate in beach and park cleaning initiatives', 'Public spaces', 'eco_outlined', '#4CAF50', 0),
    ('Elderly Care', 'Visit and assist elderly members of the community', 'Care centers', 'volunteer_activism', '#61A1FF', 0),
    ('Food Distribution', 'Help organize and distribute food to those in need', 'Community centers', 'food_bank_outlined', '#FF9800', 0);

