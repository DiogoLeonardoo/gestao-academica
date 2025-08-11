import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload de arquivos para o Storage
  Future<String> uploadFile(File file, String path) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '$timestamp-${file.path.split('/').last}';
    final fullPath = 'users/$userId/$path/$fileName';
    
    final ref = _storage.ref().child(fullPath);
    final uploadTask = ref.putFile(file);
    
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  // Download de um arquivo do Storage
  Future<String> getDownloadURL(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }

  // Excluir um arquivo do Storage
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  // Listar arquivos em um diretório
  Future<List<Reference>> listFiles(String path) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    final fullPath = 'users/$userId/$path';
    final result = await _storage.ref().child(fullPath).listAll();
    return result.items;
  }
}
