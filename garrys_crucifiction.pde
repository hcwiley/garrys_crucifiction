/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import java.awt.Robot;
import java.awt.event.*;

SimpleOpenNI  context;
boolean       autoCalib=true;

Robot robot;
int[] monitor = new int[2];

PFont fontA;

void setup()
{
  monitor[0] = 1680;
  monitor[1] = 1050;
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable skeleton generation for all joints
  context.enableUser();//SimpleOpenNI.SKEL_PROFILE_NONE);
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  fontA = loadFont("CourierNew36.vlw");
  textAlign(CENTER);
  textFont(fontA, 62);
  size(context.depthWidth(), context.depthHeight()+300); 
  try{
    robot = new Robot();
    centerMouse();
  }catch(Exception e){}
}

void centerMouse() {
  robot.mouseMove(monitor[0]/2,monitor[1]/2);
}

void turnLeft(){
  robot.mouseMove(monitor[0]/4,monitor[1]/2);
  delay(500);
  centerMouse();
}

void turnRight(){
  robot.mouseMove(monitor[0] - monitor[0]/4,monitor[1]/2);
  delay(500);
  centerMouse();
}

void moveLeft() throws Exception{
  robot.keyPress(KeyEvent.VK_A);
  robot.keyRelease(KeyEvent.VK_A);
}

void moveRight() throws Exception{
  robot.keyPress(KeyEvent.VK_D);
  robot.keyRelease(KeyEvent.VK_D);
}

void moveForward() throws Exception{
  robot.keyPress(KeyEvent.VK_W);
  robot.keyRelease(KeyEvent.VK_W);
}

void moveBackward() throws Exception{
  robot.keyPress(KeyEvent.VK_S);
  robot.keyRelease(KeyEvent.VK_S);
}

int buffer = 30;
int zBuffer = 1000;
int zThresh = 1200;
void draw()
{
  try{
    // update the cam
    context.update();
    
    // draw depthImageMap
    image(context.depthImage(),0,0);
    
    // draw the skeleton if it's available
    int[] userList = context.getUsers();
    for(int i=0;i<userList.length;i++)
    {
      PVector position = new PVector();
      int userId = userList[i];
      context.getCoM(userId, position);
      context.convertRealWorldToProjective(position, position);
      fill(255,0,0);
      ellipse(position.x, position.y, 10,10);
//      text(position.z+"", 400,200);
//      if(position.x > 0)
//        println(position.x);
      if( position.x > width/2 + buffer ){
        moveLeft();
      } else if( position.x < width/2 - buffer ){
        moveRight();
      }
      if( position.z - zThresh > zBuffer ){
        moveBackward();
      } else if( position.z - zThresh < zBuffer ){
        moveForward();
      }
      if(context.isTrackingSkeleton(userList[i])){
        PVector lShoulder = new PVector();
        PVector rShoulder = new PVector();
        float confidence;
        confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,lShoulder);
        confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rShoulder);
        println("\n--------------");
        println(lShoulder);
        println(rShoulder);
        println("--------------\n");
        text(lShoulder.z*10 - rShoulder.z*10+"", 400,200);
        if(lShoulder.z - rShoulder.z > 0.5){
          turnLeft();
        }
        else if(rShoulder.z - lShoulder.z > 0.5){
          turnRight();
        }
      }
    }
  } catch(Exception e){}
}
