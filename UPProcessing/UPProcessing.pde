/*
  
  Ultrasonic Pong
  Thijs van Beers, 2016
  
*/
//Creating serial port
import processing.serial.*;
Serial port;

//Creating font
PFont font;

//Scores, positions and velocities
int scoreR,scoreL;
float lPaddleY, rPaddleY, ballX, ballY;
float lPaddleV, rPaddleV, ballXV = 2, ballYV;

//PID controller variables and PID values
float lPaddleS, rPaddleS, lPaddleE, rPaddleE, lPaddlePe, rPaddlePe, lPaddleTi, rPaddleTi;
final float P = 0.2, I = 0.1, D = 0.05;//I'm not great at tuning PID controllers, but I'm trying!

void setup(){
  //You can use fullscreen or any size you want
  //fullScreen();
  size(1000,700);
  fill(255);
  stroke(255);
  rectMode(CENTER);
  
  //Setting font
  font = createFont("meek.ttf",30);//Meek font by Nirmal Biswas (http://www.1001freefonts.com/meek.font)
  textFont(font);
  
  //Opening serial port
  port = new Serial(this, Serial.list()[0], 115200);
  port.bufferUntil('\n');
  
  //Starting positions
  lPaddleY = height/2;
  rPaddleY = height/2;
  ballX = width/2;
  ballY = height/2;
  
}

void draw(){
  //Field, scores and title
  background(0);
  line(0,50,width,50);
  line(0,height-50,width,height-50);
  for(int i=50; i!=height-50; i+=10){
    line(width/2,i,width/2,i+5);
  }
  textAlign(LEFT);
  text(scoreL, 50, 40);
  textAlign(RIGHT);
  text(scoreR, width-50, 40);
  textAlign(CENTER);
  text("Ultrasonic Pong",width/2,height-10);
  
  //Paddle endstops
  if(lPaddleS < 100){
    lPaddleS = 100;
  }
  else if(lPaddleS > height-100){
    lPaddleS = height-100;
  }
  if(rPaddleS < 100){
    rPaddleS = 100;
  }
  else if(rPaddleS > height-100){
    rPaddleS = height-100;
  }
  
  //Drawing and moving the paddles and ball
  rect(25, lPaddleY, 10, 100);
  rect(width-25, rPaddleY, 10, 100);
  rect(ballX, ballY, 10, 10);
  
  lPaddleY += lPaddleV;
  rPaddleY += rPaddleV;
  ballX += ballXV;
  ballY += ballYV;
  
  //Bouncing and scoring
  if(ballX < 30 && ballX > 25 && ballY >= lPaddleY-50 && ballY <= lPaddleY+50){
    ballX = 30;
    ballXV = ballXV*-1;
    ballYV += lPaddleV;
  }
  if(ballX > width-30 && ballX < width-25 && ballY >= rPaddleY-50 && ballY <= rPaddleY+50){
    ballX = width-30;
    ballXV = ballXV*-1;
    ballYV += rPaddleV;
  }
  if(ballY <= 55 || ballY >= height-55){
    ballYV = ballYV*-1;
  }
  if(ballX < 0){
    ++scoreR;
    ballYV = 0;
    ballXV = ballXV*-1;
    ballX = width/2;
    ballY = height/2;
  }
  if(ballX > width){
    ++scoreL;
    ballYV = 0;
    ballXV = ballXV*-1;
    ballX = width/2;
    ballY = height/2;
  }
  
  //PID controller
  lPaddlePe = lPaddleE;
  rPaddlePe = rPaddleE;                                        //storing the previous error
  lPaddleE = lPaddleS - lPaddleY;
  rPaddleE = rPaddleS - rPaddleY;                              //measuring current error
  lPaddleTi += (lPaddlePe+lPaddleE)/2;
  rPaddleTi += (rPaddlePe+rPaddleE)/2;                         //storing total integral
  lPaddleV = P*lPaddleE + I*lPaddleTi + D*(lPaddleE-lPaddlePe);
  rPaddleV = P*rPaddleE + I*rPaddleTi + D*(rPaddleE-rPaddlePe);//PID sum
  
}

//Reading the Arduino
void serialEvent(Serial port){
  //Splitting the input into numbers
  String inString = port.readStringUntil('\n');
  float[] input = float(split(inString, ','));
  
  //input.length should always be 2, so when it's not it just ignores that input
  if(input.length == 2){
    //Movement range from 0 to 40 cm
    lPaddleS = map(input[0], 0, 40, height-100, 100);
    rPaddleS = map(input[1], 0, 40, height-100, 100);
  }
}

//Cheats
//Resetting score and ball position
void mousePressed(){
  ballX = width/2;
  ballY = height/2;
  ballYV = 0;
  scoreL = 0;
  scoreR = 0;
}

//Adjusting ball speed
void keyPressed(){
  if(key == CODED){
    if(keyCode == UP){
      if(ballXV == 0){
        ballXV = (ballX-width/2)/abs(ballX-width/2);
      }
      else{
        ballXV = (abs(ballXV)+1) * (ballXV/abs(ballXV));
      }
    }
    else if(keyCode == DOWN){
       if(ballXV == 0){
         ballXV = -1*(ballX-width/2)/abs(ballX-width/2);
       }
       else{
        ballXV = (abs(ballXV)-1) * (ballXV/abs(ballXV));
       }
    }
  }
}