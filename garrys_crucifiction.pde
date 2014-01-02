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

void setup()
{
  monitor[0] = 1920;
  monitor[1] = 1200;
  context = new SimpleOpenNI(this);
   
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable skeleton generation for all joints
//  context.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(context.depthWidth(), context.depthHeight()); 
  try{
    robot = new Robot();
    centerMouse();
  }catch(Exception e){}
}

void centerMouse() {
  robot.mouseMove(monitor[0]/2,monitor[1]/2);
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
      fill(255,0,0);
      ellipse(position.x, position.y, 10,10);
      println(position.x);
    }
  } catch(Exception e){}
}
