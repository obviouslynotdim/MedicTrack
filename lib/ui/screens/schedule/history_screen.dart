import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medicine_model.dart';
import '../../../models/history_entry.dart';

class HistoryScreen extends StatefulWidget {
  final List<HistoryEntry> history;            // shared, real history
  final List<Medicine> medicines;
  final Function(String) onDeleteHistory;      // callback to update shared list

  const HistoryScreen({
    super.key,
    required this.history,
    required this.medicines,
    required this.onDeleteHistory,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<HistoryEntry> _visibleHistory;

  @override
  void initState() {
    super.initState();
    _visibleHistory = _sorted(widget.history);
  }

  // If parent updates history while this screen is alive, keep in sync
  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history != widget.history) {
      _visibleHistory = _sorted(widget.history);
    }
  }

  List<HistoryEntry> _sorted(List<HistoryEntry> list) {
    final copy = [...list];
    copy.sort((a, b) => b.takenTime.compareTo(a.takenTime));
    return copy;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm delete"),
        content: const Text("Are you sure you want to delete this entry?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _removeEntry(String id) {
    setState(() {
      _visibleHistory.removeWhere((e) => e.id == id);
    });
    widget.onDeleteHistory(id); // propagate deletion to shared source of truth
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine History")),
      body: _visibleHistory.isEmpty
          ? const Center(
              child: Text("No history yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visibleHistory.length,
              itemBuilder: (context, index) {
                final entry = _visibleHistory[index];
                final med = widget.medicines.firstWhere(
                  (m) => m.id == entry.medicineId,
                  orElse: () => Medicine(
                    id: '0',
                    name: 'Unknown',
                    iconIndex: 0,
                    amount: '',
                    type: '',
                    dateTime: entry.takenTime,
                    isRemind: false,
                    status: MedicineStatus.pending,
                    comments: null,
                    schedule: null,
                  ),
                );

                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) => _removeEntry(entry.id),
                  child: HistoryCard(entry: entry, medicine: med),
                );
              },
            ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final Medicine medicine;

  const HistoryCard({super.key, required this.entry, required this.medicine});

  Color _statusColor(MedicineStatus status) {
    switch (status) {
      case MedicineStatus.taken:
        return Colors.teal;
      case MedicineStatus.missed:
        return Colors.red;
      case MedicineStatus.pending:
        return Colors.orange;
    }
  }

  void _showDetailsDialog(BuildContext context, Medicine med, HistoryEntry entry) {
    final statusColor = _statusColor(entry.status);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Image.asset('assets/pill${med.iconIndex + 1}.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(med.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Chip(
                    label: Text(entry.status.name.toUpperCase()),
                    backgroundColor: statusColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              _detail("Amount:", med.amount),
              _detail("Type:", med.type),
              _detail("Taken at:", DateFormat('dd MMM yyyy • HH:mm').format(entry.takenTime)),
              _detail("Remind:", med.isRemind ? "Yes" : "No"),
              const SizedBox(height: 8),
              Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text(med.comments ?? "No notes available.", style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final med = medicine;
    final statusColor = _statusColor(entry.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsDialog(context, med, entry),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: Image.asset('assets/pill${med.iconIndex + 1}.png'),
          ),
          title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('dd MMM yyyy • HH:mm').format(entry.takenTime),
              style: TextStyle(color: Colors.grey.shade600)),
          trailing: Chip(
            label: Text(entry.status.name.toUpperCase()),
            backgroundColor: statusColor.withOpacity(0.1),
            labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
