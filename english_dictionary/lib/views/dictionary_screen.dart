import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../resources/widgets/meaning_view_widget.dart';
import '../resources/themes.dart';
import '../models/word_model.dart';
import '../resources/strings.dart';
import '../resources/utils/dismiss_keyboard.dart';
import '../databases/dictionary_database.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {

  final DictionaryDatabase db = DictionaryDatabase();
  TextEditingController? searchController;

  Future<List<WordModel>>? searchResultsFuture;
  WordModel? wordModel;
  String? wordSearch;
  String meaning = "";
  int hintWordsLength = 0;

  //Flutter TTS (Text To Speed)
  FlutterTts? flutterTts;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController = TextEditingController();
    initFlutterTTS();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _searchWordItemAppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Container(
                child: Column(
                  children: [
                    _showMeaning()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar _searchWordItemAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            if(searchController!.text.isNotEmpty)
              fetchWordSearchIconButton(searchController!.text.toLowerCase());
          },
          icon: Icon(
            Icons.search,
            color: Colors.white,
          )
        ),
        IconButton(
            onPressed: clearSearch,
            icon: Icon(
              Icons.clear,
              color: Colors.white,
            )
        )
      ],
      title: Column(
        children: [
          TextFormField(
            textAlign: TextAlign.start,
            cursorColor: Colors.white,
            cursorWidth: 3,
            controller: searchController,
            decoration: InputDecoration(
              hintText: SEARCH_HINT,
              hintStyle: TextStyle(
                color: Colors.black26,
                fontWeight: FontWeight.normal,
                fontSize: 17
              )
            ),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17
            ),
            onChanged: handleSearch,
            onFieldSubmitted: handleSearchOnSubmitted,
          )
        ],
      ),
    );
  }

  _showMeaning(){
    final textTheme = Theme.of(context).textTheme.apply();
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              wordModel != null ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow> [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.4),
                      offset: Offset(1.1, 1.1),
                      blurRadius: 8
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          wordSearch!,
                          style: textTheme.titleLarge
                        ),
                      )
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: wordSearch != "" ? IconButton(
                          onPressed: () async {
                            if(wordSearch != null)
                              if(wordSearch!.isNotEmpty)
                                await flutterTts!.speak(wordSearch!);
                          },
                          icon: Icon(
                            Icons.volume_up_outlined,
                            size: 30,
                            color: Colors.blue,
                          )
                        ) : Container()
                      ),
                    )
                  ],
                ),
              ) : Container(),
              wordModel != null ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow> [
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.4),
                      offset: Offset(1.1, 1.1),
                      blurRadius: 8
                    )
                  ]
                ),
                child: formatResultWidget(wordModel!.meaning!, wordSearch!),
              ) : Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.grey.withOpacity(0.4),
                      offset: Offset(1.1, 1.1),
                      blurRadius: 8),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      SEARCH_GUIDE,
                      textAlign: TextAlign.center,
                      style: textTheme.titleSmall,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        meaning,
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        searchResultsFuture != null ? Container(
          height: hintWordsLength * 50,
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
          color: Colors.blue.withOpacity(0.82),
          child: showListWordSearch()
        ) : Container()
      ]
    );
  }

  fetchWordSearchIconButton(String wordString) async {
    DismissKeyboard().off(context);
    wordModel = await db.fetchWordByWord(wordString);

    String word = "";
    if(wordModel == null)
      word = WORD_NOT_AVAILABLE;
    else {
      searchController!.clear();
      word = wordModel!.meaning!;
    }
    setState(() {
      wordSearch = wordString;
      meaning = word;
      searchResultsFuture = null;
      hintWordsLength = 0;
    });
  }

  handleSearch(String searchWord) async {
    Future<List<WordModel>> words = db.searchEnglishResults(searchWord.toLowerCase()) ;
    List<WordModel> list = await words;

    setState(()  {
      if(list.length > 0) {
        searchResultsFuture = words;
        hintWordsLength = list.length;
      }
      else {
        searchResultsFuture = null;
        hintWordsLength = 0;
      }
      if(searchController!.text.isEmpty) {
        searchResultsFuture = null;
        hintWordsLength = 0;
      }
    });
  }

  handleSearchOnSubmitted(String searchWord) async {
    DismissKeyboard().off(context);
    if(searchWord.isNotEmpty){
      wordModel = await db.fetchWordByWord(searchWord.toLowerCase());

      String word = "";
      if(wordModel == null)
        word = WORD_NOT_AVAILABLE;
      else {
        searchController!.clear();
        word = wordModel!.meaning!;
      }
      setState(()  {
        wordSearch = searchWord.toLowerCase();
        meaning = word;
        searchResultsFuture = null;
        hintWordsLength = 0;
      });
    }
  }

  showListWordSearch () {
    return FutureBuilder<List<WordModel>>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          return Container();
        List<WordModel> listWordFounded = [];
        snapshot.data!.forEach((elementWord) {
          listWordFounded.add(elementWord);
        });
        return ListView.builder(
          itemCount: listWordFounded.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Container(
                height: 50,
                padding: EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    listWordFounded[index].word!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                        color: AppTheme.white
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    color: AppTheme.white
                  )
                ),
              ),
              onTap: () {
                DismissKeyboard().off(context);
                searchController!.clear();
                setState(() {
                  wordModel = listWordFounded[index];
                  wordSearch = listWordFounded[index].word!;
                  meaning = listWordFounded[index].meaning!;
                  searchResultsFuture = null;
                });
              },
            );
          },
        );
      }
    );
  }

  clearSearch() {
    searchController!.clear();
    setState(() {
      searchResultsFuture = null;
      hintWordsLength = 0;
    });
    DismissKeyboard().off(context);
  }

  initFlutterTTS() async {
    flutterTts = FlutterTts();
    await flutterTts!.setVolume(volume);
    await flutterTts!.setPitch(pitch);
    await flutterTts!.setSpeechRate(rate);
    await flutterTts!.setLanguage("en-US");
  }
}