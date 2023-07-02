import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pembayaran_detail.dart';

class PilihPaketPremiumView extends StatefulWidget {
  const PilihPaketPremiumView(
      {Key? key, required User user, required Map<String, dynamic> userData})
      : _user = user,
        _userData = userData,
        super(key: key);

  final User _user;
  final Map<String, dynamic> _userData;

  @override
  State<PilihPaketPremiumView> createState() => _PilihPaketPremiumViewState();
}

class _PilihPaketPremiumViewState extends State<PilihPaketPremiumView> {
  late User user;
  late Map<String, dynamic> userData;

  late double width;
  late double height;

  @override
  void initState() {
    user = widget._user;
    userData = widget._userData;

    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Paket Premium'),
        ),
        body: SingleChildScrollView(
            child: SafeArea(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(40),
                child: Image.asset(
                  "assets/images/premium-icon.png",
                  width: 140,
                ),
              ),
              TextJudul2(
                text: 'Upgrade Teman Agro Pro!',
                color: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                )
                              ]),
                          child: Container(
                            height: height / 9,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'Rp 75.000',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'Basic',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        '10 Pegawai',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        'Presensi Pegawai',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        'Laporan Keuangan',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailPembayaranView(
                                                    user: user,
                                                    userData: userData,
                                                    tipe: 1)));
                                  },
                                  child: const Text('Beli'),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30)),
                                ),
                              ],
                            ),
                          )),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              )
                            ]),
                        child: Container(
                          height: height / 7,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(
                                      'Rp 550.000',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(
                                      'Eksklusif',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const Column(
                                children: [
                                  Text(
                                    'Unlimited Pegawai',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    'Presensi Pegawai',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    'Laporan Keuangan',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    'Gaji Pegawai',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPembayaranView(
                                                  user: user,
                                                  userData: userData,
                                                  tipe: 3)));
                                },
                                child: const Text('Beli'),
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30)),
                              ),
                            ],
                          ),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                )
                              ]),
                          child: Container(
                            height: height / 10,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'Rp 350.000',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'Premium',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const Column(
                                  children: [
                                    Text(
                                      '50 Pegawai',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      'Presensi Pegawai',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      'Laporan Keuangan',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailPembayaranView(
                                                    user: user,
                                                    userData: userData,
                                                    tipe: 2)));
                                  },
                                  child: const Text('Beli'),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30)),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
