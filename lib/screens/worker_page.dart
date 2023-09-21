import 'package:flutter/material.dart';

class WorkersPage extends StatefulWidget {
  @override
  _WorkersPageState createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  List<Worker> workers = [
    Worker(name: 'John Doe', orderAmount: 10),
    Worker(name: 'Jane Smith', orderAmount: 5),
    // Add more workers as needed
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
      appBar: AppBar(
        title: Text('Workers'),
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
              decoration: InputDecoration(
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
                  subtitle: Text('Order Amount: ${filteredWorkers[index].orderAmount}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerDetailsPage(worker: filteredWorkers[index]),
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

  Worker({
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
      appBar: AppBar(
        title: Text('Worker Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${worker.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Order Amount: ${worker.orderAmount}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

