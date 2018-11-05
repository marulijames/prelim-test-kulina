import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_choice.dart';
import 'package:intl/intl.dart';

class SubscriptionPicker extends StatefulWidget {
  final DateTime now;
  final List<SubscriptionChoice> subscriptionChoices;
  SubscriptionPicker(this.now, this.subscriptionChoices);
  @override
  _SubscriptionPickerState createState() => _SubscriptionPickerState();
}

class _SubscriptionPickerState extends State<SubscriptionPicker> {
  List<String> thisMonth; //Store starting month name and year
  List<String> nextMonth; //Store next month name and year
  List<String> nextTwoMonth; //Store next two month name and year
  List<SubscriptionChoice>
      subscriptionChoices; //Store number of subscription days choices
  int pickerDisplayedMonth; //Month in int example: November(11)
  int pickerDisplayedYear;
  int todayDateDay;
  int selectedMonthIndex; //This Month(1),Next Month(2), Next 2 Months(3)

  bool maximumChoiceExcedeed = false;
  List<DateTime> curMonthSelected = []; //Selected date from starting month
  List<DateTime> nextMonthSelected = []; //Selected date from next month
  List<DateTime> nextTwoMonthSelected = []; //Selected date from next two month
  int selectedSubscriptionId = 0;
  int minimumSelectedDays = 5;
  final formatter = NumberFormat("#,###");
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> daysIndo = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

  @override
  void initState() {
    super.initState();
    thisMonth =
        formatDate(widget.now, [yyyy, '-', MM, '-', DD, '-', dd]).split('-');
    nextMonth = formatDate(DateTime(widget.now.year, widget.now.month + 1, 1),
        [yyyy, '-', MM, '-', DD]).split('-');
    nextTwoMonth = formatDate(
        DateTime(widget.now.year, widget.now.month + 2, 1),
        [yyyy, '-', MM, '-', DD]).split('-');
    pickerDisplayedYear = int.parse(thisMonth[0]);
    todayDateDay = int.parse(thisMonth[3]);
    setMonthNumber(thisMonth[1]);
    selectedMonthIndex = 1;
    subscriptionChoices = widget.subscriptionChoices;
    fillStarter(widget.now, 5);
  }

  //This method used for selecting first (numOfDays) days consequently
  //skipping saturday and sunday
  fillStarter(DateTime startDate, int numOfDays) {
    curMonthSelected = [];
    nextMonthSelected = [];
    nextTwoMonthSelected = [];
    String dayName;
    for (int i = 0; i < numOfDays; i++) {
      dayName = formatDate(startDate, [D]);
      if (dayName == 'Fri') {
        startDate =
            DateTime(startDate.year, startDate.month, startDate.day + 3);
      } else if (dayName == 'Sat') {
        startDate =
            DateTime(startDate.year, startDate.month, startDate.day + 2);
      } else
        startDate =
            DateTime(startDate.year, startDate.month, startDate.day + 1);
      if (startDate.month == getMonthNumber(thisMonth[1])) {
        curMonthSelected.add(startDate);
      } else if (startDate.month == getMonthNumber(nextMonth[1])) {
        nextMonthSelected.add(startDate);
      } else if (startDate.month == getMonthNumber(nextTwoMonth[1])) {
        nextTwoMonthSelected.add(startDate);
      }
    }
    _saveResult(getSelectedDate());
    updateSubscripionChoice();
  }

  //Check if a date already selected
  isSelected(int selectedMonthIdx, DateTime date) {
    switch (selectedMonthIdx) {
      case 1:
        for (int i = 0; i < curMonthSelected.length; i++) {
          if (curMonthSelected[i].year == date.year &&
              curMonthSelected[i].month == date.month &&
              curMonthSelected[i].day == date.day) {
            return true;
          }
        }
        return false;
        break;
      case 2:
        for (int i = 0; i < nextMonthSelected.length; i++) {
          if (nextMonthSelected[i].year == date.year &&
              nextMonthSelected[i].month == date.month &&
              nextMonthSelected[i].day == date.day) {
            return true;
          }
        }
        return false;
        break;
      case 3:
        for (int i = 0; i < nextTwoMonthSelected.length; i++) {
          if (nextTwoMonthSelected[i].year == date.year &&
              nextTwoMonthSelected[i].month == date.month &&
              nextTwoMonthSelected[i].day == date.day) {
            return true;
          }
        }
        return false;
        break;
      default:
        {
          return false; //statements;
        }
    }
  }

