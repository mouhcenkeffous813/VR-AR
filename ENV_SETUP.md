# Environment Variables Setup

This project uses `flutter_dotenv` to securely manage API keys and sensitive configuration.

## Initial Setup

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env`** and replace the placeholder values with your actual API keys:
   ```env
   SUPABASE_URL=your_actual_supabase_url
   SUPABASE_ANON_KEY=your_actual_supabase_anon_key
   ```

## Important Security Notes

- ✅ `.env.example` can be committed to git (contains no sensitive data)
- ❌ `.env` should NEVER be committed to git (contains your actual API keys)
- The `.gitignore` file is configured to exclude `.env`

## Files

- `.env.example`: Template file with placeholders (safe to commit)
- `.env`: Your actual environment variables (DO NOT COMMIT)

## Usage in Code

Environment variables are loaded in `main.dart` and can be accessed using:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final supabaseUrl = dotenv.env['SUPABASE_URL']!;
final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;
```

## Troubleshooting

If you get errors about missing environment variables:
1. Ensure `.env` file exists in the project root
2. Verify `.env` is included in `pubspec.yaml` assets section
3. Run `flutter pub get` to ensure `flutter_dotenv` is installed
4. Do a full app restart (not just hot reload)

