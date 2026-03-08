import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CatHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CatHomePage extends StatefulWidget {
  const CatHomePage({super.key});

  @override
  State<CatHomePage> createState() => _CatHomePageState();
}

class _CatHomePageState extends State<CatHomePage> {
  String fact = "";
  String imageUrl = "";

  bool loading = false;

  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;

  /// -------------------------
  /// API CALL
  /// -------------------------

  Future<void> fetchCat() async {
    setState(() => loading = true);

    try {
      final factResponse =
          await http.get(Uri.parse("https://catfact.ninja/fact"));

      final imageResponse = await http.get(
        Uri.parse("https://api.thecatapi.com/v1/images/search"),
      );

      final factJson = jsonDecode(factResponse.body);
      final imageJson = jsonDecode(imageResponse.body);

      setState(() {
        fact = factJson["fact"];
        imageUrl = imageJson[0]["url"];
      });
    } catch (e) {
      fact = "API error";
    }

    setState(() => loading = false);
  }

  /// -------------------------
  /// Background randomizer
  /// -------------------------

  void changeBackground() {
    final random = Random();

    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );

    final brightness =
        (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114);

    final textColor = brightness > 160 ? Colors.black : Colors.white;

    setState(() {
      backgroundColor = color;
      this.textColor = textColor;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCat();
    changeBackground();
  }

  /// -------------------------
  /// UI
  /// -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text("Cat Explorer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              if (loading)
                CircularProgressIndicator(color: textColor),

              if (!loading && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 24),

              if (!loading)
                Text(
                  fact,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchCat();
          changeBackground();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}