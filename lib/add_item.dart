import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';

final formatter = DateFormat.yMd();

class AddItem extends StatefulWidget {
  const AddItem({super.key, required this.onAddExpense});
  final void Function(Expense expense) onAddExpense;
  @override
  State<StatefulWidget> createState() {
    return _AddItem();
  }
}

class _AddItem extends State<AddItem> {
  final _enteredTitle = TextEditingController();
  final _enteredAmount = TextEditingController();
  DateTime? _enteredDate;
  Cat _enteredCategory = Cat.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = now;
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    setState(() {
      _enteredDate = pickedDate;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text("Invalid Input"),
                content: const Text(
                    "Please make sure your entries are valid or non-empty!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text("Ok"))
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Invalid Input"),
                content: const Text(
                    "Please make sure your entries are valid or non-empty!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text("Ok"))
                ],
              ));
    }
  }

  void _submitData() {
    final enteredAmount = double.tryParse(_enteredAmount.text);
    final amountIsInvalid =
        (enteredAmount == null || enteredAmount < 0) ? true : false;
    if (_enteredTitle.text.trim().isEmpty ||
        amountIsInvalid ||
        _enteredDate == null) {
      _showDialog();
      return;
    } else {
      widget.onAddExpense(Expense(
          title: _enteredTitle.text,
          amount: enteredAmount,
          date: _enteredDate!,
          category: _enteredCategory));

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _enteredTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, keyboardSpace + 16),
            child: Column(
              children: [
                if (width >= 600)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _enteredTitle,
                          maxLength: 50,
                          decoration:
                              const InputDecoration(label: Text("Title")),
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _enteredAmount,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              prefixText: "\$", label: Text("Amount")),
                        ),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: _enteredTitle,
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text("Title")),
                  ),
                if (width >= 600)
                  Row(
                    children: [
                      DropdownButton(
                          value: _enteredCategory,
                          items: Cat.values.map((category) {
                            return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()));
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            } else {
                              setState(() {
                                _enteredCategory = value;
                              });
                            }
                          }),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text((_enteredDate == null)
                              ? "No Date"
                              : formatter.format(_enteredDate!)),
                          IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month))
                        ],
                      )),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _enteredAmount,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              prefixText: "\$", label: Text("Amount")),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text((_enteredDate == null)
                              ? "No Date"
                              : formatter.format(_enteredDate!)),
                          IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month))
                        ],
                      )),
                    ],
                  ),
                const SizedBox(
                  width: 15,
                ),
                Row(
                  children: [
                    if (width <= 600)
                      DropdownButton(
                          value: _enteredCategory,
                          items: Cat.values.map((category) {
                            return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase()));
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            } else {
                              setState(() {
                                _enteredCategory = value;
                              });
                            }
                          }),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                        onPressed: _submitData,
                        child: const Text("Save Expense")),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
