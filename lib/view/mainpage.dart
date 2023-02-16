import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  String _category = 'Coffee';
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;
  // late File _imageFile;
  late String _productName;
  late double _productPrice;
  late String _productCategory;

  List<String> _categories = ['Coffee', 'Juice', 'Food', 'Other'];
  Future<void> _pickImage( ) async {
    print("dddddd");
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
            print("**************************");
            print(pickedFile);
            print("**************************");
            if(pickedFile !=null)
    setState(() {
      _image = File(pickedFile!.path);
    });
            else
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select an Image')));
    print("////////////////////////////");
    print(_image);
    print("////////////////////////////");
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadImage(String imagePath) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(
        'product_images/${DateTime.now().toString()}');
    UploadTask uploadTask = ref.putFile(File(imagePath));
    await uploadTask.whenComplete(() => null);
    final url = await ref.getDownloadURL();
    _uploadData(url);
  }

  void _uploadData(String imageUrl) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      firestore.collection('products').add({
        'nom': _nomController.text,
        'prix': double.parse(_prixController.text),
        'category': _category,
        'imageUrl': imageUrl,
      });
      setState(() {
        _isUploading = false;
        _nomController.clear();
        _prixController.clear();
        _category = 'Coffee';
        _image = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_isUploading) LinearProgressIndicator(),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    hintText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Prix',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pickImage();
                    },
                    icon: Icon(Icons.photo),
                    label: Text('Select Image'),
                  ),
                ),
                SizedBox(height: 16.0),
                if (_image != null) ...[
                  Center(
                    child: Image.file(
                      _image!,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _image != null) {
                        setState(() {
                          _isUploading = true;
                        });
                        uploadImage(_image!.path);
                      }
                    },
                    child: Text('Add Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}