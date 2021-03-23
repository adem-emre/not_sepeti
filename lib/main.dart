import 'package:flutter/material.dart';
import 'kategori_islemleri.dart';
import 'models/kategori.dart';
import 'not_detay.dart';
import 'utils/database_helper.dart';

import 'models/notlar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatefulWidget {
  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Not Sepeti"),
        ),
        actions: <Widget>[
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: ListTile(
                leading: Icon(Icons.category),
                title: Text("Kategoriler"),
                onTap: () => _kategorilerSayfasinaGit(context),
              ))
            ];
          }),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "KategoriEkle",
            onPressed: () {
              kategoriEkle(context);
            },
            tooltip: "Kategori Ekle",
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: "NotEkle",
            onPressed: () => _detaySayfasinaGit(context),
            tooltip: "Not Ekle",
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkle(BuildContext context) {
   
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      yeniKategoriAdi = yeniDeger;
                    },
                    decoration: InputDecoration(
                        labelText: "Kategori Adı",
                        border: OutlineInputBorder()),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 3) {
                        return "Hata En Az 3 Karakter Giriniz";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriEkle(Kategori(yeniKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Kategori Eklendi"),
                              duration: Duration(seconds: 2),
                            ));
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.redAccent,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Yeni Not",
                )));
  }

  void _kategorilerSayfasinaGit(BuildContext context) {
    
    Navigator.push(context,MaterialPageRoute(builder: (context) => Kategoriler())).then((value)=>setState((){}));
        
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
  
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();  
    
  }
  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: databaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snaphot) {
        if (snaphot.connectionState == ConnectionState.done) {
          tumNotlar = snaphot.data;

          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIkonuAta(tumNotlar[index].notOncelik),
                  title: Text(tumNotlar[index].notBaslik),
                  subtitle: Text(tumNotlar[index].kategoriBaslik),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Olusturulma Tarihi ",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(DateTime.parse(
                                      tumNotlar[index].notTarih)),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Icerik : \n" + tumNotlar[index].notIcerik),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FlatButton(
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notID),
                                  child: Text("Sil")),
                              FlatButton(
                                  onPressed: () {
                                    _detaySayfasinaGit(
                                        context, tumNotlar[index]);
                                  },
                                  child: Text(
                                    "Güncelle",
                                    style: TextStyle(color: Colors.green),
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _oncelikIkonuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "AZ",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "ORTA",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text(
            "ACİL",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        );
        break;
    }
  }

  _detaySayfasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Notu Düzenle",
                  duzenlenecekNot: not,
                )));
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Not Silindi")));
      }
    });

    setState(() {});
  }
}
