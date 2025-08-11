import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Obter stream de alterações de estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar com e-mail e senha
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Adicionar informações adicionais ao Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Atualizar o nome do usuário no Firebase Auth
    await userCredential.user!.updateDisplayName(name);

    return userCredential;
  }

  // Fazer login com e-mail e senha
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obter dados do perfil do usuário
  Future<Map<String, dynamic>> getUserProfile() async {
    if (_auth.currentUser == null) {
      throw Exception('Usuário não autenticado');
    }
    
    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
        
    return snapshot.data() ?? {};
  }
}
