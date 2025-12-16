import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; //tools for formatting dates, numbers 
import 'package:mydiary/diary.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:path_provider/path_provider.dart'; //find commonly used locations on a device's file system

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late double screenHeight;
  late double screenWidth;

  File? image;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm a');

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) screenWidth = 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 132, 45, 68), Color.fromARGB(255, 249, 234, 234)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  ),
                ],
              ),
              //header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  "Add New Diary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              //formSection
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //imagePicker
                        GestureDetector(
                          onTap: selectCameraGalleryDialog,
                          child: Container(
                            height: screenHeight * 0.25,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: image == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, size: 70, color: Colors.grey.shade600),
                                      const SizedBox(height: 8),
                                      const Text("Tap to add image",
                                          style: TextStyle(color: Colors.black54, fontSize: 16)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.file(image!, width: double.infinity, fit: BoxFit.cover),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //titleInput
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Title",
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //notesInput
                        TextField(
                          controller: contentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Notes",
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //dateDescription
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color.fromARGB(255, 132, 45, 68)),
                            const SizedBox(width: 10),
                            Text("Date: ${formatter.format(DateTime.now())}",
                                style: const TextStyle(fontSize: 16, color: Colors.black87)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        //saveBtn
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: showConfirmDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 132, 45, 68),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("Save Diary",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //imagePicker
  void selectCameraGalleryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Image Source", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),
              
              //camera or gallery option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  //camera
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openCamera();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 132, 45, 68),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Color.fromARGB(255, 255, 255, 255), size: 40),
                        ),
                        const SizedBox(height: 8),
                        const Text("Camera"),
                      ],
                    ),
                  ),

                  //gallery
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openGallery();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 132, 45, 68),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.photo_library_rounded, color: Color.fromARGB(255, 250, 250, 250), size: 40),
                        ),
                        const SizedBox(height: 8),
                        const Text("Gallery"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              //cancelBtn
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 16))),
            ],
          ),
        );
      },
    );
  }

  //camera
  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  //gallery
  Future<void> openGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  //saveConfirmation
  void showConfirmDialog() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a title.")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Color.fromARGB(255, 132, 45, 68), 
                  shape: BoxShape.circle),

                  child: const Icon(
                    Icons.save_rounded, 
                    size: 40, 
                    color: Color.fromARGB(255, 255, 255, 255)),

                ),
                const SizedBox(height: 18),

                const Text("Confirm Save", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Text("Do you want to save this diary entry?", 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 15, color: Colors.grey[700])),

                const SizedBox(height: 24),

              //cancel or save btn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    //cancelBtn
                    Expanded(
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color.fromARGB(255, 132, 45, 68)), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 

                            padding: const EdgeInsets.symmetric(vertical: 14)),

                            onPressed: () => Navigator.pop(context),

                            child: const Text("Cancel", 
                            style: TextStyle(fontSize: 16, 
                            color: Color.fromARGB(255, 132, 45, 68))))),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 132, 45, 68), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 

                          padding: const EdgeInsets.symmetric(vertical: 14)),

                        onPressed: () {
                          Navigator.pop(context);
                          saveEntry();
                        },

                        child: const Text("Save", 
                          style: TextStyle(
                          fontSize: 16, 
                          color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //save item to sqlLite
  Future<void> saveEntry() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String storedImagePath = "NA";

    if (image != null) {
      String imageName = "${DateTime.now().millisecondsSinceEpoch}.png";
      storedImagePath = "${appDir.path}/$imageName";
      await image!.copy(storedImagePath);
    }

    await DatabaseHelper().insertDiary(
      Diary(
        0,
        titleController.text,
        contentController.text,
        formatter.format(DateTime.now()),
        storedImagePath,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Diary entry saved successfully")));
      Navigator.pop(context);
    }
  }
}
