import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/materia.dart';
import '../models/atividade.dart';
import '../models/convidado.dart';

class MateriaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter coleção de matérias
  CollectionReference<Map<String, dynamic>> get _materiasCollection =>
      _firestore.collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('materias');

  // Obter todas as matérias
  Stream<List<Materia>> getMaterias() {
    return _materiasCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Materia(
          id: doc.id,
          nome: data['nome'] ?? '',
          descricao: data['descricao'] ?? '',
        );
      }).toList();
    });
  }

  // Obter uma matéria específica com suas atividades
  Stream<Materia> getMateria(String materiaId) {
    return _materiasCollection.doc(materiaId).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return Materia(
        id: doc.id,
        nome: data['nome'] ?? '',
        descricao: data['descricao'] ?? '',
      );
    });
  }

  // Adicionar uma nova matéria
  Future<DocumentReference> addMateria(String nome, String descricao) {
    return _materiasCollection.add({
      'nome': nome,
      'descricao': descricao,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Atualizar uma matéria
  Future<void> updateMateria(String materiaId, String nome, String descricao) {
    return _materiasCollection.doc(materiaId).update({
      'nome': nome,
      'descricao': descricao,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Excluir uma matéria
  Future<void> deleteMateria(String materiaId) {
    return _materiasCollection.doc(materiaId).delete();
  }

  // Obter atividades de uma matéria
  Stream<List<Atividade>> getAtividades(String materiaId) {
    return _materiasCollection
        .doc(materiaId)
        .collection('atividades')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Converter a lista de mapas de convidados de volta para objetos Convidado
        List<Convidado> convidados = [];
        if (data['convidados'] != null) {
          final convidadosData = data['convidados'] as List<dynamic>;
          convidados = convidadosData.map((c) => Convidado(
            id: c['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            nome: c['nome'] ?? '',
            email: c['email'] ?? '',
          )).toList();
        }
        
        return Atividade(
          id: doc.id,
          titulo: data['titulo'] ?? '',
          descricao: data['descricao'] ?? '',
          dataLimite: (data['dataLimite'] as Timestamp).toDate(),
          status: data['status'] == 'concluido'
              ? StatusAtividade.concluido
              : StatusAtividade.pendente,
          convidados: convidados,
        );
      }).toList();
    });
  }

  // Adicionar uma atividade a uma matéria
  Future<DocumentReference> addAtividade(
      String materiaId, Atividade atividade) {
    // Converter a lista de convidados para uma lista de mapas
    List<Map<String, dynamic>> convidadosMap = [];
    if (atividade.convidados.isNotEmpty) {
      convidadosMap = atividade.convidados.map((convidado) => {
        'id': convidado.id,
        'nome': convidado.nome,
        'email': convidado.email,
      }).toList();
    }

    return _materiasCollection.doc(materiaId).collection('atividades').add({
      'titulo': atividade.titulo,
      'descricao': atividade.descricao,
      'dataLimite': Timestamp.fromDate(atividade.dataLimite),
      'status': atividade.status == StatusAtividade.concluido
          ? 'concluido'
          : 'pendente',
      'convidados': convidadosMap,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Atualizar uma atividade
  Future<void> updateAtividade(
      String materiaId, String atividadeId, Atividade atividade) {
    // Converter a lista de convidados para uma lista de mapas
    List<Map<String, dynamic>> convidadosMap = [];
    if (atividade.convidados.isNotEmpty) {
      convidadosMap = atividade.convidados.map((convidado) => {
        'id': convidado.id,
        'nome': convidado.nome,
        'email': convidado.email,
      }).toList();
    }
    
    return _materiasCollection
        .doc(materiaId)
        .collection('atividades')
        .doc(atividadeId)
        .update({
      'titulo': atividade.titulo,
      'descricao': atividade.descricao,
      'dataLimite': Timestamp.fromDate(atividade.dataLimite),
      'status': atividade.status == StatusAtividade.concluido
          ? 'concluido'
          : 'pendente',
      'convidados': convidadosMap,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Excluir uma atividade
  Future<void> deleteAtividade(String materiaId, String atividadeId) {
    return _materiasCollection
        .doc(materiaId)
        .collection('atividades')
        .doc(atividadeId)
        .delete();
  }
}
