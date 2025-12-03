import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  // Dropdown Values
  String selectedCategory = "T-Shirt";
  String selectedSize = "M";

  // Category Options
  final List<String> categoryList = [
    "T-Shirt",
    "Hoodie",
    "Shirt",
    "Outer",
    "Pants",
    "Skirt",
    "Dress",
  ];

  // Size Options
  final List<String> sizeList = ["XS", "S", "M", "L", "XL", "XXL"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE PLACEHOLDER =================
            GestureDetector(
              onTap: () {
                // Panggil function insert image milikmu di sini
              },
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.add_a_photo, size: 40)),
              ),
            ),

            const SizedBox(height: 20),

            // ================= NAME FIELD =================
            const Text("Product Name"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "example: y2k oversize shirt",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CATEGORY =================
            const Text("Category"),
            DropdownButtonFormField(
              value: selectedCategory,
              items: categoryList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            // ================= BRAND =================
            const Text("Brand"),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                hintText: "example: Uniqlo, H&M, Zara...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ================= SIZE =================
            const Text("Size"),
            DropdownButtonFormField(
              value: selectedSize,
              items: sizeList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSize = value!;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 35),

            // ================= BUTTONS =================
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // balik ke homepage
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 15),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // === MASUKIN LOGIC SAVE DI SINI ===
                      // Kirim data ke database / Firebase dll

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product Saved!")),
                      );

                      Navigator.pop(context); // balik ke homepage
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Save"),
                    
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
  }
}
