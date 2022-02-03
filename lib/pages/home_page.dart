import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_recorder_app/widgets/audio_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Gravar'),
    Tab(text: 'Lista'),
  ];

  late TabController _tabController;
  bool _recording = false;
  int timer = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Gravador de Voz",
          style: GoogleFonts.getFont(
            "Inter",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF323232),
            ),
          )
        ],
        bottom: TabBar(
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4.0, color: Color(0xFF495BFF)),
          ),
          labelColor: const Color(0xFF495BFF),
          labelStyle: GoogleFonts.getFont(
            "Inter",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          unselectedLabelColor: const Color(0xFF23262F),
          tabs: const [
            Tab(
              text: "Gravar",
            ),
            Tab(text: "Lista")
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              Text(
                "00:00:00",
                style: GoogleFonts.getFont(
                  "Inter",
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                  color: const Color(0xFF23262F),
                ),
              ),
              Text(
                "Alta qualidade",
                style: GoogleFonts.getFont(
                  "Inter",
                  fontWeight: FontWeight.w300,
                  fontSize: 24,
                  color: const Color(0xFF777777),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close),
                      ),
                      visible: timer > 4 ? true : false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _recording = !_recording;
                            timer += 1;
                          });
                        },
                        child: _recording ? const Icon(Icons.pause) : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(_recording ? const Color(0xFFFF5656) : Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(color: Color(0xFFFF5656), width: 8),
                          )),
                        ),
                      ),
                    ),
                    Visibility(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.check),
                        ),
                      ),
                      visible: timer > 4 ? true : false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                    ),
                  ],
                ),
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextField(
                      onTap: () => Navigator.pushNamed(context, "/search"),
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Procurar",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(style: BorderStyle.none, width: 0.0),
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ),
                  DropdownButton(
                    items: [].map((value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (_) {},
                    hint: Text(
                      "Categoria",
                      style: GoogleFonts.getFont(
                        "Inter",
                        color: const Color(0xFF23262F),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down_outlined,
                      color: Color(0xFF323232),
                      size: 24,
                    ),
                    underline: const SizedBox(),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 5),
                    itemCount: 7,
                    itemBuilder: (BuildContext context, int index) => AudioCard(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
