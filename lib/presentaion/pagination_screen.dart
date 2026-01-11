import 'package:flutter/material.dart';
import 'package:pagination_with_rxdart/domain/entities/item.dart';
import 'package:pagination_with_rxdart/data/datasources/local_item_datasource.dart';
import 'package:pagination_with_rxdart/data/repositories/item_repository_impl.dart';
import 'package:pagination_with_rxdart/presentaion/widgets/custom_loading_indicator.dart';

class PaginationScreen extends StatefulWidget {
  const PaginationScreen({super.key});

  @override
  State<PaginationScreen> createState() => _PaginationScreenState();
}

class _PaginationScreenState extends State<PaginationScreen> {


  @override
  void initState() {
    super.initState();
    //Implement it next
    // _repository = ItemRepositoryImpl(LocalItemDatasource());
    // _loadItems();
  }
  // List to hold items (domain entity)
  List<Item> items = List.generate(
    20,
    (index) => Item(
      id: index + 1,
      title: 'Item ${index + 1}',
      description: 'Description for item ${index + 1}',
    ),
  );
  bool _loading = false;

  late final ItemRepositoryImpl _repository;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        animateColor: true,
        backgroundColor: Colors.greenAccent,
        shadowColor: Color.fromARGB(221, 249, 249, 249),
        centerTitle: true,

        title: const Text('Pagination Bottom Load',style: TextStyle(fontWeight: FontWeight.bold),) ,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: items.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        // Show custom loading indicator as the last item
                        if (index == items.length) {
                          return const CustomLoadingIndicator(
                            size: 60.0,
                            primaryColor: Colors.greenAccent,
                            secondaryColor: Colors.green,
                          );
                        }
                        
                        final item = items[index];
                        
                        return ListTile(
                          tileColor: Colors.amber[100],
                          leading: CircleAvatar(child: Text(item.id.toString())),
                          title: Text(item.title,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                          subtitle: Text(item.description,style: const TextStyle(fontStyle: FontStyle.italic,fontSize: 13),),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }


//Implement it next
  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final fetched = await _repository.fetchItems();
      setState(() {
        items = fetched;
      });
    } catch (e) {
      // in a real app handle/report error properly
      debugPrint('Failed to load items: $e');
    } finally {
      setState(() => _loading = false);
    }
  }
}