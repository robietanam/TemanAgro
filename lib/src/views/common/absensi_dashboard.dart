import 'package:flutter/material.dart';

import '../../core/props/text_font.dart';

class AbsensiDashboard extends StatelessWidget {
  AbsensiDashboard({super.key, this.userData});
  Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = Theme.of(context).primaryColor;
    final _textColor = Theme.of(context).cardColor;
    if (userData != null && userData!.isNotEmpty) {
      return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: _backgroundColor,
          child: Padding(
            padding:
                const EdgeInsets.only(right: 8, left: 8, bottom: 8, top: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 30,
                        child: Image.asset('assets/images/app-icon.png')),
                    SizedBox(
                      width: 5,
                    ),
                    const TextJudul2(text: "Teman Agro")
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(80.0),
                          child: (userData!["photoURL"] != null)
                              ? Image.network(
                                  userData!["photoURL"],
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/noimage.png',
                                      height: 70,
                                      width: 70,
                                    );
                                  },
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    print(frame);
                                    if (frame != null ||
                                        wasSynchronouslyLoaded) {
                                      return child;
                                    }
                                    return const Center(
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  'assets/images/noimage.png',
                                  height: 70,
                                  width: 70,
                                )),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextJudul(text: userData!['displayName']),
                            TextJudul2(
                              text: userData!['role'],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ));
    } else {
      return Container(
          height: 150,
          child: Card(
            color: _backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 30,
                          child: Image.asset('assets/images/app-icon.png')),
                      SizedBox(
                        width: 10,
                      ),
                      const TextJudul2(text: "Teman Agro")
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  CircularProgressIndicator(
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ));
    }
  }
}
