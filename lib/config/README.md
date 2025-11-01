# Configuration Setup

This directory contains configuration files for the app.

## Setup Instructions

1. **Copy the example file:**
   ```bash
   cp app_config.example.dart app_config.dart
   ```

2. **Edit `app_config.dart`** and replace the placeholder values with your actual API keys:
   - `supabaseUrl`: Your Supabase project URL
   - `supabaseAnonKey`: Your Supabase anonymous/public key

3. **Important:** 
   - ✅ `app_config.example.dart` can be committed to git (it contains no sensitive data)
   - ❌ `app_config.dart` should NEVER be committed to git (it contains your actual API keys)
   - The `.gitignore` file is configured to exclude `app_config.dart`

## Files

- `app_config.example.dart`: Template file with placeholders (safe to commit)
- `app_config.dart`: Your actual config file with real API keys (DO NOT COMMIT)

