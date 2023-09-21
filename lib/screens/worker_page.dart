import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorkersPageState createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  List<Worker> workers = [
    Worker(1, name: "سجاد", orderAmount: 19),
    Worker(2, name: "سلام", orderAmount: 20),
    Worker(5, name: "محمد", orderAmount: 40)
  ];

  List<Worker> filteredWorkers = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredWorkers = workers;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterWorkers(String searchQuery) {
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة العمال ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterWorkers(value);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredWorkers[index].name),
                  subtitle: Text(
                      'Order Amount: ${filteredWorkers[index].orderAmount}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkerDetailsPage(worker: filteredWorkers[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Worker {
  final String name;
  final int orderAmount;
  final int days;

  Worker(
    this.days, {
    required this.name,
    required this.orderAmount,
  });
}

class WorkerDetailsPage extends StatelessWidget {
  final Worker worker;

  const WorkerDetailsPage({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          worker.name.toString(),
          style: const TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                Text(
                    textAlign: TextAlign.end,
                    'الحساب: ${worker.orderAmount}',
                    style: const TextStyle(fontFamily: "myfont", fontSize: 25)),
                const SizedBox(height: 10),
                Text(
                    textAlign: TextAlign.end,
                    'الايام: ${worker.days}',
                    style: const TextStyle(fontFamily: "myfont", fontSize: 25)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
