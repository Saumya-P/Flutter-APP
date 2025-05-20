
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyAppId = 'wmBhYHJlvM50vW4BWkInY8NJ7yGG0OjtR96kiR5O';
  const keyClientKey = 'tBPFUANGM4Lo4MzpAvGLUF1tDZnU7hM2HhN6xB2E';
  const keyParseServerUrl = 'https://parseapi.back4app.com';
 
  await Parse().initialize(
    keyAppId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    debug: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Back4App Flutter CRUD',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String text, {bool error = true}) {
    final color = error ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  Future<void> login() async {
    setState(() => _isLoading = true);
    final user = ParseUser(_usernameController.text.trim(), _passwordController.text.trim(), null);
    final response = await user.login();

    setState(() => _isLoading = false);

    if (response.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      _showMessage(response.error?.message ?? 'Login failed');
    }
  }

  Future<void> signUp() async {
    setState(() => _isLoading = true);
    final email = '${_usernameController.text.trim()}@email.com';
    final user = ParseUser(_usernameController.text.trim(), _passwordController.text.trim(), email);
    final response = await user.signUp();

    setState(() => _isLoading = false);

    if (response.success) {
      _showMessage("Account created! Please log in.", error: false);
    } else {
      _showMessage(response.error?.message ?? 'Sign up failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome To Back4App 2023tm93680")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 100, color: Color.fromARGB(255, 95, 75, 4)),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: login,
                            icon: const Icon(Icons.login),
                            label: const Text("Login"),
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: signUp,
                            icon: const Icon(Icons.person_add),
                            label: const Text("Sign Up"),
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _itemController = TextEditingController();
  List<ParseObject> items = [];

  Future<void> fetchItems() async {
    final query = QueryBuilder(ParseObject('Item'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() => items = List<ParseObject>.from(response.results!));
    }
  }

  Future<void> addItem() async {
    if (_itemController.text.trim().isEmpty) return;
    final item = ParseObject('Item')..set('name', _itemController.text.trim());
    await item.save();
    _itemController.clear();
    fetchItems();
  }

  Future<void> deleteItem(ParseObject item) async {
    await item.delete();
    fetchItems();
  }

  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser;
    await user.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Items"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(labelText: "Add new item"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addItem,
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text("No items yet."))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.get<String>('name') ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 97, 1, 1)),
                          onPressed: () => deleteItem(item),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
