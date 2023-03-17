import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import 'db_helper.dart';

class GroupListViewDemo extends StatefulWidget {
  @override
  _GroupListViewDemoState createState() => _GroupListViewDemoState();
}

class _GroupListViewDemoState extends State<GroupListViewDemo> {

  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  void _refreshBooks() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _books = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshBooks(); // Loading the books when the app starts
  }

  List _elements = [
    {'topicName': 'GridView.count', 'group': 'GridView Type'},
    {'topicName': 'GridView.builder', 'group': 'GridView Type'},
    {'topicName': 'GridView.custom', 'group': 'GridView Type'},
    {'topicName': 'GridView.extent', 'group': 'GridView Type'},
    {'topicName': 'ListView.builder', 'group': 'ListView Type'},
    {'topicName': 'StatefulWidget', 'group': 'Type of Widget'},
    {'topicName': 'ListView', 'group': 'ListView Type'},
    {'topicName': 'ListView.separated', 'group': 'ListView Type'},
    {'topicName': 'ListView.custom', 'group': 'ListView Type'},
    {'topicName': 'StatelessWidget', 'group': 'Type of Widget'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grouped ListView'),
      ),
      body: GroupedListView<dynamic, String>(
        elements: _books,
        groupBy: (element) => element['subject'],
        groupComparator: (value1,
            value2) => value2.compareTo(value1),
        itemComparator: (item1, item2) =>
            item1['subject'].compareTo(item2['subject']),
        order: GroupedListOrder.DESC,
        // useStickyGroupSeparators: true,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (c, element) {

          return Card(
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0,
                vertical: 6.0),
            child: Container(
              child: ListTile(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0,
                    vertical: 10.0),
                //leading: Icon(Icons.account_circle),
                title: Text(
                  element['classDate'],
                  style: TextStyle(fontSize: 16),
                ),
                trailing: SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          if (await confirm(context,
                            title: const Text('Confirm'),
                            content: const Text('Would you like to remove?'),
                            textOK: const Text('Yes'),
                            textCancel: const Text('No'),
                          )) {
                            return _deleteItem(element['id']);
                          }

                        },
                      ),
                      const Tooltip(
                        message: 'Class fees Today',
                        child: Icon(
                          Icons.access_alarm,
                          color: Colors.red,
                        ),
                      ) ,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Item!'),
    ));
    _refreshBooks();
  }

}
