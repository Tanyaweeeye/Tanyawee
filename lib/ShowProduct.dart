import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'productdetail.dart';

//Method หลักทีRun //มีเพื่อให้รันหน้าโดด ๆ ได้ แต่ไม่ต้องมีก็ได้ถ้ารันผ่านหน้าอื่นมา
void main() {
  runApp(MyApp());
}

//Class stateless สั่งแสดงผลหนาจอ
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 102, 186)),
        useMaterial3: true,
      ),
      home: ShowProduct(),
    );
  }
} //มีเพื่อให้รันหน้าโดด ๆ ได้ แต่ไม่ต้องมีก็ได้ถ้ารันผ่านหน้าอื่นมา

//Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class ShowProduct extends StatefulWidget {
  @override
  State<ShowProduct> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShowProduct> {
//ส่วนเขียน Code ภาษา dart เพื่อรับค่าจากหน้าจอมาคํานวณหรือมาทําบางอย่างและส่งค่ากลับไป
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];
  Future<void> fetchProducts() async {
    try {
//เติมบรรทัดที่ใช้ query ข้อมูล กรองสินค้าที่ราคา >= 500
      final query = dbRef.orderByChild('price').startAt(0);

// ดึงข้อมูลจาก Realtime Database
      final snapshot = await query.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];
// วนลูปเพื่อแปลงข้อมูลเป็ น Map
        snapshot.children.forEach((child) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          product['key'] =
              child.key; // เก็บ key สําหรับการอ้างอิง (เช่นการแก้ไข/ลบ)
          loadedProducts.add(product);
        });
        loadedProducts.sort((a, b) => a['price']
            .compareTo(b['price'])); //การเรียงลำดับขอมูลตามราคา จากนอยไปมาก
// อัปเดต state เพื่อแสดงข้อมูล
        setState(() {
          products = loadedProducts;
        });
        print(
            "จํานวนรายการสินค้าทั้งหมด: ${products.length} รายการ"); // Debugging
      } else {
        print("ไม่พบรายการสินค้าในฐานข้อมูล"); // กรณีไม่มีข้อมูล
      }
    } catch (e) {
      print("Error loading products: $e"); // แสดงข้อผิดพลาดทาง Console
// แสดง Snackbar เพื่อแจ้งเตือนผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(); // เรียกใช้เมื่อ Widget ถูกสร้าง
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

//ส่วนการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แสดงข้อมูลสินค้า'),
        backgroundColor: const Color.fromARGB(255, 255, 102, 186),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // พื้นหลังเป็นภาพ
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'), // ใส่ชื่อไฟล์ภาพพื้นหลัง
                fit: BoxFit.cover,
              ),
            ),
          ),

          products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          product['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: const Color.fromARGB(255, 201, 0, 111),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'รายละเอียดสินค้า: ${product['description']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 247, 42, 155),
                              ),
                            ),
                            Text(
                              'ประเภท: ${product['category']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 247, 42, 155),
                              ),
                            ),
                            Text(
                              'จำนวน: ${product['quantity']} ชิ้น',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 247, 42, 155),
                              ),
                            ),
                            Text(
                              'วันที่ผลิต: ${formatDate(product['productionDate'])}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 247, 42, 155),
                              ),
                            ),
                          ],
                        ), //สามารถใส่ได้มากกว่า 1 รายการ

                        trailing: Text(
                          'ราคา : ${product['price']} บาท',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color.fromARGB(255, 247, 42, 155),
                          ),
                        ), //สามารถใส่ได้มากกว่า 1 รายการ

                        onTap: () {
//เมื่อกดที่แต่ละรายการจะเกิดอะไรขึ้น
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => productdetail(
                                product: product, // ส่งข้อมูลสินค้า
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
