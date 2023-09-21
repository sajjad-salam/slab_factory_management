import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class out_screen extends StatefulWidget {
  const out_screen({super.key});

  @override
  State<out_screen> createState() => _out_screenState();
}

class _out_screenState extends State<out_screen> {
  List<Customer> customers = [
    Customer(name: 'John Doe', customerNumber: 1),
    Customer(name: 'Jane Smith', customerNumber: 2),
    // Add more customers as needed
  ];

  List<Customer> filteredCustomers = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController addCustomerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
  }

  @override
  void dispose() {
    searchController.dispose();
    addCustomerController.dispose();
    super.dispose();
  }

  void filterCustomers(String searchQuery) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    final customerIndex = customers
        .indexWhere((customer) => customer.name == updatedCustomer.name);
    if (customerIndex != -1) {
      setState(() {
        customers[customerIndex] = updatedCustomer;
      });
    }
  }

  void addCustomer(String customerName) {
    final customerNumber = customers.length + 1;
    final newCustomer =
        Customer(name: customerName, customerNumber: customerNumber);
    setState(() {
      customers.add(newCustomer);
      filteredCustomers = customers;
    });
    addCustomerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الصادرات",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterCustomers(value);
              },
              decoration: InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredCustomers[index].name,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: "myfont",
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    '${filteredCustomers[index].customerNumber}',
                    style: TextStyle(
                      fontFamily: "myfont",
                    ),
                    textAlign: TextAlign.end,
                  ),
                  onTap: () async {
                    final updatedCustomer = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsPage(
                            customer: filteredCustomers[index]),
                      ),
                    );

                    if (updatedCustomer != null) {
                      await updateCustomer(updatedCustomer);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addCustomerController,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'اضافة عميل ',
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.4,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      String customerName = addCustomerController.text;
                      if (customerName.isNotEmpty) {
                        addCustomer(customerName);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Customer {
  final String name;
  final int customerNumber;

  Customer({
    required this.name,
    required this.customerNumber,
  });
}

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;

  // ignore: prefer_const_constructors_in_immutables
  CustomerDetailsPage({super.key, required this.customer});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late TextEditingController shtagernumber;

  @override
  void initState() {
    super.initState();
    shtagernumber =
        TextEditingController(text: widget.customer.customerNumber.toString());
  }

  @override
  void dispose() {
    shtagernumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(widget.customer.name.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الشتايكر',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الماستك',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الزفت',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الفلين',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الفلانكوت',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedCustomer = Customer(
                  name: widget.customer.name,
                  customerNumber: int.tryParse(shtagernumber.text) ??
                      widget.customer.customerNumber,
                );

                Navigator.pop(context, updatedCustomer);
              },
              child: const Text(
                textAlign: TextAlign.end,
                'تحديث',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "myfont",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
