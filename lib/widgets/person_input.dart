import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/person_provider.dart';

class PersonInput extends StatefulWidget {
  @override
  _PersonInputState createState() => _PersonInputState();
}

class _PersonInputState extends State<PersonInput> {
  final _nameController = TextEditingController();

  void addPerson() {
    if (_nameController.text.trim().isEmpty) return;
    Provider.of<PersonProvider>(context, listen: false)
        .addPerson(_nameController.text);
    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: TextField(
              decoration: InputDecoration(labelText: "Add a person"),
              controller: _nameController,
            ),
          ),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.black,),
              onPressed: addPerson,
            ),
          )
        ],
      ),
    );
  }
}
