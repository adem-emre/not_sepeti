

class Kategori{

  int kategoriID;
  String kategoriBaslik;
  //kategori eklerken kullan çünkü id db tarafından oluşturuluyor
  Kategori(this.kategoriBaslik);
  //kategorileri db den okurken kullanılır
  Kategori.withID(this.kategoriID,this.kategoriBaslik);

  Map<String,dynamic> toMap(){
    var map=Map<String,dynamic>();
    map['kategoriID']=kategoriID;
    map['kategoriBaslik']=kategoriBaslik;

    return map;

  }

  Kategori.fromMap(Map<String,dynamic> map){
    this.kategoriID=map['kategoriID'];
    this.kategoriBaslik=map['kategoriBaslik'];

  }
  @override
  String toString() {
    return 'Kategori{kategoriID: $kategoriID, kategoriBaslik: $kategoriBaslik}';
  }
}