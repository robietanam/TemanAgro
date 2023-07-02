import 'package:com.ppl.teman_agro_admin/src/core/props/text_font.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanPageView extends StatefulWidget {
  const BantuanPageView({super.key});

  @override
  State<BantuanPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<BantuanPageView> {
  @override
  Widget build(BuildContext context) {
    final url =
        "whatsapp://send?phone=+62895326363837&text=Hallo admin teman agro";
    final encoded = Uri.parse(url);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextJudul(
              text: 'Kontak kami',
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.chat,
                  color: Theme.of(context).colorScheme.onSecondary),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Buka di whatsapp ?'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          launchUrl(encoded);
                                        },
                                        child: Text('Oke')),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Batal')),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: TextJudul3(
                  text: '+62895326363837',
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
