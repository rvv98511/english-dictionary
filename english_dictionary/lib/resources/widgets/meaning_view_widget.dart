import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import '../themes.dart';

formatResultWidget(String result,  String searchKey)
{
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: toViewFormatWidget(splitResult(result, searchKey), searchKey)

  );
  //return toViewFormatWidget(splitResult(result), searchKey) ;
  //return toViewFormatHtml(splitResult(result), searchKey);
}


List<Widget> toViewFormatWidget(List<String> strings, String searchKey)
{

  List<Widget> list = [];
  for(String string in strings) {
    if(string.length > 0) {
      switch(string[0]) {

        case '@':
          if(searchKey == (string.substring(1).trim())) {
            list.add(Text(searchKey + "\n" ,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontName,
              ),
              textAlign: TextAlign.left,));


          } else {
            list.add(Text("\n"+string.substring(1) ,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontName,
              ),
              textAlign: TextAlign.left,));
          }
          break;

        case '-':
          list.add(Text(string ,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
            ),
            textAlign: TextAlign.left,));
          break;
        case '/':
          if (string.length > 1) {

            list.add(Text( string + "/" + "\n",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontStyle: FontStyle.italic
              ),));

          }
          break;
        case '*':
          list.add(Text(string.substring(2),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: Color(0xffb71c1c)
            ),));

          break;
        case '^':
          list.add(Text(  string.substring(1),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.bold,
                color: Color(0xff3f51b5)
            ),));

          break;
        case '=':

          if (isAlpha(string[1])) {
            list.add(Text( string.substring(1),
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  color: Color(0xff607d8b),
                  fontStyle: FontStyle.italic
              ),));

          } else {
            list.add (Text( string,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
              ),
              textAlign: TextAlign.left,),
            );
          }
          break;
        case '+':
          list.add (Text( "->" + string.substring(1),
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color(0xff607d8b),
                fontFamily: AppTheme.fontName,
                fontStyle: FontStyle.italic
            ),));

          break;
        default:
          list.add (Text(string,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
            ),
            textAlign: TextAlign.left,));
          break;
      }
    }
  }
  return list;

}

/// Convert all orignalWord to another
convertSplitCharacter({@required String? originalWord,
  @required String? stringNeedCheck,
  @required String? splitCharacter,
  @required String? replacedSplitCharacter})
{
  String tempString = stringNeedCheck!;
  String tempStringItem = originalWord!.replaceAll(splitCharacter!, replacedSplitCharacter!);
  tempString = tempString.replaceAll(originalWord, tempStringItem);

  return tempString;
}

// Convert all orignalWord to another
revertSplitCharacter({@required String? originalWord,
  @required String? stringNeedCheck,
  @required String? splitCharacter,
  @required String? replacedSplitCharacter})
{
  String tempString = stringNeedCheck!;
  String tempStringItem = originalWord!.replaceAll(splitCharacter!, replacedSplitCharacter!);
  tempString = tempString.replaceAll(tempStringItem, originalWord);

  return tempString;
}


List<String> splitResult(String value, String word)
{
  // Split but hold Character : value.split(new RegExp(r'(?=\@)')); Ex: LoveYou@Sarha ==> ['LoveYou', '@Sarha']
  List<String> at = value.split(new RegExp(r'(?=\@)'));
  List<String> al = [];
  for(String tmpAt in at) {
    /// Convert Word(-) into Word(+)
    tmpAt = convertSplitCharacter(originalWord: word, stringNeedCheck: tmpAt, splitCharacter: "-", replacedSplitCharacter: "+") ;
    //print(word);
    //print(tmpAt);


    List<String> hyphen = tmpAt.split(new RegExp(r'(?=\-)'));


    for(String tmpHyphen in hyphen) {

      tmpHyphen = revertSplitCharacter(originalWord: word, stringNeedCheck: tmpHyphen, splitCharacter: "-", replacedSplitCharacter: "+") ;


      List<String> slash = tmpHyphen.split(new RegExp(r'(?=\/)'));
      for(String tmpSlash in slash) {
        List<String> equals = tmpSlash.split(new RegExp(r'(?=\=)'));
        for(String tmpEquals in equals) {
          List<String> plusSign = tmpEquals.split(new RegExp(r'(?=\+)'));
          for(String tmpPlusSign in plusSign) {
            List<String> asterisk = tmpPlusSign.split(
                new RegExp(r'(?=\*)'));

            for (String tmpAsterisk in asterisk) {
              //print(tmpAsterisk);
              int n;
              int pos = 0;
              String x = tmpAsterisk;
              while ((n = x.indexOf('!')) != -1) {
                if (tmpAsterisk.length > n + pos + 1) {
                  if ((isAlpha(tmpAsterisk[n + pos + 1])) ||
                      (tmpAsterisk[n + pos + 1] == '[')) {
                    tmpAsterisk =
                        tmpAsterisk.substring(0, n + pos) + '^' +
                            tmpAsterisk.substring(n + pos + 1);
                  }
                }
                x = x.substring(n + 1);
                pos += n + 1;
              }
              List<String> caret = tmpAsterisk.split(
                  new RegExp(r'(?=\^)'));
              // al.addAll(caret);
              for (String tmpCaret in caret) {
                //print(tmpCaret);
                al.add(tmpCaret);
              }
            }
          }
        }
      }
    }

  }
  return al;

}