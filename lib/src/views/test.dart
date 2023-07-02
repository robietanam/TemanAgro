import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/props/main_paint.dart';

/// Providers are declared globally and specify how to create a state
final counterProvider = StateNotifierProvider<Counter, int>((ref) {
  return Counter();
});

final counterProvider2 = StateNotifierProvider<Counter, int>((ref) {
  return Counter();
});

class Counter extends StateNotifier<int> {
  Counter() : super(0);
  void increment() => state++;
  void doubleIncrement() => state += 2;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod example'),
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You have pushed the button this many times:'),
                  Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(counterProvider);
                      final count2 = ref.watch(counterProvider2);
                      return Column(
                        children: [
                          Text(
                            '$count',
                            key: const Key('counterState'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '$count2',
                            key: const Key('counterState2'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      );
                    },
                  ),
                  FloatingActionButton(
                    key: const Key('increment_floatingActionButton2'),
                    // The read method is a utility to read a provider without listening to it
                    onPressed: () =>
                        ref.read(counterProvider2.notifier).doubleIncrement(),
                    tooltip: 'Increment',
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment_floatingActionButton'),
        // The read method is a utility to read a provider without listening to it
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
