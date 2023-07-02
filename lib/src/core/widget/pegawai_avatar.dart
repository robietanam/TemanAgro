import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/avatar/avatar_provider.dart';

class PegawaiDetailAvatarIcon extends StatefulHookConsumerWidget {
  const PegawaiDetailAvatarIcon({
    this.imageInheritURL,
    this.filePath,
    Key? key,
  }) : super(key: key);

  // const AvatarIcon({super.key, this.imageInheritURL});
  final String? imageInheritURL;
  final String? filePath;
  @override
  ConsumerState<PegawaiDetailAvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends ConsumerState<PegawaiDetailAvatarIcon> {
  dynamic test = const AssetImage(
    "assets/images/noimage.png",
  );

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
                          .read(pegawaiDetailAvatarNotifierProvider.notifier)
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
                          .read(pegawaiDetailAvatarNotifierProvider.notifier)
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
    ref.invalidate(pegawaiDetailAvatarNotifierProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? filePath = ref.watch(pegawaiDetailAvatarNotifierProvider);
    // filePath = (filePath != null) ? filePath : widget.filePath;
    print("=====================");
    print(filePath);
    FileImage? fileImage;
    if (filePath != null) {
      final file = File(filePath);
      fileImage = FileImage(file);
    }

    if (widget.imageInheritURL != null) {
      test = NetworkImage(widget.imageInheritURL!);
    }
    return Stack(
      children: [
        ElevatedButton(
          onPressed: () {
            myAlert();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white, // <-- Button color
            foregroundColor: Colors.white, // <-- Splash color
          ),
          child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(90),
              child: Image(
                fit: BoxFit.cover,
                image: fileImage ?? test,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(
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
        ),
        Positioned(
          right: 20,
          bottom: 0,
          child: FloatingActionButton(
            onPressed: () {
              print("edit");
            },
            child: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }
}
