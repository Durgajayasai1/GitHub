import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String baseUrl = 'https://api.github.com';

  Future<List<dynamic>> fetchRepositories(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$username/repos'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<List<dynamic>> fetchRepositoryContents(String owner, String repo) async {
    final response = await http.get(Uri.parse('$baseUrl/repos/$owner/$repo/contents'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load repository contents');
    }
  }

  Future<String> fetchFileContent(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final content = json.decode(response.body)['content'];
      return utf8.decode(base64.decode(content));
    } else {
      throw Exception('Failed to load file content');
    }
  }
}
