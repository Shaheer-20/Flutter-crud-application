import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() => runApp(const UserManagementApp());

class UserManagementApp extends StatelessWidget {
  const UserManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: const UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> users = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fetchUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load users')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await http.delete(Uri.parse('http://localhost:3000/users/$id'));
      fetchUsers();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  void _showDeleteConfirmationDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: const Text(
            'Delete User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete ${user['name']}?'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                deleteUser(user['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : users.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Animate(
                      effects: [
                        FadeEffect(duration: 300.ms),
                        SlideEffect(
                          begin: const Offset(0.5, 0),
                          end: Offset.zero,
                          duration: 300.ms,
                        ),
                      ],
                      child: Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              user['name'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email']),
                              const SizedBox(height: 4),
                              Text(
                                'Age: ${user['age']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserFormPage(user: user),
                                    ),
                                  ).then((_) => fetchUsers());
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeleteConfirmationDialog(user),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserFormPage()),
          ).then((_) => fetchUsers());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UserFormPage extends StatefulWidget {
  final dynamic user;
  const UserFormPage({Key? key, this.user}) : super(key: key);

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user != null ? widget.user['name'] : '',
    );
    _emailController = TextEditingController(
      text: widget.user != null ? widget.user['email'] : '',
    );
    _ageController = TextEditingController(
      text: widget.user != null ? widget.user['age'].toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final email = _emailController.text;
    final age = int.parse(_ageController.text);

    try {
      if (widget.user == null) {
        // Create new user
        await http.post(
          Uri.parse('http://localhost:3000/users'),
          headers: const {'Content-Type': 'application/json'},
          body: json.encode({'name': name, 'email': email, 'age': age}),
        );
      } else {
        // Update existing user
        final id = widget.user['id'];
        await http.put(
          Uri.parse('http://localhost:3000/users/$id'),
          headers: const {'Content-Type': 'application/json'},
          body: json.encode({'name': name, 'email': email, 'age': age}),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Add User' : 'Edit User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveUser,
                child: Text(widget.user == null ? 'Add User' : 'Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
