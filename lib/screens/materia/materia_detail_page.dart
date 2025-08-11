import 'package:flutter/material.dart';
import '../../models/materia.dart';
import '../../models/atividade.dart';
import '../../services/materia_service.dart';
import '../../widgets/cards/atividade_card.dart';
import '../../widgets/dialogs/adicionar_atividade_dialog.dart';
import '../atividade/atividade_detail_page.dart';

class MateriaDetailPage extends StatefulWidget {
  final Materia materia;

  const MateriaDetailPage({Key? key, required this.materia}) : super(key: key);

  @override
  _MateriaDetailPageState createState() => _MateriaDetailPageState();
}

class _MateriaDetailPageState extends State<MateriaDetailPage> {
  final MateriaService _materiaService = MateriaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materia.nome),
        backgroundColor: Colors.blue[600],
      ),
      body: StreamBuilder<List<Atividade>>(
        stream: _materiaService.getAtividades(widget.materia.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar atividades: ${snapshot.error}'),
            );
          }

          final atividades = snapshot.data ?? [];
          
          return atividades.isEmpty
            ? _buildEmptyState()
            : _buildAtividadesList(atividades);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarAtividade,
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
          Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Nenhuma atividade cadastrada',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAtividadesList(List<Atividade> atividades) {
    return ListView.builder(
      itemCount: atividades.length,
      itemBuilder: (context, index) {
        final atividade = atividades[index];
        return AtividadeCard(
          atividade: atividade,
          onTap: () => _navegarParaAtividade(atividade),
          onToggleStatus: () => _toggleStatus(atividade),
          onDelete: () => _excluirAtividade(atividade),
        );
      },
    );
  }

  void _navegarParaAtividade(Atividade atividade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtividadeDetailPage(
          atividade: atividade,
          materiaId: widget.materia.id,
        ),
      ),
    );
  }

  void _toggleStatus(Atividade atividade) {
    // Atualize o status no Firestore
    final novoStatus = atividade.status == StatusAtividade.pendente
        ? StatusAtividade.concluido
        : StatusAtividade.pendente;
    
    final atividadeAtualizada = Atividade(
      id: atividade.id,
      titulo: atividade.titulo,
      descricao: atividade.descricao,
      dataLimite: atividade.dataLimite,
      status: novoStatus,
      convidados: atividade.convidados,
    );
    
    _materiaService.updateAtividade(widget.materia.id, atividade.id, atividadeAtualizada);
  }

  void _excluirAtividade(Atividade atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a atividade "${atividade.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _materiaService.deleteAtividade(widget.materia.id, atividade.id);
              Navigator.pop(context);
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _adicionarAtividade() {
    showDialog(
      context: context,
      builder: (context) => AdicionarAtividadeDialog(),
    ).then((atividade) {
      if (atividade != null) {
        _materiaService.addAtividade(widget.materia.id, atividade);
      }
    });
  }
}