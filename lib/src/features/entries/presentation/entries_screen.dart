import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voting_app/src/common_widgets/list_items_builder.dart';
import 'package:voting_app/src/constants/app_sizes.dart';
import 'package:voting_app/src/constants/strings.dart';
import 'package:voting_app/src/features/entries/application/entries_service.dart';
import 'package:voting_app/src/features/entries/domain/entries_list_tile_model.dart';

class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.indigo, Colors.blue],
            ),
          ),
        ),
        elevation: 0.0,
        title: const Text(Strings.history),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.how_to_vote_rounded),
            onPressed: () {},
          ),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationVersion: '^1.0.0',
                  applicationName: 'ElectChain',                 
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // * This data is combined from two streams, so it can't be returned
          // * directly as a Query object from the repository.
          // * As a result, we can't use FirestoreListView here.
          final entriesTileModelStream =
              ref.watch(entriesTileModelStreamProvider);
          return ListItemsBuilder<EntriesListTileModel>(
            data: entriesTileModelStream,
            itemBuilder: (context, model) => EntriesListTile(model: model),
          );
        },
      ),
    );
  }
}

class EntriesListTile extends StatelessWidget {
  const EntriesListTile({super.key, required this.model});
  final EntriesListTileModel model;

  @override
  Widget build(BuildContext context) {
    const fontSize = 16.0;
    return Container(
      color: model.isHeader ? Colors.indigo[100] : null,
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.p8,
        horizontal: Sizes.p16,
      ),
      child: Row(
        children: <Widget>[
          Text(model.leadingText, style: const TextStyle(fontSize: fontSize)),
          Expanded(child: Container()),
          if (model.middleText != null)
            Text(
              model.middleText!,
              style: TextStyle(color: Colors.green[700], fontSize: fontSize),
              textAlign: TextAlign.right,
            ),
          SizedBox(
            width: 60.0,
            child: Text(
              model.trailingText,
              style: const TextStyle(fontSize: fontSize),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
