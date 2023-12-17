import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/Category.dart';
import '../Models/Seafood.dart';
import '../constants.dart';

Future<List<Seafood>> fetchSeafoods(String? keyword, int page) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/seafoods?keyword=$keyword&page=$page'),
  );

  if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> data = json.decode(responseBody);
    List<dynamic> seafoodList = data['content'];
    List<Seafood> seafoods =
        seafoodList.map((item) => Seafood.fromJson(item)).toList();

    return seafoods;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<Category>> fetchCategories() async {
  final response = await http.get(Uri.parse('$baseUrl/api/categories'));

  if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);

    List categoriesJson = json.decode(responseBody);
    return categoriesJson.map((json) => Category.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<List<Seafood>> fetchSeafoodsByCategory(
    int categoryId, String? keyword, int page) async {
  final String apiUrl =
      '$baseUrl/api/seafoods/category?categoryId=$categoryId&keyword=$keyword&page=$page';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> data = json.decode(responseBody);
    List<dynamic> seafoodList = data['content'];
    List<Seafood> seafoods =
        seafoodList.map((item) => Seafood.fromJson(item)).toList();

    return seafoods;
  } else {
    throw Exception('Failed to load seafoods');
  }
}
