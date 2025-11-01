# Backend Setup Guide

This guide will help you set up your Supabase database for the Youth Center app.

## 📋 Prerequisites

- Supabase project created at https://supabase.com
- Your Supabase URL and anon key (already in `main.dart`)

## 🗄️ Database Setup Steps

### Step 1: Create Database Tables

1. Go to your Supabase Dashboard → SQL Editor
2. Open the file `SUPABASE_SCHEMA.sql` from the root of this project
3. Copy the entire SQL content
4. Paste it into the SQL Editor
5. Click "Run" to execute

This will create:
- ✅ `user_profiles` - Store user information and points
- ✅ `opportunities` - Store internships, programs, volunteering, projects
- ✅ `projects` - Store collaborative projects
- ✅ `project_participants` - Track who joined which projects
- ✅ `bookmarks` - Store user bookmarks/favorites

### Step 2: Verify Tables Created

Go to Supabase Dashboard → Table Editor and verify all tables exist:
- user_profiles
- opportunities
- projects
- project_participants
- bookmarks

### Step 3: Row Level Security (RLS)

The SQL script automatically:
- ✅ Enables RLS on all tables
- ✅ Creates policies for secure data access
- ✅ Allows users to only modify their own data

### Step 4: Test Your Setup

The SQL includes sample data. You should see 5 opportunities after running the script.

## 🔧 Using the Database Service

### Import the service:
```dart
import 'package:youth_center/services/database_service.dart';

final dbService = DatabaseService();
```

### Examples:

**Get all opportunities:**
```dart
final opportunities = await dbService.getOpportunities();
```

**Search opportunities:**
```dart
final results = await dbService.searchOpportunities('developer');
```

**Get user profile:**
```dart
final userId = supabase.auth.currentUser?.id;
final profile = await dbService.getUserProfile(userId!);
```

**Join a project:**
```dart
await dbService.joinProject(projectId);
```

**Toggle bookmark:**
```dart
await dbService.toggleBookmark(opportunityId);
```

## 📝 Next Steps

1. ✅ Run the SQL schema in Supabase
2. ⏭️ Update your screens to use `DatabaseService` instead of hardcoded data
3. ⏭️ Test CRUD operations
4. ⏭️ Add more features as needed

## 🚨 Important Notes

- All tables use Row Level Security (RLS) for security
- User profiles are automatically created when a user signs up (via trigger)
- The `updated_at` column is automatically updated via triggers
- Sample opportunities are inserted by default (you can remove them if needed)

## 🔐 Security

- Users can only modify their own data
- Public data (opportunities, projects) can be viewed by anyone
- Only authenticated users can create/update opportunities
- Project creators can only modify their own projects

