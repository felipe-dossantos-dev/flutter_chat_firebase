import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imageFile}) sendMessage;
  final _imagePicker = ImagePicker();

  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  void _clearTextField() {
    setState(() {
      _isComposing = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final pickedFile = await widget._imagePicker
                  .getImage(source: ImageSource.camera);
              if (pickedFile == null) {
                return;
              }
              widget.sendMessage(imageFile: File(pickedFile.path));
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (value) {
                setState(() {
                  _isComposing = value.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                widget.sendMessage(text: value);
                _clearTextField();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    _clearTextField();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
