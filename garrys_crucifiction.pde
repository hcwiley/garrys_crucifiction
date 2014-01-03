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

int yCenter;
void setup()
{
  monitor[0] = 1920;
  monitor[1] = 1200;
  yCenter = monitor[1]/2 + 240;
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
  size(context.depthWidth(), context.depthHeight()); 
  try{
    robot = new Robot();
//    centerMouse();
  }catch(Exception e){}
}

void myDelay(float del){
  float cur = millis();
  while(millis() - del < cur){}
  return;
}

void centerMouse() {
  robot.mouseMove(monitor[0]/2,yCenter);
}

void turn(float delta){
  if(delta < 0){
   robot.keyPress(KeyEvent.VK_LEFT);
   myDelay(abs(delta));
   robot.keyRelease(KeyEvent.VK_LEFT);
  } else {
    robot.keyPress(KeyEvent.VK_RIGHT);
    myDelay(abs(delta));
    robot.keyRelease(KeyEvent.VK_RIGHT);
  }
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
  robot.keyPress(KeyEvent.VK_SHIFT);
  robot.keyPress(KeyEvent.VK_W);
  robot.keyRelease(KeyEvent.VK_W);
  robot.keyRelease(KeyEvent.VK_SHIFT);
}

void moveBackward() throws Exception{
  robot.keyPress(KeyEvent.VK_SHIFT);
  robot.keyPress(KeyEvent.VK_S);
  robot.keyRelease(KeyEvent.VK_S);
  robot.keyRelease(KeyEvent.VK_SHIFT);
}

int buffer = 30;
int zBuffer = 100;
int zThresh = 1300;
void draw()
{
  try{
    // update the cam
    context.update();
    
    // draw depthImageMap
    context.depthImage();
    image(context.userImage(),0,0);
    
    // draw the skeleton if it's available
    int[] userList = context.getUsers();
    for(int i=0;i<userList.length;i++)
    {
      PVector position = new PVector();
      int userId = userList[i];
      if(context.isTrackingSkeleton(userList[i])){
        PVector lShoulder = new PVector();
        PVector rShoulder = new PVector();
        float confidence;
        PMatrix3D  orientation = new PMatrix3D();
        confidence = context.getJointOrientationSkeleton(userId,SimpleOpenNI.SKEL_TORSO,orientation);
        println("--------------");
        println(orientation.m00+ ",   \t" +  orientation.m01+ ",   \t" +  orientation.m02+ ",   \t" +  orientation.m03+ ",   \t" + "\n" +
orientation.m10+ ",   \t" +  orientation.m11+ ",   \t" +  orientation.m12+ ",   \t" +  orientation.m13+ ",   \t" + "\n" +
orientation.m20+ ",   \t" +  orientation.m21+ ",   \t" +  orientation.m22+ ",   \t" +  orientation.m23+ ",   \t" + "\n" +
orientation.m30+ ",   \t" +  orientation.m31+ ",   \t" +  orientation.m32+ ",   \t" +  orientation.m33
);
        println("--------------\n");
//        text(lShoulder.z - rShoulder.z+"", 400,200);
        float rotation = map(orientation.m02, -1.0, 1.0, -1.0, 1.0);
        if(abs(rotation) > 0.2){
          turn(rotation);
        }
      }
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
      text((int)position.z+"", 100,120);
      if( position.z > (zThresh + zBuffer) ){
        moveBackward();
      } else if( position.z < (zThresh - zBuffer) ){
        moveForward();
      }
    }
  } catch(Exception e){}
}
// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

