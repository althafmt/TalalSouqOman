import 'package:talalsouqoman/imports.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? userDetails;
  bool isLoading = true;
  String? _profileUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response = await supabase
            .from('users')
            .select('name, email, phone, privilege, profile_picture_url')
            .eq('userid', userId)
            .maybeSingle();

        if (response != null) {
          setState(() {
            userDetails = response;
            _profileUrl = response['profile_picture_url'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('No user found with userid: $userId');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('No logged-in user found');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      final fileName = '${supabase.auth.currentUser?.id}_${DateTime.now().toIso8601String()}.jpg';
      final filePath = 'profile-pictures/$fileName';

      try {
        // Upload the file to the `profile-pictures` bucket
        await supabase.storage.from('profile-pictures').upload(filePath, file);

        // Get the public URL of the uploaded file
        final String publicUrl = supabase.storage.from('profile-pictures').getPublicUrl(filePath);

        // Update the user's profile with the new image URL
        await supabase
            .from('users')
            .update({'profile_picture_url': publicUrl})
            .eq('userid', supabase.auth.currentUser?.id as Object);

        // Update the state to reflect the new profile picture
        setState(() {
          _profileUrl = publicUrl;
        });

        print('Profile picture uploaded successfully: $publicUrl');
      } catch (e) {
        print('Error uploading profile picture: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            GestureDetector(
              onTap: _uploadProfilePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileUrl != null
                    ? NetworkImage(_profileUrl!)
                    : const AssetImage('assets/image/default_profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            // Name
            ProfileInfoCard(
              title: 'Name',
              value: userDetails?['name'] ?? 'Loading...',
            ),
            const SizedBox(height: 20),
            // Email
            ProfileInfoCard(
              title: 'Email',
              value: userDetails?['email'] ?? 'Loading...',
            ),
            const SizedBox(height: 20),
            // Phone Number
            ProfileInfoCard(
              title: 'Phone',
              value: userDetails?['phone'] ?? 'Loading...',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to create a card for displaying user profile info
class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileInfoCard({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}