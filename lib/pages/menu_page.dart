import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/Seafood.dart';
import '../Models/Category.dart';
import '../Service/SeafoodService.dart';
import 'seafood_category_page.dart';
import 'seafood_detail_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Seafood> seafoods = [];
  List<Category> categories = [];
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  String keyword = '';
  bool isLoading = false;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadMoreData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _fetchCategories();
  }

  Future<void> _loadMoreData() async {
    try {
      setState(() => isLoading = true);
      List<Seafood> newSeafoods = await fetchSeafoods(keyword, currentPage);
      setState(() {
        seafoods.addAll(newSeafoods);
        isLoading = false;
        currentPage++;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng hải sản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: _buildContentPage(),
    );
  }

  Widget _buildContentPage() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildCategoryList(),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _buildSeafoodItem(seafoods[index]);
            },
            childCount: seafoods.length,
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeafoodCategoryPage(
                    categoryId: categories[index].id,
                    categoryName: categories[index].name,
                  ),
                ),
              );
            },
            child: Container(
              width: 80.0,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(categories[index].img),
                    radius: 30.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    categories[index].name,
                    style: const TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          keyword = value;
          seafoods.clear();
          currentPage = 0;
        });
        _loadMoreData();
      },
      decoration: const InputDecoration(
        labelText: 'Search',
        suffixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSeafoodItem(Seafood seafood) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    elevation: 5,
    shadowColor: Colors.grey[400],
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            child: Image.network(
              seafood.mainImage,
              height: 130.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  seafood.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  seafood.category.name,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currencyFormat.format(seafood.price),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${seafood.unit}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
