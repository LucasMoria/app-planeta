import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() => runApp(PlanetApp());

class PlanetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Planetas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanetListScreen(),
    );
  }
}

class PlanetListScreen extends StatefulWidget {
  @override
  _PlanetListScreenState createState() => _PlanetListScreenState();
}

class _PlanetListScreenState extends State<PlanetListScreen> {
  late Database _database;
  List<Map<String, dynamic>> _planets = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
   String path = p.join(await getDatabasesPath(), 'planets.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE planets(id INTEGER PRIMARY KEY, name TEXT, distance REAL, size REAL, nickname TEXT)'
        );
      },
    );
    _fetchPlanets();
  }

  Future<void> _fetchPlanets() async {
    final List<Map<String, dynamic>> planets = await _database.query('planets');
    setState(() {
      _planets = planets;
    });
  }

  Future<void> _addPlanet(String name, double distance, double size, String? nickname) async {
    await _database.insert(
      'planets',
      {'name': name, 'distance': distance, 'size': size, 'nickname': nickname},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _fetchPlanets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planeta adicionado com sucesso!')),
    );
  }

  Future<void> _updatePlanet(int id, String name, double distance, double size, String? nickname) async {
    await _database.update(
      'planets',
      {'name': name, 'distance': distance, 'size': size, 'nickname': nickname},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchPlanets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planeta atualizado com sucesso!')),
    );
  }

  Future<void> _deletePlanet(int id) async {
    await _database.delete(
      'planets',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchPlanets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planeta excluído com sucesso!')),
    );
  }

  void _showPlanetDialog({int? id, String? name, double? distance, double? size, String? nickname}) {
    final _nameController = TextEditingController(text: name);
    final _distanceController = TextEditingController(text: distance?.toString());
    final _sizeController = TextEditingController(text: size?.toString());
    final _nicknameController = TextEditingController(text: nickname);

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(id == null ? 'Adicionar Planeta' : 'Editar Planeta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: _distanceController,
                decoration: InputDecoration(labelText: 'Distância do Sol (UA)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Tamanho (km)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Apelido (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(id == null ? 'Adicionar' : 'Atualizar'),
            onPressed: () {
              final name = _nameController.text.trim();
              final distance = double.tryParse(_distanceController.text) ?? -1;
              final size = double.tryParse(_sizeController.text) ?? -1;
              final nickname = _nicknameController.text.trim();

              if (name.isEmpty || distance <= 0 || size <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preencha os campos obrigatórios corretamente.')),
                );
                return;
              }

              if (id == null) {
                _addPlanet(name, distance, size, nickname.isNotEmpty ? nickname : null);
              } else {
                _updatePlanet(id, name, distance, size, nickname.isNotEmpty ? nickname : null);
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPlanetDetails(Map<String, dynamic> planet) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Detalhes do Planeta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${planet['name']}'),
            Text('Distância do Sol: ${planet['distance']} UA'),
            Text('Tamanho: ${planet['size']} km'),
            Text('Apelido: ${planet['nickname'] ?? 'Sem apelido'}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Fechar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planetas'),
      ),
      body: ListView.builder(
        itemCount: _planets.length,
        itemBuilder: (context, index) {
          final planet = _planets[index];
          return ListTile(
            title: Text(planet['name']),
            subtitle: Text(planet['nickname'] ?? 'Sem apelido'),
            onTap: () => _showPlanetDetails(planet),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Confirmar exclusão'),
                  content: Text('Deseja realmente excluir o planeta ${planet['name']}?'),
                  actions: [
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: Text('Excluir'),
                      onPressed: () {
                        _deletePlanet(planet['id']);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showPlanetDialog(),
      ),
    );
  }
}
