import de.voidplus.leapmotion.*;
import toxi.color.*;
import toxi.util.datatypes.*;
import java.util.Arrays;
import java.util.*;

LeapMotion leap;

PVector[][][] dp;
PGraphics pg, fg;
int speed = 0;
ColorTheme t;
ColorList colors;

ArrayList<runner> runners = new ArrayList<runner>();

void setup() {
  size(2500, 1200, OPENGL);
  background(255);
  pg = createGraphics(width, height, P2D);
  fg = createGraphics(width, height, P2D);
  pg.strokeCap(ROUND);
  makeColors();
  dp = new PVector[4][10][2];
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 10; j++) {
      for (int k = 0; k < 2; k++) {
        dp[i][j][k] = new PVector(0,0,0);
      }
    }
  }
  println(dp);
  pg.beginDraw();
  pg.fill(colors.getDarkest().toARGB());
  pg.noStroke();
  pg.rect(0, 0, width, height);
  pg.endDraw();
  leap = new LeapMotion(this).withGestures();
}

void draw() {
  background(255);
  // ...
  hint(DISABLE_DEPTH_TEST);
  image(pg, 0, 0);

  int fps = leap.getFrameRate();


  // ========= HANDS =========
  int color_index = 1;
  int hand_index = 0;
  for (Hand hand : leap.getHands ()) {


    // ----- BASICS -----

    int     hand_id          = hand.getId();
    PVector hand_position    = hand.getPosition();
    PVector hand_stabilized  = hand.getStabilizedPosition();
    PVector hand_direction   = hand.getDirection();
    PVector hand_dynamics    = hand.getDynamics();
    float   hand_roll        = hand.getRoll();
    float   hand_pitch       = hand.getPitch();
    float   hand_yaw         = hand.getYaw();
    boolean hand_is_left     = hand.isLeft();
    boolean hand_is_right    = hand.isRight();
    float   hand_grab        = hand.getGrabStrength();
    float   hand_pinch       = hand.getPinchStrength();
    float   hand_time        = hand.getTimeVisible();
    PVector sphere_position  = hand.getSpherePosition();
    float   sphere_radius    = hand.getSphereRadius();


    // ----- SPECIFIC FINGER -----

    Finger  finger_thumb     = hand.getThumb();
    // or                      hand.getFinger("thumb");
    // or                      hand.getFinger(0);

    Finger  finger_index     = hand.getIndexFinger();
    // or                      hand.getFinger("index");
    // or                      hand.getFinger(1);

    Finger  finger_middle    = hand.getMiddleFinger();
    // or                      hand.getFinger("middle");
    // or                      hand.getFinger(2);

    Finger  finger_ring      = hand.getRingFinger();
    // or                      hand.getFinger("ring");
    // or                      hand.getFinger(3);

    Finger  finger_pink      = hand.getPinkyFinger();
    // or                      hand.getFinger("pinky");
    // or                      hand.getFinger(4);        


    // ----- DRAWING -----

    hand.draw();
    // hand.drawSphere();


    // ========= ARM =========

    if (hand.hasArm()) {
      Arm     arm               = hand.getArm();
      float   arm_width         = arm.getWidth();
      PVector arm_wrist_pos     = arm.getWristPosition();
      PVector arm_elbow_pos     = arm.getElbowPosition();
    }


    // ========= FINGERS =========
    //
    int finger_ind = 0;
    for (Finger finger : hand.getFingers ()) {
      // Alternatives:
      // hand.getOutstrechtedFingers();
      // hand.getOutstrechtedFingersByAngle();

      // ----- BASICS -----

      int     finger_id         = finger.getId();
      PVector finger_position   = finger.getPosition();
      PVector finger_stabilized = finger.getStabilizedPosition();
      PVector finger_velocity   = finger.getVelocity();
      PVector finger_direction  = finger.getDirection();
      float   finger_time       = finger.getTimeVisible();


      // ----- SPECIFIC FINGER -----

      switch(finger.getType()) {
      case 0:
        //System.out.println(finger.getDistalBone().getNextJoint());
        //tp = finger.getDistalBone().getNextJoint();
        break;
      case 1:
        // System.out.println("index");
        //ip = finger.getDistalBone().getNextJoint();
        break;
      case 2:
        // System.out.println("middle");
        break;
      case 3:
        // System.out.println("ring");
        break;
      case 4:
        // System.out.println("pinky");
        break;
      }




      // ----- SPECIFIC BONE -----

      Bone    bone_distal       = finger.getDistalBone();
      // or                       finger.get("distal");
      // or                       finger.getBone(0);

      Bone    bone_intermediate = finger.getIntermediateBone();
      // or                       finger.get("intermediate");
      // or                       finger.getBone(1);

      Bone    bone_proximal     = finger.getProximalBone();
      // or                       finger.get("proximal");
      // or                       finger.getBone(2);

      Bone    bone_metacarpal   = finger.getMetacarpalBone();
      // or                       finger.get("metacarpal");
      // or                       finger.getBone(3);


      // ----- DRAWING -----

      dp[hand_index][finger_ind][1] = dp[hand_index][finger_ind][0];
      dp[hand_index][finger_ind][0] = bone_distal.getNextJoint();
      pg.beginDraw();
      pg.pushMatrix();
      //pg.translate(ip.x,ip.y,400 - 10 * ip.z);

      pg.noStroke();
      
      pg.stroke(colors.get(color_index).toARGB());
      PVector tp = dp[hand_index][finger_ind][0];
      PVector ip = dp[hand_index][finger_ind][1];
      float d = PVector.dist(tp,ip);
      pg.strokeWeight(max(2,min(20,d/5)));
      pg.strokeCap(ROUND);
      if (d < 90){
        pg.line(tp.x, tp.y, tp.z, ip.x + speed, ip.y, ip.z);
      }
      if (d > 90 && d < 120){
        for( int i = 0; i < 4; i++){
          runners.add(new runner(new PVector(ip.x,ip.y),PVector.lerp(new PVector((tp.x-ip.x),(tp.y-ip.y)), PVector.mult(PVector.random2D(), 20),0.5),colors.get(color_index).toARGB()));
        }
      }
      pg.popMatrix();
      pg.endDraw();
      // finger.draw(); // = drawLines()+drawJoints()
      // finger.drawLines();
      // finger.drawJoints();

      color_index++;
      finger_ind++;

      // ----- TOUCH EMULATION -----

      int     touch_zone        = finger.getTouchZone();
      float   touch_distance    = finger.getTouchDistance();

      /*switch(touch_zone) {
       case -1: // None
       break;
       case 0: // Hovering
       // println("Hovering (#"+finger_id+"): "+touch_distance);
       break;
       case 1: // Touching
       // println("Touching (#"+finger_id+")");
       break;
       }*/
    }

    /*if(PVector.dist(tp,ip) < 1){
     pg.beginDraw();
     pg.pushMatrix();
     pg.translate(ip.x,ip.y,500 - 20 * ip.z);
     pg.stroke(255,0,255);
     pg.sphere(3);
     pg.popMatrix();
     pg.endDraw();
     }*/
     
     //pg.endDraw();
     

    // ========= TOOLS =========

    for (Tool tool : hand.getTools ()) {


      // ----- BASICS -----

      int     tool_id           = tool.getId();
      PVector tool_position     = tool.getPosition();
      PVector tool_stabilized   = tool.getStabilizedPosition();
      PVector tool_velocity     = tool.getVelocity();
      PVector tool_direction    = tool.getDirection();
      float   tool_time         = tool.getTimeVisible();


      // ----- DRAWING -----

      // tool.draw();


      // ----- TOUCH EMULATION -----

      int     touch_zone        = tool.getTouchZone();
      float   touch_distance    = tool.getTouchDistance();

      switch(touch_zone) {
      case -1: // None
        break;
      case 0: // Hovering
        // println("Hovering (#"+tool_id+"): "+touch_distance);
        break;
      case 1: // Touching
        // println("Touching (#"+tool_id+")");
        break;
      }
    }
    hand_index++;
  }
  
  // END DRAW
  
  fg.beginDraw();
  fg.copy(pg,0,0,width,height,0,0,width,height);
  fg.endDraw();
  //pg.beginDraw();
  pg.beginDraw();
  pg.image(fg,speed,0,width,height);
  pg.stroke(colors.getDarkest().toARGB());
  pg.strokeWeight(5);
  pg.noFill();
  pg.rect(0,0,width,height);
  
  for ( runner r : runners){
    r.update();
    r.draw(pg);
  }
  
  Iterator<runner> it = runners.iterator();
  while (it.hasNext()) {
    if (it.next().scale <= 0) {
        it.remove();
        break;
        // If you know it's unique, you could `break;` here
    }
  }
  
  pg.endDraw();


  // ========= DEVICES =========

  for (Device device : leap.getDevices ()) {
    float device_horizontal_view_angle = device.getHorizontalViewAngle();
    float device_verical_view_angle = device.getVerticalViewAngle();
    float device_range = device.getRange();
  }
}

