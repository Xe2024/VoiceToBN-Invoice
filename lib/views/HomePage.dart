import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class InvoiceSection {
  final DateTime date;
  final List<DocumentSnapshot> invoices;

  InvoiceSection(this.date, this.invoices);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAccount = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white, // Change Background color
        systemNavigationBarIconBrightness:
            Brightness.light, // Change Icon color
      ),

      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.all(0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Invoices",
                          style: GoogleFonts.abhayaLibre(
                            fontSize: 40,
                            color: Colors.white,
                          ),
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
                                    return InvoiceSection(
                                      entry.key,
                                      entry.value,
                                    );
                                  })
                                  .toList();
                              Sections.sort((a, b) => b.date.compareTo(a.date));
                              return ListView.builder(
                                padding: EdgeInsets.only(
                                  bottom: 250,
                                  left: 20,
                                  right: 20,
                                ),

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
              // ...inside your Stack children:
              StatefulBuilder(
                builder: (context, setBarState) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInCubic,
                        height: showAccount ? 250 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                7,
                                7,
                                7,
                              ).withOpacity(0.6),
                              blurRadius: 24,
                              offset: Offset(0, -3),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 5,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.account_circle,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    setBarState(() {
                                      showAccount = !showAccount;
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor: Colors.black,
                                    elevation: 5,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                Icon(Icons.settings, color: Colors.black),
                              ],
                            ),
                            if (showAccount)
                              Expanded(
                                // padding: const EdgeInsets.only(top: 16.0),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),

                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Account Info",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "user@email.com",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Add your logout logic here
                                          },
                                          icon: Icon(
                                            Icons.logout,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            "Logout",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
