# Volunteering Setup - Installation Guide

## ⚠️ IMPORTANT: Create Tables in Supabase

Before using the volunteering feature, you **MUST** execute the SQL schema in Supabase.

### Steps:

1. **Access Supabase Dashboard**
   - Go to your Supabase project
   - Click on **SQL Editor** in the side menu

2. **Execute the SQL Schema**
   - Open the `VOLUNTEERING_SCHEMA.sql` file
   - Copy all the content
   - Paste it into the Supabase SQL Editor
   - Click **RUN** or press `Ctrl+Enter` (or `Cmd+Enter` on Mac)

3. **Verify Tables Were Created**
   - Go to **Table Editor** in the side menu
   - You should see two new tables:
     - `volunteering_opportunities`
     - `volunteering_enrollments`

### What the SQL Schema Does:

- ✅ Creates the `volunteering_opportunities` table with required fields
- ✅ Creates the `volunteering_enrollments` table to track enrollments
- ✅ Configures Row Level Security (RLS) to protect data
- ✅ Creates triggers to automatically update counters
- ✅ Inserts 5 default volunteering opportunities

### Common Error:

If you see this error:
```
Could not find the table 'public.volunteering_opportunities'
```

**It means the SQL schema hasn't been executed yet.** Follow the steps above.

### After Executing the Schema:

After running the SQL, the volunteering opportunities will be available in the app:
- Healthcare Support
- Education Tutoring
- Environmental Cleanup
- Elderly Care
- Food Distribution

