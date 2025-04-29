import 'dart:convert';

MenuModel menuModelFromJson(String str) => MenuModel.fromJson(json.decode(str));

String menuModelToJson(MenuModel data) => json.encode(data.toJson());

class MenuModel {
    List<MenuItem> hafta1;
    List<MenuItem> hafta2;
    List<MenuItem> hafta3;
    List<MenuItem> hafta4;

    MenuModel({
        required this.hafta1,
        required this.hafta2,
        required this.hafta3,
        required this.hafta4,
    });

    factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        hafta1: List<MenuItem>.from(json["hafta_1"].map((x) => MenuItem.fromJson(x))),
        hafta2: List<MenuItem>.from(json["hafta_2"].map((x) => MenuItem.fromJson(x))),
        hafta3: List<MenuItem>.from(json["hafta_3"].map((x) => MenuItem.fromJson(x))),
        hafta4: List<MenuItem>.from(json["hafta_4"].map((x) => MenuItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "hafta_1": List<dynamic>.from(hafta1.map((x) => x.toJson())),
        "hafta_2": List<dynamic>.from(hafta2.map((x) => x.toJson())),
        "hafta_3": List<dynamic>.from(hafta3.map((x) => x.toJson())),
        "hafta_4": List<dynamic>.from(hafta4.map((x) => x.toJson())),
    };
}

class MenuItem {
    String gun;
    String corba;
    String anaYemek;
    String karbonhidrat;
    String yanci;

    MenuItem({
        required this.gun,
        required this.corba,
        required this.anaYemek,
        required this.karbonhidrat,
        required this.yanci,
    });

    factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        gun: json["gun"],
        corba: json["corba"],
        anaYemek: json["ana_yemek"],
        karbonhidrat: json["karbonhidrat"],
        yanci: json["yanci"],
    );

    Map<String, dynamic> toJson() => {
        "gun": gun,
        "corba": corba,
        "ana_yemek": anaYemek,
        "karbonhidrat": karbonhidrat,
        "yanci": yanci,
    };
}
