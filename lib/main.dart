import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? selectedImage;
  bool imageScanning = false;
  String result = "";
  List<String> keywords = ["Best", "Key", "Scott", "Tails", "Parrot"];
  List<String> keywordsMatch = [];


  selectImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? responseImage = await picker.pickImage(source: ImageSource.camera);
    if (responseImage == null) {
      debugPrint("Something went wrong with your camera");
      return;
    }

    setState(() {
      selectedImage = File(responseImage.path);
      imageScanning = true;
    });

    await textRecognizer();
  }

  textRecognizer() async {
    InputImage inputImage = InputImage.fromFile(selectedImage!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    setState(() {
      result = text;
      imageScanning = false;
    });

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          if (keywords.contains(element.text)) {
            keywordsMatch.add(element.text);
          }
        }
      }
    }

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Rendiet - POC"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImage == null ?
            Column(
              children: [
                GestureDetector(
                  child: Image.asset("assets/scanner.png", width: 200),
                  onTap: selectImage,
                ),
                SizedBox(height: 20,),
                const Text(
                  'Click on the image to take picture',
                ),
              ],
            ) :
            Column(
              children: [
                Image.file(
                  selectedImage!,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(height: 20,),
                imageScanning ?
                Column(
                  children: [
                    CircularProgressIndicator(color: Colors.green,),
                    const Text(
                      'Image detection...',
                    ),
                  ],
                ) :
                Column(
                  children: [
                    Text(result),
                    SizedBox(height: 10,),
                    if(keywordsMatch.isNotEmpty)
                      Text("keywordsMatch : $keywordsMatch", style: TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
