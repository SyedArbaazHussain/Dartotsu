import 'package:objectbox/objectbox.dart';
import 'objectbox.g.dart';

import 'ShowResponse.dart';

class ObjectBox {
  late final Store store;
  late final Box<ShowResponse> responseTokenBox;

  ObjectBox._create(this.store) {
    responseTokenBox = store.box<ShowResponse>();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  Future<void> close() async => store.close();
}

late final ObjectBox objectBox;

Box<ShowResponse> get responseTokenBox => objectBox.responseTokenBox;