  //Remove date from selection
  unselectDate(int selectedMonthIdx, DateTime date) {
    switch (selectedMonthIdx) {
      case 1:
        for (int i = 0; i < curMonthSelected.length; i++) {
          if (curMonthSelected[i].year == date.year &&
              curMonthSelected[i].month == date.month &&
              curMonthSelected[i].day == date.day) {
            curMonthSelected.removeAt(i);
          }
        }
        return false;
        break;
      case 2:
        for (int i = 0; i < nextMonthSelected.length; i++) {
          if (nextMonthSelected[i].year == date.year &&
              nextMonthSelected[i].month == date.month &&
              nextMonthSelected[i].day == date.day) {
            nextMonthSelected.removeAt(i);
          }
        }
        break;
      case 3:
        for (int i = 0; i < nextTwoMonthSelected.length; i++) {
          if (nextTwoMonthSelected[i].year == date.year &&
              nextTwoMonthSelected[i].month == date.month &&
              nextTwoMonthSelected[i].day == date.day) {
            nextTwoMonthSelected.removeAt(i);
          }
        }
        break;
    }
  }

  //Add date to selection
  selectDate(int selectedMonthIdx, DateTime date) {
    switch (selectedMonthIdx) {
      case 1:
        curMonthSelected.add(date);
        break;
      case 2:
        nextMonthSelected.add(date);
        break;
      case 3:
        nextTwoMonthSelected.add(date);
        break;
    }
  }

  //Update subscription choice box according to latest
  //number of selected dates
  updateSubscripionChoice() {
    int selected = getSelectedDate().length;
    if (selected <= subscriptionChoices[0].numberOfDays) {
      selectedSubscriptionId = 1;
      maximumChoiceExcedeed = false;
    } else if (selected <= subscriptionChoices[1].numberOfDays) {
      selectedSubscriptionId = 2;
      maximumChoiceExcedeed = false;
    } else if (selected <= subscriptionChoices[2].numberOfDays) {
      selectedSubscriptionId = 3;
      maximumChoiceExcedeed = false;
    } else {
      selectedSubscriptionId = 0;
      maximumChoiceExcedeed = true;
    }
  }

  setMonthNumber(String month) {
    for (int i = 0; i < months.length; i++) {
      if (months[i] == month) {
        setState(() {
          pickerDisplayedMonth = i + 1;
        });
      }
    }
  }

  getMonthNumber(String month) {
    for (int i = 0; i < months.length; i++) {
      if (months[i] == month) {
        return i + 1;
      }
    }
  }

  getDayNumber(String day) {
    for (int i = 0; i < days.length; i++) {
      if (days[i] == day) {
        return i;
      }
    }
  }

  getSelectedDate() {
    var selectedDate = [
      curMonthSelected,
      nextMonthSelected,
      nextTwoMonthSelected
    ].expand((x) => x).toList();
    selectedDate.sort();
    return selectedDate;
  }

