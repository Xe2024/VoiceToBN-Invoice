import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class InvoiceSection {
  final DateTime date;
  final List<DocumentSnapshot> invoices;

  InvoiceSection(this.date, this.invoices);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Invoices",
                      style: GoogleFonts.abhayaLibre(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("invoices")
                        .orderBy("createdOn", descending: true)
                        .snapshots(),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot,
                        ) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Something went Wrong!"),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData) {
                            List<DocumentSnapshot> allInvoiceDoc =
                                snapshot.data!.docs;
                            Map<DateTime, List<DocumentSnapshot>>
                            groupedInvoices = {};
                            for (var doc in allInvoiceDoc) {
                              Timestamp? timestamp =
                                  doc["createdOn"] as Timestamp?;
                              if (timestamp == null) continue;
                              DateTime invoiceDate = DateTime(
                                timestamp.toDate().year,
                                timestamp.toDate().month,
                                timestamp.toDate().day,
                              );
                              if (!groupedInvoices.containsKey(invoiceDate)) {
                                groupedInvoices[invoiceDate] = [];
                              }
                              groupedInvoices[invoiceDate]?.add(doc);
                            }
                            List<InvoiceSection> Sections = groupedInvoices
                                .entries
                                .map((entry) {
                                  return InvoiceSection(entry.key, entry.value);
                                })
                                .toList();
                            Sections.sort((a, b) => b.date.compareTo(a.date));
                            return ListView.builder(
                              itemCount: Sections.length,
                              itemBuilder: (context, sectionIndex) {
                                final InvoiceSection section =
                                    Sections[sectionIndex];
                                return StickyHeader(
                                  header: Container(
                                    color: Colors.black,
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      DateFormat(
                                        "EEEE, MMMM d, yyyy",
                                      ).format(section.date),
                                      style: GoogleFonts.abhayaLibre(
                                        color: Colors.white,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ),
                                  content: Column(
                                    children: section.invoices.map((
                                      invoiceDoc,
                                    ) {
                                      return ListTile(
                                        title: Text(
                                          invoiceDoc["name"] ?? '',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                  ),
                ),
              ],
            ),
            // Bottom bar overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "bottomBar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