// ========= CALLBACKS =========

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
   println("Leap Motion Exit");
}

// ----- CIRCLE GESTURE -----

void leapOnCircleGesture(CircleGesture g, int state){
  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position_center  = g.getCenter();
  float   radius           = g.getRadius();
  float   progress         = g.getProgress();
  long    duration         = g.getDuration();
  float   duration_seconds = g.getDurationInSeconds();
  int     direction        = g.getDirection();

  switch(state){
    case 1:  // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      //makeColors();
      break;
  }
  
  switch(direction){
    case 0: // Anticlockwise/Left gesture
      break;
    case 1: // Clockwise/Right gesture
      break;
  }
}

void leapOnSwipeGesture(SwipeGesture g, int state){
  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector position         = g.getPosition();
  PVector position_start   = g.getStartPosition();
  PVector direction        = g.getDirection();
  float   speed            = g.getSpeed();
  long    duration         = g.getDuration();
  float   duration_seconds = g.getDurationInSeconds();

  switch(state){
    case 1:  // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      //makeColors();
      break;
  }
}

void keyPressed() {
  if (key == ' ') {
    makeColors();
  }
}

class runner{
   PVector pos;
   PVector vel;
   color col;
   float scale = 10;
   runner(PVector p, PVector v, color c){
    pos = p;
    vel = v;
    col = c;
   }
   
   void update(){
     pos = PVector.add(pos,vel);
     vel = PVector.lerp(vel,PVector.mult(PVector.random2D(),20),0.05);
     vel = PVector.lerp(vel,new PVector(0,0),0.02);
     scale -= 0.25;
   }
   void draw(PGraphics pic){
     if (scale > 0){
       pic.strokeWeight(scale);
       pic.stroke(col);
       pic.line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
     }
   }
}

void makeColors() {
  t = new ColorTheme("iter_01");
  t.addRange("soft ivory", 0.5);
  t.addRange("dark red", 0.02);
  t.addRange("intense goldenrod", 0.25);
  t.addRange("warm saddlebrown", 0.15);
  t.addRange("fresh teal", 0.4);
  t.addRange("fresh coral", 0.4);
  t.addRange("bright yellow", 0.05);
  colors = t.getColors(20);
  colors.sortByCriteria(AccessCriteria.LUMINANCE,false);
  colors.complement();
  pg.beginDraw();
  pg.fill(colors.getDarkest().toARGB());
  pg.noStroke();
  pg.rect(0, 0, width, height);
  pg.endDraw();
}

