import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.amber,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),
      home: MainPage(),
    );
  }
}

class Product {
  final String title;
  final double price;
  final String image;
  final String category;
  final Rating? rating;

  Product({
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json['rate'].toDouble(),
      count: json['count'],
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var url = Uri.https("fakestoreapi.com", "products");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        products = jsonResponse.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      print('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WU Shop"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                var imgUrl = product.image.isNotEmpty
                    ? product.image
                    : "https://icon-library.com/images/no-picture-available-icon/no-picture-available-icon-20.jpg";

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      product.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("\$${product.price}"),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: 60, // ตั้งค่าความกว้าง
                        height: 60, // ตั้งค่าความสูง
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    var imgUrl = product.image.isNotEmpty
        ? product.image
        : "https://icon-library.com/images/no-picture-available-icon/no-picture-available-icon-20.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15), // เพิ่มขอบโค้งมนให้ภาพ
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                width: MediaQuery.of(context)
                    .size
                    .width, // ให้ความกว้างของภาพเท่ากับหน้าจอ
                height: MediaQuery.of(context).size.width *
                    9 /
                    16, // ให้ความสูงสัมพันธ์กับความกว้าง (16:9)
              ),
            ),
            SizedBox(height: 16),
            Text(
              product.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "\$${product.price}",
              style: TextStyle(
                fontSize: 20.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Category: ${product.category}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Great outerwear jackets for Spring/Autumn/Winter, "
              "various occasions, such as working, hiking, camping, "
              "mountain/rock climbing, cycling, traveling or other outdoor activities.",
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8),
            if (product.rating != null)
              Text(
                "Rating: ${product.rating!.rate}/5 of ${product.rating!.count} ratings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (product.rating != null)
              RatingBar.builder(
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) => print(value),
                minRating: 0,
                itemCount: 5,
                allowHalfRating: true,
                direction: Axis.horizontal,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                initialRating: product.rating!.rate,
              ),
          ],
        ),
      ),
    );
  }
}
