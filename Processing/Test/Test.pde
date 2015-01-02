import procontroll.*; // http://creativecomputing.cc/p5libs/procontroll/
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick;
ControllButton button;
ControllButton button_reset;

ControllButton button_circle;
boolean button_circle_pre;
boolean goCircle;
int circle_timer;


ControllButton button_square;
boolean button_square_pre;
boolean goSquare;
int square_timer;
int t = 0;


ControllButton button_tri;
boolean button_tri_pre;
boolean goTri;
int tri_timer;
int t_tri = 0;


ControllButton button_x;
boolean button_x_pre;
boolean goX;
int x_timer;
int t_x = 0;

float totalX;
float totalY;

float totalX_pre;
float totalY_pre;

ArrayList<Point> points;
boolean btn_pre;
boolean btn_reset_pre;
boolean readyToGo;
boolean isPS3 = false;
int manualX,manualY;


boolean pressing;
boolean isShaping = false;

void setup(){
  size(400,400);
  

  controll = ControllIO.getInstance(this);

  device = controll.getDevice("PLAYSTATION(R)3 Controller");
  device.printSticks();
  device.printSliders();
  device.printButtons();
  device.setTolerance(0.05f);
  
  ControllSlider sliderX = device.getSlider("x");
  ControllSlider sliderY = device.getSlider("y");
  

  stick = new ControllStick(sliderX,sliderY);
  /* 
    0 = SELECT
    1 = L3
    2 = R3
    3 = START
    8 = L2
    9 = R2 
    10 = L1
    11 = R1
    12 = trianle
    13 = CIRCLE
    14 = X
    15 = SQUARE
    16 = PS BTN
    17 
  */ 
  button = device.getButton("11");
  button_reset = device.getButton("9");
  button_circle = device.getButton("13");
  button_square = device.getButton("15");
  button_tri = device.getButton("12");
  button_x = device.getButton("14");
  
  isPS3 = true;
 
  
  totalX = 0;
  totalY = 0;
  totalX_pre = 0;
  totalY_pre = 0;
  
  fill(0);
  points = new ArrayList<Point>();
  setupCP5();
  ardu_setup();
  
  
}


void draw(){
  background(255);
  // simple instructions
  textSize(16);
  text("Press R1 to the pen down", 20, height/2 - 100);
  text("Press R2 to reset", 20, height/2 - 70);
  text("Control left stick to move BOB", 20, height/2 - 40);
  
  text("Push Shape Buttons to draw Shapes", 20, height/2 - 10);
  text("( Hold R1 button to actually draw )", 20, height/2 + 20);

  if(isPS3){
    if(button.pressed()){
      fill(255,0,0);
    }else{
      fill(0);
    }
    if(!isShaping){
      totalX = constrain(totalX + stick.getX(),0,2500);
    totalY = constrain(totalY + stick.getY(),0,2500);
     }
    
    update_points();
     
   }else{
     
     if(mousePressed){
       fill(255,0,0);
      }else{
        fill(0);
      }
     
     totalX = constrain(totalX + manualX,0,2500);
     totalY = constrain(totalY + manualY,0,2500);
     update_points_mouse();
  }


}


void update_points(){
  
  if(button.pressed()) {
    if(!sending)sendMessage(TAGS,2);
    pressing = true;
  }
  else {
    pressing = false;
     if(!sending)sendMessage(TAGS,1);
  }
   
  if(button_reset.pressed() != btn_reset_pre){
    
   if(button_reset.pressed()){
    if(!sending) sendMessage(TAGH,2);
    
   }else{
   }
    btn_reset_pre = button_reset.pressed();
  }
  

  shapes();
  
  // normal drawing
  if(!isShaping){
  
    if(totalX != totalX_pre){
    
      float tempX = map(totalX,0,width,0.f,2500);
      
      if(!sending) {
       sendMessage(TAGY,(int)totalX);
        
      }
      if(button.pressed()) points.add(new Point(totalX, totalY));
      totalX_pre = totalX;
    }
    
    if(totalY != totalY_pre){
    
     float tempY = map(totalY,0,height,0.f,2500);
     if(!sending) sendMessage(TAGX,(int)totalY);
     if(button.pressed()) points.add(new Point(totalX, totalY));
      totalY_pre = totalY;
    }
  
  }else{
   
    totalX_pre = totalX;
    totalY_pre = totalY;
  
  }
  
  
  /* displaying all stick movements if required 
  if(points.size()!=0){
    for (int i = points.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    Point p = points.get(i);
    p.display();
    
    }  
  }
  */
  ellipse(totalX,totalY,5,5);
}

