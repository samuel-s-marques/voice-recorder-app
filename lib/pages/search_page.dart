import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _hasText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runSpacing: 5,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Procurar",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(style: BorderStyle.none, width: 0.0),
                        ),
                        suffixIcon: _hasText
                            ? IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF777777),
                                ),
                              )
                            : IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.mic,
                                  color: Color(0xFF777777),
                                ),
                              ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _hasText = true;
                          });
                        } else {
                          setState(() {
                            _hasText = false;
                          });
                        }
                      },
                      autofocus: true,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0.0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Categorias",
                                style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 16),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: -8,
                                children: [
                                  ChoiceChip(
                                    label: const Text("Finanças"),
                                    labelStyle: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 14),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    selected: false,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: Text(
                  "Nada encontrado",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
