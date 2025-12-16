import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/newitemscreen.dart';
import 'package:mydiary/diary.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Diary> entries = [];
  String message = "Loading...";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    entries = await DatabaseHelper().getAllDiaries();
    message = entries.isEmpty ? "No diary saved yet" : "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 241, 240),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 132, 45, 68),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewEntryScreen()),
          );
          loadData();
        },
      ),

      body: Column(
        children: [
          //header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 235, 137, 137), Color.fromARGB(255, 132, 45, 68)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:BorderRadius.vertical(bottom: Radius.circular(17)),
            ),
            child: const Center(
              child: Text(
                "My Diary",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          //content
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      message,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    itemBuilder: (_, index) {
                      final item = entries[index];
                      return InkWell(
                        onTap: () => showDetailsDialog(item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              //imageSection
                              SizedBox(
                                width: screenWidth * 0.25,
                                height: 90,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: loadImage(item.imagename),
                                ),
                              ),

                              const SizedBox(width: 12),

                              //textSection
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      item.description.isEmpty
                                          ? "No content"
                                          : item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      item.date,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              //actionsBtn
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => editEntry(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => deleteEntry(item.id),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  //itemDetails
  void showDetailsDialog(Diary item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               if (item.imagename != "NA")
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: loadImage(item.imagename),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Diary Notes: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 7),

              Text(item.description),
              const SizedBox(height: 26),
              Text("Date: ${item.date}"),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  //itemEdit
  void editEntry(Diary item) {
    final titleCtrl = TextEditingController(text: item.title);
    final contentCtrl = TextEditingController(text: item.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Diary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Content"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              item.title = titleCtrl.text.trim();
              item.description = contentCtrl.text.trim();
              await DatabaseHelper().updateDiary(item);
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  //itemDelete
  void deleteEntry(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Entry"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper().deleteDiary(id);
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //imageLoader
  Widget loadImage(String imagename) {
    if (imagename == "NA") {
      return const Icon(Icons.image_not_supported,
          size: 40, color: Colors.grey);
    }
    final file = File(imagename);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.broken_image, size: 40, color: Colors.grey);
  }
}