  //Saving selected dates info, so can be acessed from subscription_page class
  _saveResult(List<DateTime> selectedDate) async {
    String startDate = '';
    if (selectedDate.isNotEmpty) {
      startDate = formatDate(selectedDate[0], [d, ' ', MM, ' ', yyyy]);
    }
    int price;
    if(maximumChoiceExcedeed){
      price = subscriptionChoices[2].price;
    } else price = subscriptionChoices[selectedSubscriptionId - 1].price;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected', selectedDate.length);
    await prefs.setInt('price', price);
    await prefs.setString('start_date', startDate);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    //Making view for boxes in the datepicker
    dateBox(bool selected, bool selectable, DateTime current, String dayNumber,
        int curMonth) {
      Color textColor;
      if (!selectable) {
        textColor = Color(0xFFDADEDF);
      } else if (!selected) {
        textColor = Theme.of(context).textSelectionColor;
      } else {
        textColor = Colors.white;
      }
      return Container(
          margin: EdgeInsets.only(left:screenWidth / 150,bottom:screenWidth / 150),
          child: InkWell(
              onTap: () {
                setState(() {
                  if (!selected && selectable) {
                    selectDate(curMonth, current);
                    updateSubscripionChoice();
                    _saveResult(getSelectedDate());
                  } else {
                    if (getSelectedDate().length > minimumSelectedDays)
                      unselectDate(curMonth, current);
                    updateSubscripionChoice();
                    _saveResult(getSelectedDate());
                  }
                });
              },
              child: Container(
                  alignment: Alignment.center,
                  width: screenWidth / 8.85,
                  height: screenWidth / 8.85,
                  decoration: new BoxDecoration(
                    color: selected
                        ? Theme.of(context).buttonColor
                        : Color(0xFFF0F1F2),
                  ),
                  child: Text(
                    dayNumber,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ))));
    }

    //Making view for datepicker
    makeDayPicker() {
      var firstDayOfCurMonth =
          DateTime(pickerDisplayedYear, pickerDisplayedMonth, 1);
      var firstDayOfNextMonth =
          DateTime(pickerDisplayedYear, pickerDisplayedMonth + 1, 1);
      var lastDayOfCurMonth = DateTime(firstDayOfNextMonth.year,
          firstDayOfNextMonth.month, firstDayOfNextMonth.day - 1);
      var lastDayOfPrevMonth = DateTime(firstDayOfCurMonth.year,
          firstDayOfCurMonth.month, firstDayOfCurMonth.day - 1);
      String firstDayName = formatDate(firstDayOfCurMonth, [DD]);
      int distanceToMonday = getDayNumber(firstDayName);

      var calendarStart = new DateTime(firstDayOfCurMonth.year,
          firstDayOfCurMonth.month, firstDayOfCurMonth.day - distanceToMonday);
      int calendarStartDay = int.parse(formatDate(calendarStart, [dd]));
      int prevMonthLastDay = int.parse(formatDate(lastDayOfPrevMonth, [dd]));
      int curMonthLastDay = int.parse(formatDate(lastDayOfCurMonth, [dd]));
      bool lastWeek = false;
      int curDay = calendarStartDay;
      int curWeek = 1;
      int curMonth = selectedMonthIndex;
      if (calendarStartDay != 1) {
        curMonth--;
      }

      List<Widget> allWeeks = [];
      List<Widget> week;
      int selectedDateYear;
      int selectedDateMonth;
      while (!lastWeek) {
        week = [];
        for (int i = 0; i < 7; i++) {
          selectedDateYear = pickerDisplayedYear;
          selectedDateMonth = pickerDisplayedMonth;

          if (calendarStartDay != 1 && curWeek == 1 && curDay > 24) {
            if (pickerDisplayedMonth == 1) {
              selectedDateMonth = 12;
              selectedDateYear--;
            } else
              selectedDateMonth--;
          }

          DateTime current =
              DateTime(selectedDateYear, selectedDateMonth, curDay);
          var selectable = i > 4 ||
                  curMonth == 0 ||
                  curMonth == 4 ||
                  (curMonth == 1 && curDay < todayDateDay + 1)
              ? false
              : true;
          var selected = selectable ? isSelected(curMonth, current) : false;

          week.add(dateBox(
              selected, selectable, current, curDay.toString(), curMonth));
          if (curWeek == 1 && curDay == prevMonthLastDay) {
            curDay = 1;
            curMonth++;
          } else if (curWeek != 1 && curDay == curMonthLastDay) {
            lastWeek = true;
            curDay = 1;
            curMonth++;
          } else {
            curDay++;
          }
        }
        allWeeks.add(Row(children: week));
        curWeek++;
      }

      return Column(children: allWeeks);
    }

    //Change displayed month to next month
    toNextMonth() {
      if (selectedMonthIndex == 1) {
        pickerDisplayedYear = int.parse(nextMonth[0]);
        setMonthNumber(nextMonth[1]);
        selectedMonthIndex = 2;
      } else if (selectedMonthIndex == 2) {
        pickerDisplayedYear = int.parse(nextTwoMonth[0]);
        setMonthNumber(nextTwoMonth[1]);
        selectedMonthIndex = 3;
      }
    }

    //Change displayed month to next two month
    toPrevMonth() {
      if (selectedMonthIndex == 2) {
        pickerDisplayedYear = int.parse(thisMonth[0]);
        setMonthNumber(thisMonth[1]);
        selectedMonthIndex = 1;
      } else if (selectedMonthIndex == 3) {
        pickerDisplayedYear = int.parse(nextMonth[0]);
        setMonthNumber(nextMonth[1]);
        selectedMonthIndex = 2;
      }
    }

    //View component for the month name on datepicker
    final monthSection = Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Row(children: <Widget>[
          InkWell(
            child: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: selectedMonthIndex > 1
                    ? Icon(
                        Icons.arrow_left,
                        color: Colors.black54,
                      )
                    : Container()),
            onTap: selectedMonthIndex > 1 ? toPrevMonth : null,
          ),
          Expanded(child: Container()),
          Text(
              months[pickerDisplayedMonth - 1] +
                  ' ' +
                  pickerDisplayedYear.toString(),
              style: TextStyle(color: Colors.black54, fontSize: 20.0)),
          Expanded(child: Container()),
          InkWell(
              child: Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: selectedMonthIndex < 3
                      ? Icon(
                          Icons.arrow_right,
                          color: Colors.black54,
                        )
                      : Container()),
              onTap: selectedMonthIndex < 3 ? toNextMonth : null),
        ]));

    //View component for the dateboxes and
    //Day name (SEN SEL RABU ....)
    makeDaysInfo() {
      List<Widget> daysInfo = [];
      for (int i = 0; i < daysIndo.length; i++) {
        daysInfo.add(Container(
            margin: EdgeInsets.only(left:screenWidth / 150,bottom:screenWidth / 150),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 8.85,
            height: MediaQuery.of(context).size.width / 35,
            child: Container(
                child: Text(
              daysIndo[i],
              style: TextStyle(color: Colors.black54, fontSize: 14.0),
            ))));
      }
      makeDayPicker();
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: Row(children: daysInfo));
    }

    //Method that will give the subscription choice box component
    Widget choiceBox(SubscriptionChoice box) {
      return InkWell(
          onTap: () {
            setState(() {
              this.selectedSubscriptionId = box.id;
            });
            fillStarter(widget.now, box.numberOfDays);
          },
          child: Container(
              width: screenWidth * 3.7 / 9,
              height: 70.0,
              decoration: box.id != selectedSubscriptionId
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(3.5),
                      border: Border.all(
                          width: 1.5, color: Theme.of(context).buttonColor))
                  : BoxDecoration(
                      color: Theme.of(context).buttonColor,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Text(
                      box.numberOfDays.toString() + ' Hari',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0,
                          color: box.id != selectedSubscriptionId
                              ? Theme.of(context).textSelectionColor
                              : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6.0),
                    Text(
                      'Rp ' + formatter.format(box.price) + '/hari',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: box.id != selectedSubscriptionId
                              ? Theme.of(context).textSelectionColor
                              : Colors.white),
                    ),
                  ]))));
    }

    //Alternate box if days is more than the biggest subscription choices
    final alternateBox = Container(
        width: screenWidth * 3.7 / 9,
        height: 70.0,
        decoration: !maximumChoiceExcedeed
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(3.5),
                border: Border.all(
                    width: 1.5, color: Theme.of(context).buttonColor))
            : BoxDecoration(
                color: Theme.of(context).buttonColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
        child: Center(
            child: !maximumChoiceExcedeed
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                          'Pilih Hari',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Theme.of(context).textSelectionColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          'Min. 5 Hari',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Theme.of(context).textSelectionColor),
                        ),
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                          getSelectedDate().length.toString() + ' Hari',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          'Rp ' +
                              formatter.format(subscriptionChoices[2].price) +
                              '/hari',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ])));
    //Subscription boxes positioned as a grid here
    final subscriptionChoicesSection = Container(
        height: 175.0,
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  choiceBox(this.subscriptionChoices[0]),
                  Expanded(child: Container()),
                  choiceBox(this.subscriptionChoices[1])
                ])),
            Expanded(child: Container()),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  choiceBox(this.subscriptionChoices[2]),
                  Expanded(child: Container()),
                  alternateBox
                ])),
          ],
        ));

    return Column(children: [
      subscriptionChoicesSection,
      Container(
          padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 16.0),
          child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Color(0xFFDCDFE1),
                  blurRadius: 15.0,
                ),
              ]),
              child: Card(
                  color: Color(0xFFFFFFFF),
                  child: Column(
                    children: <Widget>[
                      monthSection,
                      makeDaysInfo(),
                      makeDayPicker()
                    ],
                  ))))
    ]);
  }
}
