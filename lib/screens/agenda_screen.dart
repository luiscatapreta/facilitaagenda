import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  double _monthlyTotal = 0;

  DateTime _dayUtc(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlyTotal();
    });
  }

  // ===============================
  // STREAM DO DIA (UTC + RANGE)
  // ===============================
  Stream<List<Booking>> _bookingsForSelectedDay() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final start = _dayUtc(_selectedDay);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Booking(
          id: doc.id,
          clientName: data['clientName'],
          value: (data['value'] as num).toDouble(),
          hasDeposit: data['hasDeposit'],
          notes: data['notes'],
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // ===============================
  // TOTAL MENSAL
  // ===============================
  Future<void> _loadMonthlyTotal() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final start = DateTime.utc(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime.utc(_focusedDay.year, _focusedDay.month + 1, 1);

    final snap = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    double total = 0;
    for (final d in snap.docs) {
      total += (d.data()['value'] as num).toDouble();
    }

    if (!mounted) return;
    setState(() => _monthlyTotal = total);
  }

  // ===============================
  // MODAL CRIAR / EDITAR
  // ===============================
  void _openBookingDialog({Booking? booking}) {
    final nameCtrl =
        TextEditingController(text: booking?.clientName ?? '');
    final valueCtrl =
        TextEditingController(text: booking?.value.toString() ?? '');
    final notesCtrl =
        TextEditingController(text: booking?.notes ?? '');
    bool hasDeposit = booking?.hasDeposit ?? false;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      booking == null
                          ? 'Novo agendamento'
                          : 'Editar agendamento',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: valueCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        prefixText: 'R\$ ',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('Sinal pago'),
                      value: hasDeposit,
                      onChanged: (v) =>
                          setModalState(() => hasDeposit = v),
                    ),

                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        if (booking != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              label: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(booking.id)
                                    .delete();
                                _loadMonthlyTotal();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        if (booking != null)
                          const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            onPressed: () async {
                              final uid = FirebaseAuth
                                  .instance.currentUser!.uid;
                              final dayUtc = _dayUtc(_selectedDay);

                              if (booking == null) {
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .add({
                                  'userId': uid,
                                  'clientName': nameCtrl.text,
                                  'value': double.tryParse(
                                        valueCtrl.text
                                            .replaceAll(',', '.'),
                                      ) ??
                                      0,
                                  'hasDeposit': hasDeposit,
                                  'notes': notesCtrl.text,
                                  'date': Timestamp.fromDate(dayUtc),
                                });
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(booking.id)
                                    .update({
                                  'clientName': nameCtrl.text,
                                  'value': double.tryParse(
                                        valueCtrl.text
                                            .replaceAll(',', '.'),
                                      ) ??
                                      0,
                                  'hasDeposit': hasDeposit,
                                  'notes': notesCtrl.text,
                                });
                              }

                              _loadMonthlyTotal();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Locações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBookingDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) =>
                isSameDay(d, _selectedDay),

            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMonthlyTotal();
              });
            },

            // ✅ FIX: ATUALIZA TOTAL QUANDO MUDA O MÊS
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMonthlyTotal();
              });
            },
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '💰 Total do mês: R\$ ${_monthlyTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream: _bookingsForSelectedDay(),
              builder: (_, snapshot) {
                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return const Center(
                    child: Text('Nenhum agendamento neste dia'),
                  );
                }

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (_, i) {
                    final b = bookings[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          b.hasDeposit
                              ? Icons.verified
                              : Icons.event,
                          color:
                              b.hasDeposit ? Colors.green : Colors.grey,
                        ),
                        title: Text(b.clientName),
                        subtitle: Text(
                          'R\$ ${b.value.toStringAsFixed(2)} • '
                          '${b.hasDeposit ? 'Sinal pago' : 'Sem sinal'}',
                        ),
                        onTap: () =>
                            _openBookingDialog(booking: b),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}