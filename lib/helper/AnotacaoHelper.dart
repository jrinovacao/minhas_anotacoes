import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class AnotacaoHelper{

  static final String nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();

  Database _db;


  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){
  }

  get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await inicializaDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async{
    String sql = "CREATE TABLE $nomeTabela(id INTEGER PRIMARY KEY AUTOINCREMENT,"
        " titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  inicializaDB() async {
    final caminhoBandodeDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBandodeDados, "banco_minhas_anotacoes.db");
    
    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;

  }


   Future<int> salvarAnotacao(Anotacao anotacao) async{

    var bancoDados = await db;

    int id = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return id;

  }


  recuperarAnotacoes() async{

    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);

    return anotacoes;

  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async{

    var bancoDados = await db;
    return await bancoDados.update(
      nomeTabela,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id]
    );

  }


  Future<int> removerAnotacao(int id) async{

    var bancoDados = await db;
    return await bancoDados.delete(
        nomeTabela,
        where: "id = ?",
        whereArgs: [id]
    );


  }

}