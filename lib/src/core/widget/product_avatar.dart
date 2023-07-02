import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/avatar/avatar_provider.dart';

class ProductAvatarIcon extends StatefulHookConsumerWidget {
  const ProductAvatarIcon({
    this.imageInheritURL,
    Key? key,
  }) : super(key: key);

  // const AvatarIcon({super.key, this.imageInheritURL});
  final String? imageInheritURL;
  @override
  ConsumerState<ProductAvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends ConsumerState<ProductAvatarIcon> {
  dynamic test = AssetImage("assets/images/noimage2.png") as ImageProvider;

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Pilih media gambar'),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      ref
                          .read(productAvatarNotifierProvider.notifier)
                          .chooseImage(ImageSource.gallery);
                      ImageCache().clearLiveImages();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.image),
                        Text('Galeri'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      ref
                          .read(productAvatarNotifierProvider.notifier)
                          .chooseImage(ImageSource.camera);
                      ImageCache().clearLiveImages();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.camera),
                        Text('Kamera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    ref.invalidate(productAvatarNotifierProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? filePath = ref.watch(productAvatarNotifierProvider);

    FileImage? fileImage;
    if (filePath != null) {
      final file = File(filePath);
      fileImage = FileImage(file);
    }

    if (widget.imageInheritURL != null) {
      test = NetworkImage(widget.imageInheritURL!);
    }
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    myAlert();
                  },
                  clipBehavior: Clip.antiAlias,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Image(
                    fit: BoxFit.fill,
                    image: fileImage ?? test,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Padding(
                        padding: EdgeInsets.all(60),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: FloatingActionButton(
                  heroTag: "EditProdukButton",
                  mini: true,
                  onPressed: () {
                    print("edit");
                  },
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
