#include <AccelStepper.h> // http://www.airspayce.com/mikem/arduino/AccelStepper/
#include <Servo.h> 

// Serial comm Tags
#define TAGX         'X'
#define TAGY         'Y'
#define TAGS         'S'
#define TAGH         'H'
#define TAGC         'C' // circle
#define TAGQ         'Q' // square
#define MESSAGE_BYTES  5  // the total bytes in a message

#define servoPin 5

//stepper stuff
AccelStepper stepperX(AccelStepper::DRIVER, 12, 13); // 12-PUL, 13-DIR PORT 3
AccelStepper stepperY(AccelStepper::DRIVER, 8, 11); // 8-PUL, 11-DIR, PORT 4


int limitSW_Y = A0; //PORT 7
int limitSW_X = A1; //PORT 8

// servo for a Pen movement
Servo myservo;  
int maxSpeed = 2000;
int servoUp_val = 30;
int currentX;
int currentY;

boolean drawingShape = false;
boolean moveServo = false;

void initMotor(){
  stepperX.setMaxSpeed(500);
  stepperX.setAcceleration(3000); // set X stepper speed and acceleration
  stepperY.setMaxSpeed(500);
  stepperY.setAcceleration(3000); // set Y stepper speed and acceleration
  stepperX.moveTo(-4000);
  stepperY.moveTo(-4000);// move XY to origin

  while(!digitalRead(limitSW_X))stepperX.run();
  while(!digitalRead(limitSW_Y))stepperY.run();// scanning stepper motor

  stepperX.setCurrentPosition(0);
  stepperY.setCurrentPosition(0); // reset XY position
  stepperX.setMaxSpeed(maxSpeed);
  stepperY.setMaxSpeed(maxSpeed);// set XY working speed
  
  delay(500);
 
  currentX = currentY = 0;
}


void resetMotor(){
  myservo.write(servoUp_val);
  initMotor();
  Serial.println("reset_done");
}


void setup()
{
  Serial.begin(57600);
  pinMode(limitSW_X, INPUT);
  pinMode(limitSW_Y, INPUT);

  myservo.attach(servoPin);  // attaches the servo on pin 9 to the servo object 
  myservo.write(servoUp_val);

  initMotor();
  Serial.begin(57600);

  while(!Serial){

  }
  
  Serial.println("done");
}

boolean goDebug = false;

void Debug(String d){
  if(goDebug) Serial.println(d);
}

int servo_val_pre;

void loop(){
  // process Serial inputs from Processing code
  if (Serial.available() >= MESSAGE_BYTES)
  {
    char tag = Serial.read();
    if(tag == TAGX){
      int val = Serial.read() * 256;
      val = val + Serial.read();
      currentX = val;
      moveStepperX(val);
  
    } 
    
    else if(tag == TAGY){
      int val = Serial.read() * 256;
      val = val + Serial.read();
      currentY = val;
      moveStepperY(val);
    }

    else if(tag == TAGH){
      int val = Serial.read() * 256;
      val = val + Serial.read();
      if(val ==2){
        resetMotor();
      }
    }

    else if(tag == TAGS){
      int val = Serial.read()*256;
      val = val + Serial.read();
      
      if(val != servo_val_pre){
        if(val == 2){
          moveServo = true;
         
        } // drawing val
        
        if(val == 1){
          moveServo = false;
        } 
        servo_val_pre = val;
      }
      
    }

    else{
      Debug("got message with unknown tag ");
      Debug(tag);
    } 
    
  } // serial.available
 

  if(moveServo)  myservo.write(0);
  else  myservo.write(servoUp_val);

  stepperX.run();
  stepperY.run();
  
} //loop


void tapDown(){
  myservo.write(5);
}

void tapUp(){
  myservo.write(70);   
}

void moveStepperX(int n){
  if (stepperX.distanceToGo() == 0)
  {
    // Random change to speed, position and acceleration
    // Make sure we dont get 0 speed or accelerations
    //delay(1000);
    stepperX.moveTo(n);
  }
}


void moveStepperY(int n){
  if (stepperY.distanceToGo() == 0)
  {
    // Random change to speed, position and acceleration
    // Make sure we dont get 0 speed or accelerations
    //delay(1000);
    stepperY.moveTo(n);
  }
}




