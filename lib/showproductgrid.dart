import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'productdetail.dart';

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
      home: showproductgrid(),
    );
  }
}

//Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class showproductgrid extends StatefulWidget {
  @override
  State<showproductgrid> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<showproductgrid> {
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

  //ฟังก์ชันที่ใช้ลบ
  void deleteProduct(String key, BuildContext context) {
//คําสั่งลบโดยอ้างถึงตัวแปร dbRef ที่เชือมต่อตาราง product ไว้
    dbRef.child(key).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบสินค้าเรียบร้อย')),
      );
      fetchProducts();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  //ฟังก์ชันถามยืนยันก่อนลบ
  void showDeleteConfirmationDialog(String key, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิ ด Dialog โดยการแตะนอกพื้นที่
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจว่าต้องการลบสินค้านี้ใช่หรือไม่?'),
          actions: [
// ปุ่ มยกเลิก
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('ไม่ลบ'),
            ),
// ปุ่ มยืนยันการลบ
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
                deleteProduct(key, context); // เรียกฟังก์ชันลบข้อมูล
//ข้อความแจ้งว่าลบเรียบร้อย
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //ฟังก์ชันแสดง AlertDialog หน้าจอเพื่อแก้ไขข้อมูล
  void showEditProductDialog(Map<String, dynamic> product) {
    //ตัวอย่างประกาศตัวแปรเพื่อเก็บค่าข้อมูลเดิมที่เก็บไว้ในฐานข้อมูล ดึงมาเก็บไว้ตัวแปรที่กําหนด
    TextEditingController nameController =
        TextEditingController(text: product['name']);
    TextEditingController descriptionController =
        TextEditingController(text: product['description']);
        TextEditingController selectedCategory =
        TextEditingController(text: product['category']);
        TextEditingController priceController =
        TextEditingController(text: product['price'].toString());
    TextEditingController quantityController =
        TextEditingController(text: product['quantity'].toString());
         TextEditingController _selectedOption =
        TextEditingController(text: product['discount']);
    TextEditingController productionDate = TextEditingController(
        text: product['productionDate'] != null
            ? DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(product['productionDate']))
            : '');

    //สร้าง dialog เพื่อแสดงข้อมูลเก่าและให้กรอกข้อมูลใหม่เพื่อแก้ไข
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูลสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, //ดึงข้อมูลชื่อเก่ามาแสดงผลจาก
                  decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
                ),
                TextField(
                  controller:
                      descriptionController, //ดึงข้อมูลรายละเอียดเก่ามาแสดงผล
                  decoration: InputDecoration(labelText: 'รายละเอียด'),
                ),
                TextField(
                  controller:selectedCategory, //ดึงข้อมูลประเภทสินค้าเก่ามาแสดงผล

                  decoration: InputDecoration(labelText: 'ประเภทสินค้า'),
                ),
                TextField(
                  controller: quantityController, //ดึงข้อมูลจำนวนเก่ามาแสดงผล
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'จำนวน'),
                ),
                TextField(
                  controller: priceController, //ดึงข้อมูลราคาเก่ามาแสดงผล
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'ราคา'),
                ),
                TextField(
                  controller: _selectedOption, //ดึงข้อมูลชื่อเก่ามาแสดงผลจาก
                  decoration: InputDecoration(labelText: 'ส่วนลด'),
                ),
                TextField(
                  controller: productionDate, //ดึงข้อมูลวันผลิตเก่ามาแสดงผล
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'วันผลิต'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                 // ตรวจสอบว่าเป็นตัวเลขก่อน
                String priceText = priceController.text;
                String quantityText = quantityController.text;
 
                // ตรวจสอบราคา
                if (priceText.isEmpty || int.tryParse(priceText) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณากรอกราคาเป็นตัวเลข')));
                  return;
                }
                // ตรวจสอบจำนวน
                if (quantityText.isEmpty || int.tryParse(quantityText) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณากรอกจำนวนเป็นตัวเลข')));
                  return;
                }
// เตรียมข้อมูลที่แก้ไขแล้ว
                Map<String, dynamic> updatedData = {
                  'name': nameController.text, //ชื่อ
                  'description': descriptionController.text, //รายละเอียด
                  'price': int.parse(priceController.text), //ราคา
                  'category': selectedCategory.text, //ประเภท
                  'quantity': int.parse(quantityController.text), //จำนวน
                'discount': _selectedOption.text, // ส่วนลด
                'productionDate': productionDate.text.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').parse(productionDate.text).toIso8601String()
                      : null, // วันผลิต
                };

                dbRef
                    .child(
                      product['key'],
                    )
                    .update(updatedData)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อย')),
                  );
                  fetchProducts(); // เรียกใช้ฟังก์ชันเพื่อโหลดข้อมูลใหม่เพื่อแสดงผลหลังการแก้ไขเช่น fetchProducts
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                });
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
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
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // กำหนดจำนวนคอลัมน์เป็น 2
                    crossAxisSpacing: 10.0, // ระยะห่างระหว่างคอลัมน์
                    mainAxisSpacing: 10.0, // ระยะห่างระหว่างแถว
                    childAspectRatio:
                        1.0, // สัดส่วนกว้าง:สูง 1:1 (เป็นสี่เหลี่ยมจตุรัส)
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
// รอใส่ code Navigator.push() เพื่อไปยังหน้า webviewscreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => productdetail(
                              product: product, // ส่งข้อมูลสินค้า
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12.0), // ทำมุมให้โค้งมน
                        ),
                        child: Center(
                          // ทำให้เนื้อหาทั้งหมดอยู่กลาง
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // จัดตำแหน่งในแนวตั้ง
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // จัดตำแหน่งในแนวนอน
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: const Color.fromARGB(255, 201, 0, 111),
                                ),
                                textAlign: TextAlign
                                    .center, // ทำให้ข้อความชื่อสินค้าอยู่กลาง
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'รายละเอียดสินค้า: ${product['description']}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color:
                                      const Color.fromARGB(255, 247, 42, 155),
                                ),
                                textAlign: TextAlign
                                    .center, // ทำให้ข้อความรายละเอียดอยู่กลาง
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'ราคา : ${product['price']} บาท',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color:
                                      const Color.fromARGB(255, 247, 42, 155),
                                ),
                                textAlign: TextAlign
                                    .center, // ทำให้ข้อความราคาอยู่กลาง
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .end, // จัดเรียงให้ปุ่มอยู่ขวาสุด
                                children: [
                                  SizedBox(height: 20.0),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      width: 50,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .red[50], // พื้นหลังสีแดงอ่อน
                                          shape: BoxShape.circle, // รูปทรงวงกลม
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            // เรียกใช้ฟังก์ช้น showDeleteConfirmationDialog โดยส่งค่า Primary key เข้าไป
                                            showDeleteConfirmationDialog(
                                                product['key'], context);
                                          },
                                          icon: Icon(Icons.delete),
                                          color: const Color.fromARGB(
                                              255, 236, 0, 59), // สีของไอคอน
                                          iconSize: 20,
                                          tooltip: 'ลบสินค้า',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      width: 50,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .red[50], // พื้นหลังสีแดงอ่อน
                                          shape: BoxShape.circle, // รูปทรงวงกลม
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            // กดปุ่ มลบแล้วจะให้เกิดอะไรขึ้น
                                            showEditProductDialog(product); // เปด Dialog แก้ไขสินค้า
                                          },
                                          icon: Icon(Icons.edit),
                                          color: const Color.fromARGB(
                                              255, 236, 0, 59), // สีของไอคอน
                                          iconSize: 20,
                                          tooltip: 'แก้ไขสินค้า',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
