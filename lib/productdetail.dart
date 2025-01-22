import 'package:flutter/material.dart';

class productdetail extends StatelessWidget {
  final Map<String, dynamic> product; // รับข้อมูลสินค้า

  // Constructor
  productdetail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'รายละเอียดสินค้า'),
        backgroundColor: const Color.fromARGB(255, 255, 102, 186),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'), // กำหนดที่อยู่ของภาพพื้นหลัง
            fit: BoxFit.cover, // ให้ภาพขยายเต็มหน้าจอ
          ),
        ),
        child: Center( // ใช้ Center เพื่อจัดข้อมูลให้อยู่กลางหน้าจอ
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( // เพื่อให้สามารถเลื่อนดูข้อมูลได้หากข้อมูลมากเกินไป
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // จัดข้อความในแนวตั้งให้อยู่กลาง
                crossAxisAlignment: CrossAxisAlignment.center, // จัดข้อความในแนวนอนให้อยู่กลาง
                children: [
                  Text(
                    'ชื่อสินค้า : ${product['name'] ?? 'ไม่มีชื่อสินค้า'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0, // ขนาดตัวอักษรที่ใหญ่ขึ้น
                      color: const Color.fromARGB(255, 201, 0, 111),
                    ),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่กลางในแนวนอน
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'รายละเอียด : ${product['description'] ?? 'ไม่มีรายละเอียด'}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 247, 42, 155),
                    ),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่กลางในแนวนอน
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ราคาสินค้า : ${product['price']} บาท',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 247, 42, 155),
                    ),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่กลางในแนวนอน
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'จำนวน : ${product['quantity']} ชิ้น',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 247, 42, 155),
                    ),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่กลางในแนวนอน
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}