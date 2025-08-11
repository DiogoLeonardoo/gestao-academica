import 'package:flutter/material.dart';
import '../../models/materia.dart';
import '../../services/auth_service.dart';
import '../../services/materia_service.dart';
import '../../widgets/cards/materia_card.dart';
import '../../widgets/dialogs/adicionar_materia_dialog.dart';
import '../materia/materia_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final MateriaService _materiaService = MateriaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Atividades'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Materia>>(
        stream: _materiaService.getMaterias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar matérias: ${snapshot.error}'),
            );
          }

          final materias = snapshot.data ?? [];
          
          return materias.isEmpty
            ? _buildEmptyState()
            : _buildMateriasList(materias);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarMateria,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Nenhuma matéria cadastrada',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriasList(List<Materia> materiasList) {
    return ListView.builder(
      itemCount: materiasList.length,
      itemBuilder: (context, index) {
        final materia = materiasList[index];
        return MateriaCard(
          materia: materia,
          onTap: () => _navegarParaMateria(materia),
          onDelete: () => _confirmarExclusaoMateria(materia),
        );
      },
    );
  }
  
  void _confirmarExclusaoMateria(Materia materia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a matéria "${materia.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _materiaService.deleteMateria(materia.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _navegarParaMateria(Materia materia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateriaDetailPage(materia: materia),
      ),
    );
  }

  void _adicionarMateria() {
    showDialog(
      context: context,
      builder: (context) => AdicionarMateriaDialog(),
    ).then((materiaData) {
      if (materiaData != null) {
        // Agora usamos o serviço para adicionar à coleção no Firebase
        _materiaService.addMateria(
          materiaData.nome,
          materiaData.descricao,
        );
      }
    });
  }
}