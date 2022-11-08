import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final textFieldBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(
      color: Colors.red,
      width: 2.0,
    ),
  );

  late ScaffoldMessengerState sm;
  var rng = Random();
  int areaCode = 0, length = 1, first = 0, count = 0;

  onChange(type, value) {
    try {
      var newValue = int.parse(value);
      switch (type) {
        case 1:
          areaCode = newValue;
          break;
        case 2:
          first = newValue;
          break;
        case 3:
          length = newValue;
          break;
        case 4:
          count = newValue;
          break;
      }
    } on FormatException {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('只能输入数字!')));
    }
  }

  save() async {
    if (areaCode == 0 || count == 0 || length == 0) {
      EasyLoading.showError("没有参数，无效保存，请输入参数！");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('areaCode', areaCode);
    await prefs.setInt('count', count);
    await prefs.setInt('length', length);
    await prefs.setInt('first', first);
  }

  submit() async {
    if (areaCode == 0 || count == 0 || length == 0) {
      EasyLoading.showError("请输入参数！");
      return;
    }

    var contactStatus = await Permission.contacts.request();
    if (contactStatus != PermissionStatus.granted) {
      EasyLoading.showError("没有通讯录权限，请手动授权！");
      return;
    }

    EasyLoading.showProgress(0,
        status: '正在导入...', maskType: EasyLoadingMaskType.black);
    for (var i = 0; i < count; i++) {
      EasyLoading.showProgress(i / count, status: '正在导入...');
      var number = "+$areaCode$first";
      for (var i = 0; i < length - 1; i++) {
        number += rng.nextInt(9).toString();
      }

      final newContact = Contact()
        ..name.first = i.toString()
        ..name.last = '-$i'
        ..phones = [Phone(number)];
      await newContact.insert();
    }
    EasyLoading.dismiss();
  }

  final TextEditingController _areaCodeController = TextEditingController();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      // areaCode = prefs.getInt('areaCode') ?? 0;
      _areaCodeController.text = (prefs.getInt('areaCode') ?? '').toString();
      _firstController.text = (prefs.getInt('first') ?? '').toString();
      _lengthController.text = (prefs.getInt('length') ?? '').toString();
      _countController.text = (prefs.getInt('count') ?? '').toString();

      areaCode = prefs.getInt('areaCode') ?? 0;
      first = prefs.getInt('first') ?? 0;
      length = prefs.getInt('length') ?? 0;
      count = prefs.getInt('count') ?? 0;


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _areaCodeController,
              keyboardType: TextInputType.number,
              onChanged: (value) => onChange(1, value),
              decoration: InputDecoration(
                labelText: "区号（不需要添加+）",
                border: textFieldBorder,
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: TextField(
                controller: _firstController,
                keyboardType: TextInputType.number,
                onChanged: (value) => onChange(2, value),
                decoration: InputDecoration(
                  labelText: "首位号码",
                  border: textFieldBorder,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: TextField(
                controller: _lengthController,
                keyboardType: TextInputType.number,
                onChanged: (value) => onChange(3, value),
                decoration: InputDecoration(
                  labelText: "号码位数",
                  border: textFieldBorder,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                onChanged: (value) => onChange(4, value),
                decoration: InputDecoration(
                  labelText: "生成个数",
                  border: textFieldBorder,
                ),
              ),
            ),
            Center(
              child: MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("保存"),
                onPressed: save,
              ),
            ),
            Center(
              child: MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("提交"),
                onPressed: submit,
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
