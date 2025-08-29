import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salon_app/components/bottom_navigationbar.dart';
import 'package:salon_app/provider/user_provider.dart';

import '../../controller/auth_controller.dart';
// lib/screens/introduction/onboarding_screen.dart

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  ScrollController controller = ScrollController();
  double controllerOffset = 0.0;

  void move() {
    controller.animateTo(controllerOffset + 392,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 500));
  }

  bool isRev = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      move();
      setState(() {
        controllerOffset += 392;
      });
    });

    Future.delayed(const Duration(seconds: 8), () {
      move();
      setState(() {
        controllerOffset += 392;
      });
    });
  }

  List imgUrl = [
    "https://thumbs.dreamstime.com/b/hairdresser-protective-mask-cutting-hair-curly-african-american-client-beauty-salon-free-space-195792989.jpg",
    "https://as2.ftcdn.net/v2/jpg/02/65/48/75/1000_F_265487582_hg1t4uvUI33fhRDTdxVyHTNjv0F5WdX4.jpg",
    "https://www.nextinsurance.com/wp-content/uploads/2018/05/shutterstock_256912663-802x454.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            reverse: isRev,
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Row(
                children: imgUrl
                    .map((e) => BannerImages(
                          height: height,
                          width: width,
                          image: e,
                        ))
                    .toList()),
          ),
          SingleChildScrollView(
            reverse: isRev,
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _indicator(0),
                  const SizedBox(width: 10),
                  _indicator(1),
                  const SizedBox(width: 10),
                  _indicator(2),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          const Text(
            "The Professional Specialists",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "choose your hairStyle choose your hair\n          style choose your hairStyle",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
          GestureDetector(
            onTap: () async {
              // SOLO corre Google Sign-In en plataformas soportadas
              if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
                try {
                  final user =
                      await Authentication.signInWithGoogle(context: context);
                  if (user != null) {
                    userProvider.setUser(user);
                    if (mounted) {
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                const BottomNavigationComponent()),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Error de autenticación: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Firebase Google Sign-In no soportado en Linux/Desktop")),
                  );
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              height: 50,
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff721c80),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff721c80),
                    Color.fromARGB(255, 196, 103, 169),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                  child: Text(
                "Get Started",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
            ),
          )
        ],
      ),
    );
  }

  AnimatedContainer _indicator(int position) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      height: 5,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (controllerOffset >= position * 392 &&
                controllerOffset < (position + 1) * 392)
            ? const Color(0xff721c80).withAlpha((0.8 * 255).toInt())
            : Colors.grey.withAlpha((0.8 * 255).toInt()),
      ),
    );
  }
}

class BannerImages extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  const BannerImages({
    super.key,
    required this.image,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.8 * (height / 3),
      width: width,
      child: Image.network(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
