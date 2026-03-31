import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'User Manager Pro',
    home: const MenuPrincipal(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
    ),
  ));
}

// --- TELA 1: MENU PRINCIPAL (ESTILIZADA) ---
class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade800, Colors.indigo.shade500],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_tree_rounded, size: 80, color: Colors.indigo),
                  const SizedBox(height: 20),
                  const Text(
                    "Gerenciador FullStack",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text("Desenvolvido por Felipe Salazar", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  _buildMenuButton(
                    context, 
                    "CADASTRAR", 
                    Icons.person_add_alt_1, 
                    const TelaCadastro()
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    context, 
                    "LISTAR E GERENCIAR", 
                    Icons.view_list_rounded, 
                    const TelaListagem()
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, Widget tela) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => tela)),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- TELA 2: CADASTRO (POST) ---
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Future<void> salvar() async {
    if (_nomeCtrl.text.isEmpty || _emailCtrl.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/users'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nome": _nomeCtrl.text, "email": _emailCtrl.text}),
      );
      if (res.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✨ Usuário criado com sucesso!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Erro de conexão")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Cadastro"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500), // Correção aplicada aqui!
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                TextField(
                  controller: _nomeCtrl,
                  decoration: InputDecoration(
                    labelText: "Nome Completo",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: salvar,
                    child: const Text("FINALIZAR CADASTRO", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- TELA 3: LISTAGEM (GET, PUT, DELETE) ---
class TelaListagem extends StatefulWidget {
  const TelaListagem({super.key});
  @override
  State<TelaListagem> createState() => _TelaListagemState();
}

class _TelaListagemState extends State<TelaListagem> {
  Future<List> buscar() async {
    final res = await http.get(Uri.parse('http://localhost:3000/users'));
    return jsonDecode(res.body);
  }

  Future<void> deletar(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/users/$id'));
    setState(() {}); // Recarrega a lista
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Removido")));
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
      appBar: AppBar(title: const Text("Usuários Ativos"), centerTitle: true),
      body: FutureBuilder<List>(
        future: buscar(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: lista.length,
            itemBuilder: (context, i) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(lista[i]['nome'][0].toUpperCase(), style: const TextStyle(color: Colors.indigo)),
                ),
                title: Text(lista[i]['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lista[i]['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      onPressed: () => mostrarDialogoEdicao(lista[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                      onPressed: () => deletar(lista[i]['id']),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}