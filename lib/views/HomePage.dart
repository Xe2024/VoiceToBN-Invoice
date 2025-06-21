import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'dart:ui';

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
                              padding: EdgeInsets.only(bottom: 80),
                              itemCount: Sections.length,
                              itemBuilder: (context, sectionIndex) {
                                final InvoiceSection section =
                                    Sections[sectionIndex];
                                return StickyHeader(
                                  header: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Optional: rounded corners
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        width: double
                                            .infinity, // Makes the header take full width
                                        color: Colors.black.withOpacity(
                                          0.3,
                                        ), // Semi-transparent overlay
                                        padding: EdgeInsets.all(8),
                                        child: Text(
                                          DateFormat(
                                            "dd/MM/yy",
                                          ).format(section.date),
                                          style: GoogleFonts.abhayaLibre(
                                            color: Colors.white,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  content: GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: section.invoices.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              2, // Number of cards per row
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio:
                                              1.2, // Adjust for card shape
                                        ),
                                    itemBuilder: (context, index) {
                                      final invoiceDoc =
                                          section.invoices[index];
                                      return Card(
                                        color: Colors.grey[900],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(24),
                                          child: Text(
                                            invoiceDoc["name"] ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
