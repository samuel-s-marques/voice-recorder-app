import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:voice_recorder_app/utils/utils.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    void saveCategoryBottomSheet() async {
      TextEditingController _categoryTitle = TextEditingController();

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: Container(
                  color: const Color(0xFFF2F2F2),
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Criar categoria",
                          style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 20),
                        ),
                      ),
                      TextField(
                        controller: _categoryTitle,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]"))],
                        maxLength: 30,
                        decoration: const InputDecoration(
                          labelText: "Título da categoria",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            footerBuilder: (context, state) {
              return Container(
                color: const Color(0xFFF2F2F2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancelar",
                                style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 16),
                              ),
                              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.secondary)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_categoryTitle.text.trim().isNotEmpty) {
                                  Directory? applicationDirectory = await getApplicationSupportDirectory();
                                  Directory categories = Directory("${applicationDirectory.path}/audios/${_categoryTitle.text.trim()}");

                                  await categories.create();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                "Salvar",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 16, color: Theme.of(context).buttonTheme.colorScheme?.secondary),
                              ),
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).buttonTheme.colorScheme?.primary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorias"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]"))],
                  decoration: const InputDecoration(
                    hintText: "Pesquisar",
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF777777),
                    ),
                  ),
                  onChanged: (value) {},
                ),
              ),
              FutureBuilder(
                future: getDirectory(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    Directory dir = snapshot.data;
                    List<FileSystemEntity> categories = dir.listSync(recursive: true, followLinks: false);

                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          "Nada encontrado",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const SizedBox(height: 5),
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (categories[index].statSync().type != FileSystemEntityType.directory) {
                          return Container();
                        }

                        Directory category = Directory(categories[index].path);

                        DateFormat dayFormat = DateFormat.yMd();
                        DateFormat timeFormat = DateFormat.Hm();
                        DateTime createdAt = category.statSync().modified;
                        String createdAtFormatted = "";
                        String categoryName = category.name ?? "Categoria";

                        if (createdAt.isToday()) {
                          createdAtFormatted = timeFormat.format(createdAt);
                        } else {
                          createdAtFormatted = dayFormat.format(createdAt);
                        }

                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  categoryName,
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                              Text(
                                createdAtFormatted,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveCategoryBottomSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
