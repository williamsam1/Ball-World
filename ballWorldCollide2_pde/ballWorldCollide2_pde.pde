ArrayList<Ball> world = new ArrayList<Ball>();
int col = -1;
boolean click = false;
float xi;
float yi;
float dx;
float dy;
final float MAXV = 150;
final float MAXRADIUS = 30;
final float MINRADIUS = 15;
final float GRAVITY = 5;
final float FRICTION = 0.03;
final float BOUNCE = 0.85;
Ball ball;
Ball ball2;



void setup()
{
  textSize(32);
  size(3*displayWidth / 5, 3*displayHeight / 5);
  background(0);
  frameRate(30);
  colorMode(HSB, 10);
  if (frame != null)
    frame.setResizable(true);

}

void draw()
{
  background(0);
  stroke(255,255,255);
  if (click && (dx != 0 || dy != 0))
  line(xi, yi, mouseX, mouseY);
  
  
  for (Ball ball : world)
  {
    ball.move();
    ball.display();
  }
  
}

void mousePressed()
{
  click = true;
  xi = mouseX;
  yi = mouseY;
  
}

void mouseReleased()
{
  click = false;
  col++;
  if (col > 10)
  col = 1;
  world.add(new Ball(yi, xi, -1*MAXV*dy/height, -1*MAXV*dx/width, (MAXRADIUS - MINRADIUS) * (float)Math.random() + MINRADIUS, GRAVITY, FRICTION, BOUNCE, color(col, 8, 10), 1));
}

void mouseDragged()
{
  if (click)
  {
    dx = mouseX - xi;
    dy = mouseY  - yi;
    line(xi, yi, mouseX, mouseY);
  }
    
  
}


public class Ball 
{
 PVector pos;
 PVector vel;
 float gravity;
 color colour;
 float radius;
 float bounce;
 float friction;
 float m;

 Ball(float yi, float xi, float yveli, float xveli, float rad, float grav, float fric, float bou, color ballColor, float mass)
 {
   pos = new PVector(xi, yi);
   radius = rad;
   gravity = grav;
   bounce = bou;
   colour = ballColor;
   vel = new PVector(xveli, yveli);
   friction = fric;
   m = mass;
 }

void move()
  {
   resolveCollisions();
   
   vel.y -= vel.y*friction - gravity;
   pos.y += vel.y;

   vel.x -= vel.x*friction;
   pos.x += vel.x;  
   
   
   
   checkEdges();
    
     
 }
 
 void resolveCollisions()
 {
 for (Ball ball : world)
   {
     if (!equals(ball) && colliding(ball))
       checkCollision(ball);
   }
 }
 
 void checkEdges()
 {
   if (pos.y + radius  > height)
   {
    pos.y = height - radius ;
    vel.y = -1 * bounce * vel.y;
   } 
   
   if (pos.x + radius  > width)
   {
    pos.x = width - radius ;
    vel.x = -1 * bounce * vel.x;
   } 
   
   if (pos.x - radius  < 0)
   {
    pos.x = radius ;
    vel.x = -1 * bounce * vel.x;
   }
   
 }
 
 void checkCollision(Ball ball) 
 {
   PVector collision = PVector.sub(pos,ball.pos);
   float distance = collision.mag();
   if (distance == 0)
   {
     collision = new PVector(1, 0);
     distance = 1;
   }
   
   collision.div(distance);
   float aci = PVector.dot(vel, collision);
   float bci = PVector.dot(ball.vel, collision);
   
   float acf = bci;
   float bcf = aci;
   
   vel.add(PVector.mult(collision, acf - aci));
   ball.vel.add(PVector.mult(collision, bcf - bci));
   
   
  }

boolean colliding(Ball ball)
{
  return (pos.dist(ball.pos) < radius + ball.radius);
}


void display()
{
  noStroke();
  fill(colour);
  if (pos.y + radius > 0)
  ellipse(pos.x, pos.y, 2*radius, 2*radius);
  else
  rect(pos.x, 0, radius, radius / 4);
}

}



