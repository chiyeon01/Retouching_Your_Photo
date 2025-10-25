import 'package:flutter/material.dart';
import 'package:photo_retouching_app/screen/food_camera.dart';
import 'package:photo_retouching_app/screen/person_camera.dart';

class HomeScreen extends StatelessWidget {
  final firstCamera;

  const HomeScreen({
    super.key,
    required this.firstCamera,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFC3F8FF),
                Color(0xFF183E42),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Retouch ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 48.0,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    Text(
                      'Your Photo',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w200
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context){
                            return PersonCamera(
                              firstCamera: firstCamera,
                            );
                          }
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(
                        16.0,
                      ),
                      foregroundColor: Colors.grey,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      shadowColor: Color(0xFF0F2C30),
                      side: BorderSide(
                        color: Colors.black.withOpacity(0.1),
                        width: 5.0,
                      ),
                      elevation: 5.0,
                      shape: CircleBorder()
                      ),
                    child: Text(
                      '인물',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      )
                    ),
                  ),
                  SizedBox(
                    width: 32.0,
                  ),
                  OutlinedButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context){
                            return FoodCamera(
                              firstCamera: firstCamera,
                            );
                          }
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.all(
                          16.0,
                        ),
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        shadowColor: Color(0xFF0F2C30),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.1),
                          width: 5.0,
                        ),
                        elevation: 5.0,
                        shape: CircleBorder()
                    ),
                    child: Text(
                        '음식',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        )
                    ),
                  ),
                  SizedBox(
                    width: 32.0
                  ),
                ],
              ),
              SizedBox(
                height: 64.0,
              ),
            ],
          ),
        )
      ),
    );
  }
}