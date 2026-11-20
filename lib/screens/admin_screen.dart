
import 'package:flutter/material.dart';

import '../models/admin.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Admin>> futureAdmins;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureAdmins = AdminService.getAdmins();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void refreshAdmins() {
    setState(() {
      futureAdmins = AdminService.getAdmins();
    });
  }

  // ==========================================
  // GET ADMIN DETAIL BY ID
  // ==========================================
  Future<void> searchAdminById() async {
    final id = int.tryParse(searchController.text.trim());

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan ID Admin yang valid'),
        ),
      );
      return;
    }

    final admin = await AdminService.getAdmin(id);

    if (!mounted) return;

    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin dengan ID $id tidak ditemukan'),
        ),
      );
      return;
    }

    showAdminDetail(admin);
  }

  // ==========================================
  // DETAIL ADMIN
  // ==========================================
  void showAdminDetail(Admin admin) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Detail Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${admin.id}'),
              const SizedBox(height: 8),
              Text('Name: ${admin.name}'),
              const SizedBox(height: 8),
              Text('Email: ${admin.email}'),
              const SizedBox(height: 8),
              Text('Department: ${admin.department}'),
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
  // DELETE ADMIN
  // ==========================================
  void confirmDelete(Admin admin) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Admin'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${admin.name} '
                'dengan ID ${admin.id}?',
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
                  await AdminService.deleteAdmin(admin.id);

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);
                  refreshAdmins();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin berhasil dihapus'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Delete'),
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
        title: const Text('Admin Management'),
        actions: [
          IconButton(
            onPressed: refreshAdmins,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH ADMIN BY ID
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cari Admin berdasarkan ID',
                      hintText: 'Contoh: 2075',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => searchAdminById(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchAdminById,
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),

          // ADMIN LIST
          Expanded(
            child: FutureBuilder<List<Admin>>(
              future: futureAdmins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final admins = snapshot.data ?? [];

                if (admins.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data Admin'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          admin.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${admin.email}\n'
                              'ID: ${admin.id}\n'
                              'Department: ${admin.department}',
                        ),
                        isThreeLine: true,
                        onTap: () => showAdminDetail(admin),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          tooltip: 'Delete Admin',
                          onPressed: () => confirmDelete(admin),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
