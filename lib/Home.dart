import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _abrirTelaCadastro({Anotacao anotacao}){

    String textoSalvarAtualizar = "";
    if(anotacao == null){

      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";

    }else{
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotacao"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Titulo",
                      hintText: "Digite o titulo..."
                  ),
                ),

                TextField(
                  controller: _descricaoController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Descricao",
                      hintText: "Digite a descricao..."
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),

              FlatButton(
                  onPressed: (){

                    //salvar
                      _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                      Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)
              ),
            ],
          );
        }

    );

  }

  _recuperarAnotacoes() async{

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaroa = List<Anotacao>();
    for(var item in anotacoesRecuperadas){

      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaroa.add(anotacao);

    }

    setState(() {
      _anotacoes = listaTemporaroa;
    });

    listaTemporaroa = null;

  }


  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async{
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;


    if( anotacaoSelecionada == null ){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    }else{

      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);

    }





    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();

  }


  _formatarData(String data){

    initializeDateFormatting("pt_BR");
    var formater = DateFormat.yMMMd("pt_BR");
    //var formater = DateFormat("d/M/y  H:m ");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formater.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async{

     await _db.removerAnotacao(id);
     _recuperarAnotacoes();

  }


  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index){

                    final anotacao = _anotacoes[index];

                    return Card(
                      color: Colors.pink,
                      child: ListTile(
                        title: Text(anotacao.titulo),
                        subtitle: Text("${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                 _abrirTelaCadastro(anotacao: anotacao);
                              },
                              child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                ),
                              ),
                            ),


                            GestureDetector(
                              onTap: (){
                                 _removerAnotacao(anotacao.id);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  }

              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            _abrirTelaCadastro();
          }
      ),
    );
  }
}
