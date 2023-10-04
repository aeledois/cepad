import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cepad/util.dart';

final Image casaImg = Image.asset('assets/icons/casa.png', height: 100);

class Endereco {
  final String logradouro;
  final String bairro;
  final String localidade;

  const Endereco({
    required this.logradouro,
    required this.bairro,
    required this.localidade,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
        logradouro: json["logradouro"],
        bairro: json["bairro"],
        localidade: json["localidade"]);
  }
}

Future<Endereco> fetchEndereco(String cep) async {
  var u = 'https://viacep.com.br/ws/$cep/json';
  final response = await http.get(Uri.parse(u));

  if (response.statusCode == 200) {
    var endereco = Endereco.fromJson(jsonDecode(response.body));
    return endereco;
  } else {
    throw Exception('${response.statusCode}: Falha do cep  $cep');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta CEP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Consulta CEP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _cep = " ";
  final tController = TextEditingController();
  late Future<Endereco> futureEnde;
  Random random =  Random();

  @override
  void initState() {
    anuncioBanner.load();
    futureEnde = fetchEndereco('00000-000');
    super.initState();
  }

  void _btpressed() {
    _cep = tController.text;
    _cep = '${_cep.substring(0,5)}-${_cep.substring(5)}';
    setState(() {
      futureEnde = fetchEndereco(_cep);
      if (random.nextInt(2) == 1) {
        if (interstitialAd == null) createInterstitialAd();
        if (interstitialAd != null) showInterstitialAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
        titleTextStyle: titst,
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            casaImg,
            Text(
              'Número do CEP:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: bd0,
              child: TextField(
                controller: tController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(8)
                ],
                style: ts,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'somente números',
                  hintStyle: hst,
                ),
                autofocus: false,
              ),
            ),
            FloatingActionButton.extended(
                onPressed: _btpressed,
                label: const Text('Buscar'),
                icon: const Icon(Icons.home),
                extendedPadding: btedge,
                backgroundColor: btCor),
            FutureBuilder<Endereco>(
              future: futureEnde,
              builder: (cont, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    clipBehavior: Clip.hardEdge,
                    child: Text(
                      """
CEP:$_cep
Rua: ${snapshot.data!.logradouro}
Bairro:${snapshot.data!.bairro}
Cidade:${snapshot.data!.localidade}""",
                      style: titst,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text(' ');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),

          ],

        ),

      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        height: anuncioBanner.size.height.toDouble(),
        // height: 100,
        child: AdWidget(ad: anuncioBanner),
      ),
    );
  }
}

const ts = TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 171, 182, 208));
const btCor = Color.fromARGB(255, 11, 140, 245);
const btedge = EdgeInsets.only(left: 5.0, top: 0.0, right: 5.0, bottom: 0.0);
const hst =
    TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 224, 168, 168));
const titst = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 24, 45, 14));
var bd0 = BoxDecoration(
  color: const Color.fromARGB(255, 38, 49, 84),
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 3,
      blurRadius: 7,
      offset: const Offset(0, 3),
    ),
  ],
);