// simple drawing with mouse inputs
void update_points_mouse(){
  
    if(mousePressed &&  (mouseButton == LEFT) ) {
      if(!sending)sendMessage(TAGS,2);
    }
    else {
      if(!sending)sendMessage(TAGS,1);
    }
    
 
  
  if(totalX != totalX_pre){
    //println("x changed");
    //println(totalX);
    float tempX = map(totalX,0,width,0.f,2500);
    //println(tempX);
    if(!sending) {
     sendMessage(TAGY,(int)totalX*2);
      
    }
    if(mousePressed) points.add(new Point(totalX, totalY));
    totalX_pre = totalX;
  }
  
  if(totalY != totalY_pre){
   //println("y changed");
   float tempY = map(totalY,0,height,0.f,2500);
   if(!sending) sendMessage(TAGX,(int)totalY*2);
   if(mousePressed) points.add(new Point(totalX, totalY));
    totalY_pre = totalY;
  }
  
  
  /* displaying all stick movements if required 
  if(points.size()!=0){
    for (int i = points.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    Point p = points.get(i);
    p.display();
    
    }  
  }
  */
  ellipse(totalX,totalY,5,5);
}


float tempX_sx =0;
float tempY_sx =0;
    
void shapes(){
   
  if(button_circle.pressed() != button_circle_pre){
   
    if(button_circle.pressed() && goCircle == false){
      println("circlePressed");
     
     //   prevent edging confliction
       
      if(totalX < 200 ){
        sendMessage(TAGY,200);
        totalX = 200;       
        goCircle = true;
        isShaping = true;
        t= 0;
      }
      
      else if(totalX > 2200){
      
        sendMessage(TAGY,2200);
        totalX = 2200;
        goCircle = true;
        isShaping = true;
        t= 0;
      }else if(totalY < 200){
      
        sendMessage(TAGX,200);
        totalY = 200;
        goCircle = true;
        isShaping = true;
        t= 0;
      }else if(totalY > 2100){
      
        sendMessage(TAGX,2100);
        totalY = 2100;
        goCircle = true;
        isShaping = true;
        t= 0;
      }
      else {
        goCircle = true;
        isShaping = true;
        t= 0;
      }
      
        
      
   }else{
     goCircle = false;
     isShaping = false;
     println("circle released");
   }
    button_circle_pre = button_circle.pressed();
  }
  
 
  
  if(goCircle){
    if(abs(millis()-circle_timer)>25){
     
       t++;
       float tempX = (totalX-50) +  cos(radians(t))*50;
       float tempY = totalY +  sin(radians(t))*50;
       
       sendMessage(TAGY,(int)tempX);
       sendMessage(TAGX,(int)tempY);   
   
       
      if(t > 359) {
        
        
        t = 0;
       // sendMessage(TAGS,1);
        goCircle = false;
      }
      circle_timer = millis();
    }
  
  }
  
  
  if(button_square.pressed() != button_square_pre){
   
    if(button_square.pressed() && goSquare == false){
      println("squarePressed");
      
      
       if(totalX < 200 ){
        sendMessage(TAGY,200);
        totalX = 200;
       
        goSquare = true;
        isShaping = true;
        t= 0;
      }
      
      else if(totalX > 2200){
      
        sendMessage(TAGY,2200);
        totalX = 2200;
        goSquare = true;
        isShaping = true;
        t= 0;
      }else if(totalY < 200){
      
        sendMessage(TAGX,200);
        totalY = 200;
        goSquare = true;
        isShaping = true;
        t= 0;
      }else if(totalY > 2100){
      
        sendMessage(TAGX,2100);
        totalY = 2100;
        goSquare = true;
        isShaping = true;
        t= 0;
      }
      else {
        goSquare = true;
        isShaping = true;
        t= 0;
      }
      
      
   }else{
     //goSquare = false;
     isShaping = false;
     println("square released");
   }
    button_square_pre = button_square.pressed();
  }
  
  // sendMessage(TAGS,2);
  
  if(goSquare){
   
    if(abs(millis()-square_timer)>1000){
      
       float tempX =0;
       float tempY =0;
        t++;
       switch(t){
         
         case 0:
           tempX = totalX;
           tempY = totalY;
         break;
         
         case 1:
            tempX = totalX + 100;
            tempY = totalY;
         break;
         
         case 2:
            tempX = totalX + 100;
            tempY = totalY + 100;
         break;
         
         case 3:
            tempX = totalX;
            tempY = totalY + 100;
         break;
         
         case 4:
            tempX = totalX;
            tempY = totalY;
           // sendMessage(TAGS,1);
            
            totalX = tempX;
            totalY = tempY;
            t = 0;
            
            goSquare = false;
         break;
       }
       
       
       sendMessage(TAGY,(int)tempX);
       sendMessage(TAGX,(int)tempY);   
       
     
      square_timer = millis();
    }
  
  }
  
  
 if(button_tri.pressed() != button_tri_pre){
   
    if(button_tri.pressed() && goTri == false){
      println("tri Pressed");
      
       if(totalX < 200 ){
        sendMessage(TAGY,200);
        totalX = 200;
    ///    sendMessage(TAGX,(int)tempY);
       
        goTri = true;
        isShaping = true;
        t= 0;
      }
      
      else if(totalX > 2200){
      
        sendMessage(TAGY,2200);
        totalX = 2200;
        goTri = true;
        isShaping = true;
        t= 0;
      }else if(totalY < 200){
      
        sendMessage(TAGX,200);
        totalY = 200;
        goTri = true;
        isShaping = true;
        t= 0;
      }else if(totalY > 2100){
      
        sendMessage(TAGX,2100);
        totalY = 2100;
        goTri = true;
        isShaping = true;
        t= 0;
      }
      else {
        goTri = true;
        isShaping = true;
        t= 0;
      }
      
   }else{
     
      goTri = false;
      isShaping = false;
     println("tri released");
   }
    button_tri_pre = button_tri.pressed();
  }
  
  // sendMessage(TAGS,2);
  
  if(goTri){
    
  if(abs(millis()-tri_timer)>25){
      
     t++;
    if(t == 100) print(totalX);
    if(t < 101){
       sendMessage(TAGY,(int)totalX-t);
       sendMessage(TAGX,(int)totalY+t);
    }else if(t > 100 && t <301){
       int subT = t - 200;
       sendMessage(TAGY,(int)totalX + subT);
   
    }else if(t > 300 && t < 401){
       int subT = t - 400;
       sendMessage(TAGY,(int)totalX-subT);
       sendMessage(TAGX,(int)totalY-subT);
    }else{
      t = 0;
      goTri = false;  
      
    }
   
    
    tri_timer = millis();
  }
  
  }
  
  if(button_x.pressed() != button_x_pre){
   
    if(button_x.pressed() && goX == false){
      println("x Pressed");
      
      if(totalX < 200 ){
        sendMessage(TAGY,200);
        totalX = 200;
    ///    sendMessage(TAGX,(int)tempY);
       
        goX = true;
        isShaping = true;
        t= 0;
      }
      
      else if(totalX > 2200){
      
        sendMessage(TAGY,2200);
        totalX = 2200;
        goX = true;
        isShaping = true;
        t= 0;
      }else if(totalY < 200){
      
        sendMessage(TAGX,200);
        totalY = 200;
        goX = true;
        isShaping = true;
        t= 0;
      }else if(totalY > 2100){
      
        sendMessage(TAGX,2100);
        totalY = 2100;
        goX = true;
        isShaping = true;
        t= 0;
      }
      else {
        goX = true;
        isShaping = true;
        t= 0;
      }
      
   }else{
     
      goX = false;
      isShaping = false;
     println("x released");
   }
    button_x_pre = button_x.pressed();
  }
  
  // sendMessage(TAGS,2);
  
  if(goX){
    
    if(abs(millis()-x_timer)>50){
       
       t++;
      if(t < 101){
         tempX_sx = totalX - t;
         tempY_sx = totalY + t;
        
         sendMessage(TAGY,(int)tempX_sx);
         sendMessage(TAGX,(int)tempY_sx);
         println("1 // " + tempX_sx + " // "+ tempY_sx + " // " + t);
      }else if(t > 100 && t <151){
         //int subT = t - 200;
         int subT = t - 100;
        
        
         tempX_sx = tempX_sx + 1;
         tempY_sx = tempY_sx - 1;
         
         println("2 // " + tempX_sx + " // "+ tempY_sx + " // " + subT);
         sendMessage(TAGY,(int)tempX_sx);
         sendMessage(TAGX,(int)tempY_sx);
      
    }else if(t > 150 && t < 201){
         int subT = t - 150;
        
        
         tempX_sx = tempX_sx - 1;
         tempY_sx = tempY_sx - 1;
         println("3 // " + tempX_sx + " // "+ tempY_sx + " // " + subT);
         sendMessage(TAGY,(int)tempX_sx);
         sendMessage(TAGX,(int)tempY_sx);
    }else if(t > 200 && t < 301){
         int subT = t - 200;
        
        
         tempX_sx = tempX_sx + 1;
         tempY_sx = tempY_sx + 1;
         println("4 // " + tempX_sx + " // "+ tempY_sx + " // " + subT);
         sendMessage(TAGY,(int)tempX_sx);
         sendMessage(TAGX,(int)tempY_sx);
     }else{
        println("drawing x done");
        t = 0;
        goX = false;  
        
      }
     
      
      x_timer = millis();
    }

  
  }
  
  
}

void resetAll(){
  
  totalX = 500;
  totalY = 500;
  totalX_pre = 500;
  totalY_pre = 500;
  for (int i = points.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    points.remove(i);
    
  }  
}
