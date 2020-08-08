import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;

  ChatMessage(this.data, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !isMe
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              data['imageUrl'] != null
                  ? Image.network(
                      data['imageUrl'],
                      width: 150,
                    )
                  : Text(
                      data['text'],
                      style: TextStyle(fontSize: 16),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
              Text(
                data['senderName'],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              )
            ],
          )),
          isMe
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['senderPhotoUrl']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
