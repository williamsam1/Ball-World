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
final float GRAVITY = 2;
final float FRICTION = 0.03;
final float BOUNCE = 0.85;
Ball ball;
Ball ball2;



void setup()
{
  size(600, 400);
  textSize(32);
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
  
  
  for (int i = 0; i < world.size(); i++)
  {
    ball = world.get(i);
    ball.move();
   for (int j = 0; j < world.size(); j++)
   {
     if (i != j)
     {
     ball2 = world.get(j);
     if (ball.colliding(ball2))
       ball.checkCollision(ball2);
     }
   }
  }
  
  for (Ball ball : world)
  {
    
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
   vel.y -= vel.y*friction - gravity;
   pos.y += vel.y;

   vel.x -= vel.x*friction;
   pos.x += vel.x;  
   
   checkEdges();
     
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
 
 void checkCollision(Ball other) {

    // get distances between the balls components
    PVector bVect = PVector.sub(other.pos, pos);

    // calculate magnitude of the vector separating the balls
    //float bVectMag = bVect.mag();

      // get angle of bVect
      float theta  = bVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
        };

        /* this ball's position is relative to the other
         so you can use the vector between them (bVect) as the 
         reference point in the rotation expressions.
         bTemp[0].position.x and bTemp[0].position.y will initialize
         automatically to 0.0, which is what you want
         since b[1] will rotate around b[0] */
        bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
      bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
        };

        vTemp[0].x  = cosine * vel.x + sine * vel.y;
      vTemp[0].y  = cosine * vel.y - sine * vel.x;
      vTemp[1].x  = cosine * other.vel.x + sine * other.vel.y;
      vTemp[1].y  = cosine * other.vel.y - sine * other.vel.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
        };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
        };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen position
      other.pos.x = pos.x + bFinal[1].x;
      other.pos.y = pos.y + bFinal[1].y;

      pos.add(bFinal[0]);

      // update velocities
      vel.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      vel.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.vel.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.vel.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    
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