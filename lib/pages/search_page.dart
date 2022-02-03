import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF323232)),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
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
                                style: GoogleFonts.getFont(
                                  "Inter",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: const Color(0xFF23262F),
                                ),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: -8,
                                children: [
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                  ),
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                  ),
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                  ),
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                  ),
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                  ),
                                  ActionChip(
                                    label: Text(
                                      "Finanças",
                                      style: GoogleFonts.getFont(
                                        "Inter",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: const Color(0xFF23262F),
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFEFEFEF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
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
                  style: GoogleFonts.getFont(
                    "Inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF969AA0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
