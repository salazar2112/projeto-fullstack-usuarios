import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: const MenuPrincipal(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
  ));
}

// --- ETAPA 1: MENU PRINCIPAL ---
class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciador Full Stack")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaCadastro())),
              label: const Text("CADASTRAR USUÁRIO"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaListagem())),
              label: const Text("LISTAR E GERENCIAR"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ETAPA 2: TELA DE CADASTRO (POST) ---
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> salvarUsuario() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/users'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nome": _nomeController.text, "email": _emailController.text}),
      );

      if (response.statusCode == 201) {
        _nomeController.clear();
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Usuário cadastrado!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Erro de conexão")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "E-mail")),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: salvarUsuario, child: const Text("Salvar"))
          ],
        ),
      ),
    );
  }
}

// --- ETAPA 3: TELA DE LISTAGEM (GET, PUT, DELETE) ---
class TelaListagem extends StatefulWidget {
  const TelaListagem({super.key});
  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  Future<List> buscarUsuarios() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));
    return jsonDecode(response.body);
  }

  Future<void> deletarUsuario(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/users/$id'));
    setState(() {}); // Atualiza a tela
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Usuário removido")));
  }

  void mostrarDialogoEdicao(Map usuario) {
    final nomeEdit = TextEditingController(text: usuario['nome']);
    final emailEdit = TextEditingController(text: usuario['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Usuário"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeEdit, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: emailEdit, decoration: const InputDecoration(labelText: "E-mail")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              await http.put(
                Uri.parse('http://localhost:3000/users/${usuario['id']}'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"nome": nomeEdit.text, "email": emailEdit.text}),
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Atualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Banco")),
      body: FutureBuilder<List>(
        future: buscarUsuarios(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snapshot.data!;
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(lista[i]['nome']),
              subtitle: Text(lista[i]['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => mostrarDialogoEdicao(lista[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deletarUsuario(lista[i]['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}