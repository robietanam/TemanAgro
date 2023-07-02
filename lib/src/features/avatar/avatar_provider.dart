import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AvatarNotifier extends StateNotifier<String?> {
  AvatarNotifier() : super(null);

  File? file;

  void chooseImage(ImageSource media) async {
    XFile? imagePick;
    File? image;

    imagePick = await ImagePicker().pickImage(source: media);

    if (imagePick != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePick.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.rectangle,
        compressQuality: 20,
      );

      if (croppedFile != null) {
        file = File(croppedFile.path);

        String nameFile = imagePick.name;
        Directory tmpPath = await getTemporaryDirectory();

        String path = "${tmpPath.path}/tmp_profile";

        await Directory(path).create(recursive: true);

        // if (Directory(path).existsSync()) {
        //   Directory(path).deleteSync(recursive: true);
        // }

        // copy the file to a new path
        image = await file?.copy('$path/$nameFile.png');
        print(image?.path);
        state = image?.path;
      }
    }
  }
}

final profileAvatarNotifierProvider =
    StateNotifierProvider<AvatarNotifier, String?>((ref) => AvatarNotifier());

final pegawaiDetailAvatarNotifierProvider =
    StateNotifierProvider<AvatarNotifier, String?>((ref) => AvatarNotifier());

final productAvatarNotifierProvider =
    StateNotifierProvider<AvatarNotifier, String?>((ref) => AvatarNotifier());
