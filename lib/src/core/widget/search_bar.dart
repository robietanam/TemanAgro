import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/data/search_barang_provider.dart';

class CustomSearchBar extends ConsumerWidget {
  const CustomSearchBar(
      {super.key,
      required this.width,
      required this.searchController,
      required this.provider});

  final double width;
  final TextEditingController searchController;
  final StateProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                spreadRadius: 0.8,
                offset: Offset(3, 3))
          ]),
      width: width / 1.25,
      child: TextField(
        onChanged: (newValue) {
          ref.read(provider.notifier).state = newValue;
        },
        controller: searchController,
        cursorColor: Color(0xFF7972E6),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 1,
                color: Color(0xFF7972E6),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: const OutlineInputBorder(
                borderSide: BorderSide(
              width: 1,
              color: Color(0xFF7972E6),
            ))),
      ),
    );
  }
}
