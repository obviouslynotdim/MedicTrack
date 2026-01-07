import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:finalproject/ui/screens/schedule/add_schedule_screen.dart';
import 'package:finalproject/models/medicine_model.dart';

void main() {
  // Required to prevent crashes if your screen uses DateFormat
  setUpAll(() async {
    await initializeDateFormatting('en_US', null);
  });

  testWidgets('AddScheduleScreen form test', (WidgetTester tester) async {
    Medicine? result;

    // 1. Load the widget environment
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: const Text('Open Sheet'),
              onPressed: () async {
                result = await showModalBottomSheet<Medicine>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddScheduleScreen(),
                );
              },
            ),
          ),
        ),
      ),
    );

    // 2. Open the BottomSheet
    await tester.tap(find.text('Open Sheet'));

    // IMPORTANT: Wait for the slide-up animation to finish
    // This prevents the "No element" error
    await tester.pumpAndSettle();

    // 3. Fill the form using Keys
    final nameFinder = find.byKey(const Key('name_field'));
    final amountFinder = find.byKey(const Key('amount_field'));
    final remarksFinder = find.byKey(const Key('remarks_field'));

    // Ensure the fields are visible before typing
    await tester.ensureVisible(nameFinder);
    await tester.enterText(nameFinder, 'Test Pill');

    await tester.ensureVisible(amountFinder);
    await tester.enterText(amountFinder, '1');

    await tester.ensureVisible(remarksFinder);
    await tester.enterText(remarksFinder, 'No comments');

    // 4. Toggle the Remind Me switch
    final remindSwitch = find.byType(SwitchListTile);
    await tester.tap(remindSwitch);
    await tester.pumpAndSettle();

    // 5. Save the schedule
    // Make sure 'Save Schedule' matches the text on your button EXACTLY
    final saveButton = find.text('Save Schedule');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    // 6. Wait for the BottomSheet to close
    await tester.pumpAndSettle();

    // 7. Final Assertions
    expect(
      result,
      isNotNull,
      reason: "The result should not be null after saving",
    );
    expect(result!.name, 'Test Pill');
    expect(result!.amount, '1');
    expect(result!.comments, 'No comments');
  });
}
