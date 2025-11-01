import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youth_center/models/opportunity_model.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:youth_center/models/user_profile_model.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ==================== OPPORTUNITIES ====================

  /// Get all opportunities
  Future<List<OpportunityModel>> getOpportunities() async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OpportunityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching opportunities: $e');
    }
  }

  /// Get opportunity by ID
  Future<OpportunityModel?> getOpportunityById(String id) async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .eq('id', id)
          .single();

      return OpportunityModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Search opportunities
  Future<List<OpportunityModel>> searchOpportunities(String query) async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .or('title.ilike.%$query%,company.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OpportunityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error searching opportunities: $e');
    }
  }

  /// Filter opportunities by type
  Future<List<OpportunityModel>> getOpportunitiesByType(String type) async {
    try {
      final response = await supabase
          .from('opportunities')
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OpportunityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching opportunities by type: $e');
    }
  }

  // ==================== PROJECTS ====================

  /// Get all projects
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// Get project by ID
  Future<ProjectModel?> getProjectById(String id) async {
    try {
      final response = await supabase
          .from('projects')
          .select()
          .eq('id', id)
          .single();

      return ProjectModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new project
  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be logged in to create a project');
      }

      final data = project.toJson();
      data['created_by'] = userId;

      final response = await supabase
          .from('projects')
          .insert(data)
          .select()
          .single();

      return ProjectModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }

  /// Join a project
  Future<void> joinProject(String projectId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be logged in to join a project');
      }

      await supabase.from('project_participants').insert({
        'project_id': projectId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error joining project: $e');
    }
  }

  // ==================== USER PROFILE ====================

  /// Get user profile
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      // If profile doesn't exist, create it
      return await createUserProfile(userId);
    }
  }

  /// Create user profile
  Future<UserProfileModel> createUserProfile(String userId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in');
      }

      final profile = UserProfileModel(
        id: userId,
        email: user.email ?? '',
        points: 0,
      );

      await supabase.from('user_profiles').insert(profile.toJson());

      return profile;
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  /// Update user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be logged in');
      }

      final data = profile.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('user_profiles')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // ==================== BOOKMARKS ====================

  /// Get user bookmarks
  Future<List<String>> getUserBookmarks() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return <String>[];
      }

      final response = await supabase
          .from('bookmarks')
          .select('opportunity_id')
          .eq('user_id', userId);

      // Response is always a List from Supabase
      final List<dynamic> responseList = response as List<dynamic>;
      
      if (responseList.isEmpty) {
        return <String>[];
      }

      // Convert to List<String> - simple conversion
      final List<String> bookmarks = [];
      for (final item in responseList) {
        if (item is Map<String, dynamic>) {
          final id = item['opportunity_id'];
          bookmarks.add(id.toString());
        }
      }
      
      return bookmarks;
    } catch (e) {
      // Return empty list on any error - don't throw
      return <String>[];
    }
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(String opportunityId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You must be logged in to bookmark');
    }

    // Clean the ID - remove any quotes or extra characters
    final cleanId = opportunityId.trim().replaceAll("'", '').replaceAll('"', '');

    try {
      // Check if bookmark exists
      final existing = await supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('opportunity_id', cleanId)
          .maybeSingle();

      if (existing != null) {
        // Remove bookmark
        await supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('opportunity_id', cleanId);
      } else {
        // Add bookmark
        await supabase.from('bookmarks').insert({
          'user_id': userId,
          'opportunity_id': cleanId, // Store as TEXT
        });
      }
    } catch (e) {
      // Provide better error message
      final errorMsg = e.toString();
      if (errorMsg.contains('uuid') || errorMsg.contains('22P02')) {
        throw Exception(
          'Database error: Please run FIX_BOOKMARKS.sql in Supabase SQL Editor to fix the table structure.',
        );
      }
      throw Exception('Failed to save bookmark: $errorMsg');
    }
  }
}

