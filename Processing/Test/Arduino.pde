import processing.serial.*;

Serial port;  // Create object from Serial class

public static final char TAGX  = 'X';
public static final char TAGY  = 'Y';
public static final char TAGS = 'S';
public static final char TAGH = 'H';
public static final char TAGC = 'C';

boolean sending = false;
void ardu_setup(){
 try{  
   port = new Serial(this, "/dev/cu.usbmodemfd131", 57600);
 }catch(Exception e){
   port = new Serial(this,port.list()[0], 57600);
 }
 port.bufferUntil('\n');
  
}

void sendMessage(char tag, int value){
  if(readyToGo){
    try{
      sending = true;
      port.write(tag);
      char c = (char)(value / 256); // msb
      port.write(c);
      c = (char)(value & 0xff);  // lsb
      port.write(c); 
      sending = false;
    }catch(Exception e){
    
    }
    
  }
  
}

void serialEvent(Serial myPort) {
  String input = myPort.readString();
  input = input.replaceAll("\\s","");
  if(input != null)println(input);
  
  
  if(input.contains("done") ){
   readyToGo = true;
   totalX = 500;
   totalY = 500;
   sendMessage(TAGY,(int)totalX);
   sendMessage(TAGX,(int)totalY);
  }
  
  if(input.equals("reset_done") ){
    resetAll();
    readyToGo = true;
  }
}
