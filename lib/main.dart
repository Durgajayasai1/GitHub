import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'github_service.dart';  // Import the GitHub service

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GitHubRepoScreen(),
    );
  }
}

class GitHubRepoScreen extends StatefulWidget {
  @override
  _GitHubRepoScreenState createState() => _GitHubRepoScreenState();
}

class _GitHubRepoScreenState extends State<GitHubRepoScreen> {
  final TextEditingController _controller = TextEditingController();
  final GitHubService _gitHubService = GitHubService();
  List<dynamic> _repositories = [];
  bool _loading = false;

  void _fetchRepositories() async {
    setState(() {
      _loading = true;
    });

    try {
      final repositories = await _gitHubService.fetchRepositories(_controller.text);
      setState(() {
        _repositories = repositories;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter GitHub username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _fetchRepositories,
                ),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        final repo = _repositories[index];
                        return ListTile(
                          title: Text(repo['name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RepositoryContentsScreen(
                                  owner: repo['owner']['login'],
                                  repo: repo['name'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class RepositoryContentsScreen extends StatefulWidget {
  final String owner;
  final String repo;

  RepositoryContentsScreen({required this.owner, required this.repo});

  @override
  _RepositoryContentsScreenState createState() => _RepositoryContentsScreenState();
}

class _RepositoryContentsScreenState extends State<RepositoryContentsScreen> {
  final GitHubService _gitHubService = GitHubService();
  List<dynamic> _contents = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchRepositoryContents();
  }

  void _fetchRepositoryContents() async {
    setState(() {
      _loading = true;
    });

    try {
      final contents = await _gitHubService.fetchRepositoryContents(widget.owner, widget.repo);
      setState(() {
        _contents = contents;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contents.length,
              itemBuilder: (context, index) {
                final item = _contents[index];
                return ListTile(
                  title: Text(item['name']),
                  onTap: () {
                    if (item['type'] == 'file') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FileContentScreen(
                            url: item['url'],
                            fileName: item['name'],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}

class FileContentScreen extends StatefulWidget {
  final String url;
  final String fileName;

  FileContentScreen({required this.url, required this.fileName});

  @override
  _FileContentScreenState createState() => _FileContentScreenState();
}

class _FileContentScreenState extends State<FileContentScreen> {
  final GitHubService _gitHubService = GitHubService();
  String _content = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchFileContent();
  }

  void _fetchFileContent() async {
    setState(() {
      _loading = true;
    });

    try {
      final content = await _gitHubService.fetchFileContent(widget.url);
      setState(() {
        _content = content;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () {
              FlutterClipboard.copy(_content).then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied to clipboard'))));
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(_content),
              ),
            ),
    );
  }
}
