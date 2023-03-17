import 'package:class_tracker/app_const.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';

import 'db_helper.dart';

void main() {
  runApp(const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'CLASS TRACKER',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All books
  List<Map<String, dynamic>> _books = [];

  List<String> subjects = AppConst.subjects;
  List<String> feesTypes = AppConst.feesTypes;
  List<String> statusList = AppConst.statusList;
  String dropdownValue = 'English';
  String dropdownFeesTypeValue = 'PREPAID';
  String status = 'CURRENT';
  String searchString = '';
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _classDateController = TextEditingController();
  final TextEditingController _classStartTimeController = TextEditingController();
  final TextEditingController _classEndTimeController = TextEditingController();


  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshBooks() async {
    List<Map<String, dynamic>> data;
    if (status == 'ALL') {
      data = await SQLHelper.getItems();
    } else {
      data = await SQLHelper.getItemsByStatus(status);
    }

    setState(() {
      _books = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword, String status) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      _refreshBooks();
      results = _books;
    } else if (status.isNotEmpty && status.isNotEmpty) {
      results = _books
          .where((book) =>
      (book["subject"].toLowerCase().contains(enteredKeyword.toLowerCase())
          || book["teacher"].toLowerCase().contains(enteredKeyword.toLowerCase()))
      && book["status"].toLowerCase().contains(status.toLowerCase())
      )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    } else {
      results = _books
          .where((book) =>
      book["subject"].toLowerCase().contains(enteredKeyword.toLowerCase())
          || book["teacher"].toLowerCase().contains(enteredKeyword.toLowerCase())
      )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState(() {
      _books = results;
    });

  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingBook =
      _books.firstWhere((element) => element['id'] == id);
      dropdownValue = existingBook['subject'];
      _teacherController.text = existingBook['teacher'];
      _classDateController.text = existingBook['classDate'];
      _classStartTimeController.text = existingBook['clasStart'];
      _classEndTimeController.text = existingBook['classEnd'];
      dropdownFeesTypeValue = existingBook['feesType'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(
                child: SearchChoices.single(
                  items: subjects.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  value: dropdownValue,
                  hint: "Select subject",
                  searchHint: "Select subject",
                  onChanged: (value) {
                    setState(() {
                      dropdownValue = value;
                    });
                  },
                  isExpanded: true,
                ),
              ),
              TextField(
                controller: _teacherController,
                decoration: const InputDecoration(hintText: 'Teacher'),
              ),
              Center(
                child: DropdownButtonFormField<String>(
                  value: dropdownFeesTypeValue,
                  items: feesTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownFeesTypeValue = newValue ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _classDateController, //editing controller of this TextField
                decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Class Date" //label text of field
                ),
                readOnly: true,  //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context, initialDate: DateTime.now(),
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101)
                  );

                  if(pickedDate != null ){
                    //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    //formatted date output using intl package =>  2021-03-16
                    //you can implement different kind of Date Format here according to your requirement

                    setState(() {
                      _classDateController.text = formattedDate; //set output date to TextField value.
                    });
                  }else{
                    print("Date is not selected");
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _classStartTimeController, //editing controller of this TextField
                decoration: const InputDecoration(
                    icon: Icon(Icons.timer), //icon of text field
                    labelText: "Start Time" //label text of field
                ),
                readOnly: true,  //set it true, so that user will not able to edit text
                onTap: () async {
                  TimeOfDay? pickedTime =  await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if(pickedTime != null ){
                    final now = DateTime.now();
                    //output 10:51 PM
                    DateTime parsedTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                    //converting to DateTime so that we can further format on different pattern.
                    //output 1970-01-01 22:53:00.000
                    String formattedTime = DateFormat('HH:mm').format(parsedTime);
                    //output 14:59:00
                    //DateFormat() is from intl package, you can format the time on any pattern you need.

                    setState(() {
                      _classStartTimeController.text = formattedTime; //set the value of text field.
                    });
                  }else{
                    print("Time is not selected");
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _classEndTimeController, //editing controller of this TextField
                decoration: const InputDecoration(
                    icon: Icon(Icons.timer), //icon of text field
                    labelText: "End Time" //label text of field
                ),
                readOnly: true,  //set it true, so that user will not able to edit text
                onTap: () async {
                  TimeOfDay? pickedTime =  await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if(pickedTime != null ){
                    final now = DateTime.now();
                    //output 10:51 PM
                    DateTime parsedTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
                    //converting to DateTime so that we can further format on different pattern.
                    //output 1970-01-01 22:53:00.000
                    String formattedTime = DateFormat('HH:mm').format(parsedTime);
                    //output 14:59:00
                    //DateFormat() is from intl package, you can format the time on any pattern you need.

                    setState(() {
                      _classEndTimeController.text = formattedTime; //set the value of text field.
                    });
                  }else{
                    print("Time is not selected");
                  }
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  // Save new book
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }

                  // Clear the text fields
                  _teacherController.text = '';
                  _classDateController.text = '';
                  _classStartTimeController.text = '';
                  _classEndTimeController.text = '';
                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'ADD CLASS' : 'UPDATE'),
              )
            ],
          ),
        ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        dropdownValue,_teacherController.text, dropdownFeesTypeValue, _classDateController.text, _classStartTimeController.text, _classEndTimeController.text);
    _refreshBooks();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, dropdownValue,_teacherController.text, dropdownFeesTypeValue, _classDateController.text, _classStartTimeController.text, _classEndTimeController.text);
    _refreshBooks();
  }

  // Delete an item
  void _deleteItem(int id) async {
    //await SQLHelper.deleteItem(id);
    await SQLHelper.updateItemStatus(id, 'PAST');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Item!'),
    ));
    _refreshBooks();
  }

  // Delete an item
  void _deleteItemPermanent(int id) async {
    //await SQLHelper.deleteItem(id);
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Item!'),
    ));
    _refreshBooks();
  }

  // Delete an item
  void _deleteItems(List<int> ids) async {
    await SQLHelper.updateItemsStatus(ids, 'PAST');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted Items!'),
    ));
    _refreshBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASS TRACKER'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: TextField(
                      onChanged: (value) => {
                        setState(() {
                          searchString = value ?? '';
                        }),
                        _runFilter(value, status)
                      },
                      decoration: const InputDecoration(
                          labelText: 'Search', suffixIcon: Icon(Icons.search)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: status,
                      items: statusList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          status = newValue ?? '';
                        });
                        _runFilter(searchString, status);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            Expanded(
              child:_isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : GroupedListView<dynamic, String>(
                elements: _books,
                groupBy: (element) => element['subject'],
                groupComparator: (value1,
                    value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item1['subject'].compareTo(item2['subject']),
                order: GroupedListOrder.DESC,
                //useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                  Row(
                    children: [
                      showNotification(value)
                          ?
                      const Tooltip(
                        message: 'Get Ready for class fees',
                        child: Icon(
                          Icons.access_alarm,
                          color: Colors.red,
                        ),
                      ) :
                      const Text(''),
                      showNotification(value)
                          ?
                      IconButton(
                        icon: const Icon(Icons.paid_outlined),
                        onPressed: () async {
                          if (await confirm(context,
                            title: const Text('Confirm'),
                            content: Text('Would you like to pay for $value classes ?'),
                            textOK: const Text('Yes'),
                            textCancel: const Text('No'),
                          )) {
                            return _deleteItems(deletingList(value));
                          }
                        },
                      ) : const Text(''),
                    ],
                  ),

                    ],
                  ),
                ),
                itemBuilder: (c, element) {
                  bool showNotificationInd = showNotification(element['subject']);
                  return Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0,
                        vertical: 6.0),
                    child: Container(
                      child: ListTile(
                        tileColor: element['status'] == 'CURRENT' ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0,
                            vertical: 10.0),
                        //leading: Icon(Icons.account_circle),
                        title: Text(
                          element['classDate'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              element['status'] == 'CURRENT' ? IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showForm(element['id']),
                              ) : Container(),
                              element['status'] == 'CURRENT' ? IconButton(
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
                              ) :
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  if (await confirm(context,
                                    title: const Text('Confirm'),
                                    content: const Text('Would you like to remove?'),
                                    textOK: const Text('Yes'),
                                    textCancel: const Text('No'),
                                  )) {
                                    return _deleteItemPermanent(element['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            ],
          )
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }

  bool showNotification(String subject) {
    List<Map<String, dynamic>> resultsPostPaid = _books
        .where((book) =>
        book["feesType"]== 'POSTPAID' && book["subject"]== subject && book["status"] == 'CURRENT')
        .toList();
    List<Map<String, dynamic>> resultsPrePaid = _books
        .where((book) =>
    book["feesType"]== 'PREPAID' && book["subject"]== subject && book["status"] == 'CURRENT')
        .toList();
    List<Map<String, dynamic>> resultsDaily = _books
        .where((book) =>
    book["feesType"]== 'DAILY' && book["subject"]== subject && book["status"] == 'CURRENT')
        .toList();
    if (resultsPrePaid.length > 3 || resultsPostPaid.length > 2 || resultsDaily.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  List<int> deletingList(String subject) {
    List<Map<String, dynamic>> results = _books
        .where((book) =>
    book["subject"]== subject)
        .toList();
    List<int> ids = results.fold<List<int>>(
        [], (prev, element) => List.from(prev)..add(element['id']));
    return ids;
  }
}
