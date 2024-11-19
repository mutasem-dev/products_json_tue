import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'product.dart';

void main() {
  runApp(const MyApp());
}

TextEditingController nameController = TextEditingController();
TextEditingController quantityController = TextEditingController();
TextEditingController priceController = TextEditingController();

List<Product> products = [];

Future<List<Product>> fetchProducts() async {
  var response = await http.get(Uri.parse('https://www.jsonkeeper.com/b/OPMM'));
  if (response.statusCode == 200) {
    //print(response.body);
    var jsonArr = jsonDecode(response.body) as List;
    return jsonArr.map((e) => Product.fromJson(e)).toList();
  }
  return [];
  // var jsonArr = jsonDecode(jsonString) as List;
  // products = jsonArr.map((e) => Product.fromJson(e)).toList();
  // jsonArr.forEach((element) {
  //   Product p = Product.fromJson(element);
  //   products.add(p);
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      theme: ThemeData(
        useMaterial3: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Product>> futureProducts;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Products app'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Products: ',
                style: TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'add new product',
                            style: TextStyle(fontSize: 25),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'name',
                                  ),
                                ),
                                TextField(
                                  controller: quantityController,
                                  decoration: InputDecoration(
                                    labelText: 'quantity',
                                  ),
                                ),
                                TextField(
                                  controller: priceController,
                                  decoration: InputDecoration(
                                    labelText: 'price',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  products.add(Product(
                                      name: nameController.text,
                                      quantity:
                                          int.parse(quantityController.text),
                                      price:
                                          double.parse(priceController.text)));
                                  nameController.clear();
                                  quantityController.clear();
                                  priceController.clear();
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: Text('add')),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('cancel')),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('add product')),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder<List<Product>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                products = snapshot.data!;
                if (products.isEmpty) {
                  return Text('no products added');
                } else {
                  return Expanded(
                      child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.blue,
                          onTap: () {},
                          leading: Text(
                            products[index].name,
                            style: TextStyle(fontSize: 22),
                          ),
                          title: Text('Quantity: ${products[index].quantity}'),
                          subtitle: Text('Price: ${products[index].price}'),
                          trailing: IconButton(
                              onPressed: () {
                                products.removeAt(index);
                                setState(() {});
                              },
                              icon: Icon(Icons.delete_forever)),
                        ),
                      );
                    },
                  ));
                }
              } else if (snapshot.hasError) {
                return Text('erorr: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          products.clear();
          setState(() {});
        },
        child: Icon(Icons.delete_sweep),
      ),
    );
  }
}
