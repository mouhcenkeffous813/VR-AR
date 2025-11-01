import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/club_model.dart';
import 'package:youth_center/utils/icon_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubsHubPage extends StatefulWidget {
  const ClubsHubPage({super.key});

  @override
  State<ClubsHubPage> createState() => _ClubsHubPageState();
}

class _ClubsHubPageState extends State<ClubsHubPage> {
  final DatabaseService _dbService = DatabaseService();
  List<ClubModel> _clubs = [];
  Set<String> _joinedClubIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clubs = await _dbService.getClubs();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      Set<String> joinedIds = {};
      if (userId != null) {
        final memberships = await _dbService.getUserClubMemberships();
        joinedIds = memberships.map((m) => m.clubId).toSet();
      }

      setState(() {
        _clubs = clubs;
        _joinedClubIds = joinedIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clubs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleClubMembership(ClubModel club) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to join clubs'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final isMember = _joinedClubIds.contains(club.id);
      await _dbService.toggleClubMembership(club.id);
      
      setState(() {
        if (isMember) {
          _joinedClubIds.remove(club.id);
        } else {
          _joinedClubIds.add(club.id);
        }
      });

      // Reload clubs to update member count
      await _loadClubs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isMember 
              ? 'Left ${club.name} successfully' 
              : 'Joined ${club.name} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clubs Hub',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, AppColors.secondaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.group,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Clubs Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join clubs and connect with like-minded people',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content Section
            const Text(
              'Available Clubs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _clubs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No clubs available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: _clubs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final club = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _clubs.length - 1 ? 12 : 0,
                            ),
                            child: _buildClubCard(club),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(ClubModel club) {
    final isJoined = _joinedClubIds.contains(club.id);
    final icon = IconHelper.getIconFromName(club.iconName);
    final color = IconHelper.getColorFromHex(club.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isJoined ? color : AppColors.borderDefault,
          width: isJoined ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  club.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${club.memberCount} members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _toggleClubMembership(club),
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isJoined ? 'Leave' : 'Join'),
          ),
        ],
      ),
    );
  }
}

