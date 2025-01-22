import 'package:flutter/material.dart';
import 'showfiltertype.dart';

//Method หลักทีRun
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
      home: showproducttype(),
    );
  }
}

//Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class showproducttype extends StatefulWidget {
  @override
  State<showproducttype> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<showproducttype> {
//ส่วนเขียน Code ภาษา dart เพื่อรับค่าจากหน้าจอมาคํานวณหรือมาทําบางอย่างและส่งค่ากลับไป

  final categories = ['Electronics', 'Clothing', 'Food', 'Books'];
  String? selectedCategory;

  // กำหนดไอคอนที่ตรงกับประเภทสินค้าแต่ละประเภท
  final List<IconData> categoryIcons = [
    Icons.electrical_services, // Electronics
    Icons.shopping_bag, // Clothing
    Icons.fastfood, // Food
    Icons.book, // Books
  ];

  @override
  void initState() {
    super.initState();
    // เรียกใช้เมื่อ Widget ถูกสร้าง
  }

  // ส่วนการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประเภทสินค้า'),
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
          categories.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator()) // ถ้าไม่มีข้อมูลใน categories
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // กำหนดจำนวนคอลัมน์เป็น 2
                    crossAxisSpacing: 10.0, // ระยะห่างระหว่างคอลัมน์
                    mainAxisSpacing: 10.0, // ระยะห่างระหว่างแถว
                    childAspectRatio:
                        1.0, // สัดส่วนกว้าง:สูง 1:1 (เป็นสี่เหลี่ยมจตุรัส)
                  ),
                  itemCount: categories.length, // จำนวนรายการใน categories
                  itemBuilder: (context, index) {
                    final category =
                        categories[index]; // ใช้ข้อมูลใน categories มาแสดง
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                showfiltertype(category: categories[index]),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12.0), // ทำมุมให้โค้งมน
                        ),
                        elevation: 6.0, // ให้การ์ดมีเงา
                        child: Padding(
                          padding: const EdgeInsets.all(
                              12.0), // เพิ่มระยะห่างในการ์ด
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // จัดตำแหน่งในแนวตั้ง
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // จัดตำแหน่งในแนวนอน
                            children: [
                              Text(
                                category, // แสดงประเภทสินค้าจาก categories
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: const Color.fromARGB(255, 201, 0, 111),
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // ถ้าชื่อยาวเกินไปจะถูกตัด
                                textAlign:
                                    TextAlign.center, // จัดข้อความให้กลาง
                              ),
                              SizedBox(
                                  height:
                                      8.0), // ระยะห่างระหว่างชื่อกับรายละเอียด
                              Icon(
                                categoryIcons[index],
                                size: 40.0, // ขนาดของไอคอน
                                color: Color.fromARGB(
                                    255, 253, 140, 202), // สีของไอคอน
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
