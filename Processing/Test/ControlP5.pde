import controlP5.*;

ControlP5 cp5;
float max_X;
float max_Y;
boolean showMyCP5 = true;

void setupCP5(){
  
  
  cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  max_X = max_Y = 2200;
  cp5.addSlider("max_X")
     .setSize(10,100)
     .setPosition(width-100,10)
     .setRange(1000,2500.f)
     .setValue(2200)
     .setColorLabel(color(0,0,0))
     .setColorValueLabel(color(0,0,0))
     ;
     
     
  cp5.addSlider("max_Y")
     .setSize(10,100)
     .setPosition(width-50,10)
     .setRange(1000,2500.f)
     .setValue(2200)
     .setColorLabel(color(0,0,0))
     .setColorValueLabel(color(0,0,0))
     ;
     
     
  //cp5.loadProperties(("/data/plotter_max.properties"));
  
  cp5.hide();
}


void keyPressed() {
  
  if (key=='s') {
    cp5.saveProperties(("/data/plotter_max.properties"));
  } 
  else if (key=='l') {
    cp5.loadProperties(("/data/plotter_max.properties"));
  }
  
  if(keyCode == ENTER){
    showMyCP5 =! showMyCP5;
    
    if(showMyCP5)cp5.show();
    else cp5.hide();
  }
  
  if(keyCode == RIGHT){
    manualX+=1;
  }
  
  if(keyCode == LEFT){
     manualX-=1;
  }
  
  if(keyCode == UP){
     manualY-=1;
  }
  
  if(keyCode == DOWN){
    manualY+=1;
  }
}

