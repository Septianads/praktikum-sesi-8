
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = UserService.getUsers();
  }

  void refreshUsers() {
    setState(() {
      futureUsers = UserService.getUsers();
    });
  }

  // ==========================================
  // FORM USER
  // ==========================================
  void showUserForm({User? user}) {
    final nameController = TextEditingController(
      text: user?.name ?? '',
    );

    final emailController = TextEditingController(
      text: user?.email ?? '',
    );

    final cityController = TextEditingController(
      text: user?.city ?? '',
    );

    final isEdit = user != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit User (PUT)' : 'Tambah User (POST)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua field harus diisi'),
                    ),
                  );
                  return;
                }

                try {
                  if (isEdit) {
                    await UserService.updateUser(
                      id: user.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                    );
                  } else {
                    await UserService.createUser(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      city: cityController.text.trim(),
                    );
                  }

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  refreshUsers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'User berhasil diperbarui'
                            : 'User berhasil ditambahkan dengan ID 1075',
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // PATCH USER
  // ==========================================
  void patchUser(User user) {
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('PATCH User'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Nama akan ditambahkan - Flutter Developer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                try {
                  await UserService.patchUser(
                    id: user.id,
                    name: controller.text.trim(),
                  );

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);
                  refreshUsers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PATCH berhasil dilakukan'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('PATCH'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // DELETE USER
  // ==========================================
  void confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus User'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await UserService.deleteUser(user.id);

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);
                  refreshUsers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User berhasil dihapus'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // DETAIL USER
  // ==========================================
  void showDetail(User user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Detail User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${user.id}'),
              const SizedBox(height: 8),
              Text('Name: ${user.name}'),
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              Text('City: ${user.city}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: refreshUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUserForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah User'),
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi error: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text('Tidak ada data User'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.email}\nID: ${user.id} | ${user.city}',
                  ),
                  isThreeLine: true,
                  onTap: () => showDetail(user),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'detail') {
                        showDetail(user);
                      } else if (value == 'put') {
                        showUserForm(user: user);
                      } else if (value == 'patch') {
                        patchUser(user);
                      } else if (value == 'delete') {
                        confirmDelete(user);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'detail',
                        child: Text('Detail / GET'),
                      ),
                      PopupMenuItem(
                        value: 'put',
                        child: Text('Edit / PUT'),
                      ),
                      PopupMenuItem(
                        value: 'patch',
                        child: Text('PATCH Name'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('DELETE'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
