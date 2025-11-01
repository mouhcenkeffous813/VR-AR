import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youth_center/models/opportunity_model.dart';
import 'package:youth_center/models/project_model.dart';
import 'package:youth_center/models/user_profile_model.dart';
import 'package:youth_center/models/message_model.dart';
import 'package:youth_center/models/category_model.dart';
import 'package:youth_center/models/event_model.dart';
import 'package:youth_center/models/enrollment_model.dart';
import 'package:youth_center/models/question_model.dart';
import 'package:youth_center/models/suggestion_model.dart';
import 'package:youth_center/models/club_model.dart';
import 'package:youth_center/models/club_membership_model.dart';
import 'package:youth_center/models/volunteering_opportunity_model.dart';
import 'package:youth_center/models/volunteering_enrollment_model.dart';

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
      // Remove id and timestamps from update data
      data.remove('id');
      data.remove('created_at');
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

  /// Get current user profile
  Future<UserProfileModel?> getCurrentUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return null;
      }
      return await getUserProfile(userId);
    } catch (e) {
      return null;
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

  // ==================== WILAYA CHAT MESSAGES ====================

  /// Get messages for a specific wilaya
  Future<List<MessageModel>> getWilayaMessages(String wilayaName) async {
    try {
      final response = await supabase
          .from('wilaya_messages')
          .select()
          .eq('wilaya_name', wilayaName)
          .order('created_at', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  /// Send a message to a wilaya chat
  Future<void> sendWilayaMessage({
    required String wilayaName,
    required String message,
    required String userId,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      final userName = user?.email?.split('@')[0] ?? 'User';

      await supabase.from('wilaya_messages').insert({
        'wilaya_name': wilayaName,
        'user_id': userId,
        'user_name': userName,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // ==================== CATEGORIES ====================

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Get category by name
  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CategoryModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ==================== EVENTS ====================

  /// Get events by category ID
  Future<List<EventModel>> getEventsByCategoryId(String categoryId) async {
    try {
      final response = await supabase
          .from('events')
          .select()
          .eq('category_id', categoryId)
          .gte('event_date', DateTime.now().toIso8601String().split('T')[0])
          .order('event_date', ascending: true)
          .order('event_time', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  /// Get events by category name
  Future<List<EventModel>> getEventsByCategoryName(String categoryName) async {
    try {
      // First get category ID
      final category = await getCategoryByName(categoryName);
      if (category == null || category.id == null) {
        return [];
      }

      return await getEventsByCategoryId(category.id!);
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  // ==================== ENROLLMENTS ====================

  /// Check if user is enrolled in an event
  Future<bool> isEnrolledInEvent(String eventId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      final response = await supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Enroll user in an event
  Future<void> enrollInEvent(String eventId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to enroll');
      }

      // Check if already enrolled
      final isEnrolled = await isEnrolledInEvent(eventId);
      if (isEnrolled) {
        throw Exception('You are already enrolled in this event');
      }

      await supabase.from('enrollments').insert({
        'user_id': userId,
        'event_id': eventId,
      });
    } catch (e) {
      throw Exception('Error enrolling in event: $e');
    }
  }

  /// Unenroll user from an event
  Future<void> unenrollFromEvent(String eventId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to unenroll');
      }

      await supabase
          .from('enrollments')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);
    } catch (e) {
      throw Exception('Error unenrolling from event: $e');
    }
  }

  /// Toggle enrollment (enroll if not enrolled, unenroll if enrolled)
  Future<bool> toggleEnrollment(String eventId) async {
    try {
      final isEnrolled = await isEnrolledInEvent(eventId);
      if (isEnrolled) {
        await unenrollFromEvent(eventId);
        return false;
      } else {
        await enrollInEvent(eventId);
        return true;
      }
    } catch (e) {
      throw Exception('Error toggling enrollment: $e');
    }
  }

  /// Get all enrollments for current user
  Future<List<EnrollmentModel>> getMyEnrollments() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('enrolled_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => EnrollmentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching enrollments: $e');
    }
  }

  // ==================== IDEAS EXPO QUESTIONS ====================

  /// Get all questions
  Future<List<QuestionModel>> getIdeasExpoQuestions() async {
    try {
      final response = await supabase
          .from('ideas_expo_questions')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => QuestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  /// Create a new question
  Future<QuestionModel> createIdeasExpoQuestion({
    required String name,
    required String category,
    required String question,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to ask a question');
      }

      final response = await supabase
          .from('ideas_expo_questions')
          .insert({
            'user_id': userId,
            'name': name,
            'category': category,
            'question': question,
            'replies': 0,
          })
          .select()
          .single();

      return QuestionModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating question: $e');
    }
  }

  /// Delete a question
  Future<void> deleteIdeasExpoQuestion(String questionId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to delete a question');
      }

      await supabase
          .from('ideas_expo_questions')
          .delete()
          .eq('id', questionId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error deleting question: $e');
    }
  }

  // ==================== SUGGESTIONS ====================

  /// Get all suggestions
  Future<List<SuggestionModel>> getSuggestions() async {
    try {
      final response = await supabase
          .from('suggestions')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => SuggestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching suggestions: $e');
    }
  }

  /// Create a new suggestion
  Future<SuggestionModel> createSuggestion({
    required String title,
    required String description,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to create a suggestion');
      }

      final response = await supabase
          .from('suggestions')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
          })
          .select()
          .single();

      return SuggestionModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating suggestion: $e');
    }
  }

  /// Delete a suggestion
  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to delete a suggestion');
      }

      await supabase
          .from('suggestions')
          .delete()
          .eq('id', suggestionId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error deleting suggestion: $e');
    }
  }

  // ==================== CLUBS ====================

  /// Get all clubs
  Future<List<ClubModel>> getClubs() async {
    try {
      final response = await supabase
          .from('clubs')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ClubModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching clubs: $e');
    }
  }

  /// Get club by ID
  Future<ClubModel?> getClubById(String clubId) async {
    try {
      final response = await supabase
          .from('clubs')
          .select()
          .eq('id', clubId)
          .maybeSingle();

      if (response == null) return null;
      return ClubModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get user's club memberships
  Future<List<ClubMembershipModel>> getUserClubMemberships() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await supabase
          .from('club_memberships')
          .select()
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      return (response as List)
          .map((json) => ClubMembershipModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching user club memberships: $e');
    }
  }

  /// Check if user is member of a club
  Future<bool> isClubMember(String clubId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabase
          .from('club_memberships')
          .select()
          .eq('club_id', clubId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Join a club
  Future<void> joinClub(String clubId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to join a club');
      }

      await supabase.from('club_memberships').insert({
        'club_id': clubId,
        'user_id': userId,
      });
    } catch (e) {
      if (e.toString().contains('duplicate')) {
        throw Exception('You are already a member of this club');
      }
      throw Exception('Error joining club: $e');
    }
  }

  /// Leave a club
  Future<void> leaveClub(String clubId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to leave a club');
      }

      await supabase
          .from('club_memberships')
          .delete()
          .eq('club_id', clubId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error leaving club: $e');
    }
  }

  /// Toggle club membership (join if not member, leave if member)
  Future<bool> toggleClubMembership(String clubId) async {
    try {
      final isMember = await isClubMember(clubId);
      if (isMember) {
        await leaveClub(clubId);
        return false;
      } else {
        await joinClub(clubId);
        return true;
      }
    } catch (e) {
      throw Exception('Error toggling club membership: $e');
    }
  }

  // ==================== VOLUNTEERING ====================

  /// Get all volunteering opportunities
  Future<List<VolunteeringOpportunityModel>> getVolunteeringOpportunities() async {
    try {
      final response = await supabase
          .from('volunteering_opportunities')
          .select()
          .order('title', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => VolunteeringOpportunityModel.fromJson(json))
          .toList();
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('PGRST205') || 
          errorMsg.contains('Could not find the table') ||
          errorMsg.contains('volunteering_opportunities')) {
        throw Exception(
          'The table "volunteering_opportunities" does not exist in the database.\n\n'
          'Please execute the VOLUNTEERING_SCHEMA.sql file in the Supabase SQL Editor to create the table.'
        );
      }
      throw Exception('Error loading volunteering opportunities: $e');
    }
  }

  /// Get volunteering opportunity by ID
  Future<VolunteeringOpportunityModel?> getVolunteeringOpportunityById(String opportunityId) async {
    try {
      final response = await supabase
          .from('volunteering_opportunities')
          .select()
          .eq('id', opportunityId)
          .maybeSingle();

      if (response == null) return null;
      return VolunteeringOpportunityModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get user's volunteering enrollments
  Future<List<VolunteeringEnrollmentModel>> getUserVolunteeringEnrollments() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await supabase
          .from('volunteering_enrollments')
          .select()
          .eq('user_id', userId)
          .order('enrolled_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((json) => VolunteeringEnrollmentModel.fromJson(json))
          .toList();
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('PGRST205') || 
          errorMsg.contains('Could not find the table') ||
          errorMsg.contains('volunteering_enrollments')) {
        // Return empty list if table doesn't exist yet
        return [];
      }
      throw Exception('Error fetching user volunteering enrollments: $e');
    }
  }

  /// Check if user is enrolled in a volunteering opportunity
  Future<bool> isEnrolledInVolunteering(String opportunityId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabase
          .from('volunteering_enrollments')
          .select()
          .eq('opportunity_id', opportunityId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      // Return false if table doesn't exist or any error
      return false;
    }
  }

  /// Enroll in a volunteering opportunity
  Future<void> enrollInVolunteering(String opportunityId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to enroll in volunteering');
      }

      await supabase.from('volunteering_enrollments').insert({
        'opportunity_id': opportunityId,
        'user_id': userId,
      });
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('duplicate') || errorMsg.contains('unique')) {
        throw Exception('You are already enrolled in this opportunity');
      }
      if (errorMsg.contains('PGRST205') || errorMsg.contains('Could not find the table')) {
        throw Exception(
          'Volunteering tables have not been created.\n'
          'Execute VOLUNTEERING_SCHEMA.sql in the Supabase SQL Editor.'
        );
      }
      throw Exception('Error enrolling: $e');
    }
  }

  /// Unenroll from a volunteering opportunity
  Future<void> unenrollFromVolunteering(String opportunityId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to unenroll from volunteering');
      }

      await supabase
          .from('volunteering_enrollments')
          .delete()
          .eq('opportunity_id', opportunityId)
          .eq('user_id', userId);
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('PGRST205') || errorMsg.contains('Could not find the table')) {
        throw Exception(
          'Volunteering tables have not been created.\n'
          'Execute VOLUNTEERING_SCHEMA.sql in the Supabase SQL Editor.'
        );
      }
      throw Exception('Error unenrolling: $e');
    }
  }

  /// Toggle volunteering enrollment (enroll if not enrolled, unenroll if enrolled)
  Future<bool> toggleVolunteeringEnrollment(String opportunityId) async {
    try {
      final isEnrolled = await isEnrolledInVolunteering(opportunityId);
      if (isEnrolled) {
        await unenrollFromVolunteering(opportunityId);
        return false;
      } else {
        await enrollInVolunteering(opportunityId);
        return true;
      }
    } catch (e) {
      throw Exception('Error toggling volunteering enrollment: $e');
    }
  }
}

