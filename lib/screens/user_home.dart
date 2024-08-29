import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news_app/models/api_news.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<News> _newsList = [];
  bool _isLoading = true;
  String _selectedCategory = 'Automotive'; // Default category

  final List<String> _categories = [
    'Automotive',
    'Technology',
    'Business',
    'Entertainment',
    'Sports',
    'Lokal'
  ];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=tesla&from=2024-07-29&sortBy=publishedAt&apiKey=ae0bc125235245758579c70433b037d9'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['articles'];
      setState(() {
        _newsList = body.map((dynamic item) => News.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  void _logout() {
    // Implementasi logika log out
    Navigator.of(context).pop();
    // Arahkan ke halaman login atau lakukan proses log out lainnya
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Latar belakang berwarna
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'assets/logo.png', // Path ke logo yang ingin ditampilkan
            height: 40,
          ),
        ),
        elevation: 0, // Menghapus background berwarna ungu saat scroll
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('Danang'), // Ganti dengan nama user yang sebenarnya
                accountEmail: Text('user@mrnews.com'), // Ganti dengan email user yang sebenarnya
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'), // Gambar profil
                  backgroundColor: Colors.white,
                ),
                decoration: BoxDecoration(color: Colors.red),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                    fetchNews(); // Fetch news berdasarkan kategori yang dipilih
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Chip(
                      label: Text(
                        _categories[index],
                        style: TextStyle(
                          color: _selectedCategory == _categories[index]
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      backgroundColor: _selectedCategory == _categories[index]
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dua berita per baris
                  childAspectRatio: 0.6, // Atur rasio aspek
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _newsList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailScreen(
                            news: _newsList[index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _newsList[index].urlToImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15)),
                            child: Image.network(
                              _newsList[index].urlToImage!,
                              height: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.3,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _newsList[index].title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _newsList[index]
                                      .publishedAt
                                      .substring(0, 10),
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _newsList[index].description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class NewsDetailScreen extends StatelessWidget {
  final News news;

  NewsDetailScreen({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            news.urlToImage != null
                ? Image.network(news.urlToImage!)
                : Container(),
            SizedBox(height: 10),
            Text(
              news.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              news.publishedAt.substring(0, 10),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(news.description),
          ],
        ),
      ),
    );
  }
}

// Contoh implementasi halaman profil
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Danang'; // Nama default, bisa diganti dengan nama sebenarnya

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
  }

  void _editName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Nama'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Masukkan nama baru',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                setState(() {
                  _userName = _nameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'), // Gambar profil
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              _userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'user@mrnews.com', // Ganti dengan email user yang sebenarnya
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editName,
              child: Text('Edit Nama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna tombol
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Contoh implementasi halaman about
class AboutScreen extends StatelessWidget {
  final String _youtubeUrl = 'https://youtu.be/gTrBPAHMjuA'; // Ganti dengan URL YouTube yang diinginkan

  void _launchURL() async {
    if (await canLaunch(_youtubeUrl)) {
      await launch(_youtubeUrl);
    } else {
      throw 'Could not launch $_youtubeUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Path ke logo aplikasi
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Aplikasi ini dibuat untuk memberikan berita terbaru '
                    'dari berbagai kategori seperti teknologi, bisnis, hiburan, '
                    'dan lainnya. Diharapkan aplikasi ini dapat menjadi sumber informasi '
                    'yang bermanfaat bagi pengguna.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _launchURL,
                icon: Icon(Icons.video_library),
                label: Text('Kunjungi YouTube Kami'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Warna tombol
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Contoh implementasi halaman login (untuk logout)
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Path ke logo aplikasi
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Anda telah berhasil keluar dari aplikasi. '
                    'Terima kasih telah menggunakan aplikasi ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
