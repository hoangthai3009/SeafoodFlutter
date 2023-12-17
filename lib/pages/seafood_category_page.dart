import 'package:flutter/material.dart';
import '../Models/Seafood.dart';
import '../Service/SeafoodService.dart';
import 'seafood_detail_page.dart';
import 'package:intl/intl.dart';

class SeafoodCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  SeafoodCategoryPage({required this.categoryId, required this.categoryName});

  @override
  _SeafoodCategoryPageState createState() => _SeafoodCategoryPageState();
}

class _SeafoodCategoryPageState extends State<SeafoodCategoryPage> {
  List<Seafood> seafoods = [];
  int currentPage = 0;
  bool isLoading = false;
  String keyword = '';
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadSeafoods();
  }

  Future<void> _loadSeafoods() async {
    try {
      setState(() => isLoading = true);
      seafoods = await fetchSeafoodsByCategory(
          widget.categoryId, keyword, currentPage);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      // Handle exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  keyword = value;
                  seafoods.clear();
                  currentPage = 0;
                });
                _loadSeafoods();
              },
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm món hải sản',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: seafoods.length,
              itemBuilder: (context, index) {
                return _buildSeafoodItem(seafoods[index]);
              },
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildSeafoodItem(Seafood seafood) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeafoodDetailPage(seafood: seafood),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                seafood.mainImage,
                height: 140.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                seafood.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seafood.category.name,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 20,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: currencyFormat.format(seafood.price),
                            style: const TextStyle(color: Colors.green, fontSize: 18),
                          ),
                          TextSpan(
                            text: ' / ${seafood.unit}',
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
