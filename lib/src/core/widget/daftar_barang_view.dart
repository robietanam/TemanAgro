import 'package:flutter/material.dart';

class DaftarBarangView extends StatelessWidget {
  const DaftarBarangView(
      {super.key, this.judul, this.deskripsi, this.imageURL});

  final judul;
  final deskripsi;
  final imageURL;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left),
                  SizedBox(
                    width: 200,
                    child: Text(deskripsi,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.left),
                  )
                ],
              ),
              Container(
                height: 80,
                width: 100,
                color: Colors.amber,
                child: Image.network(
                  imageURL,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
