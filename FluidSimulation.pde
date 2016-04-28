//A fluid simulation based on the smoothed particle hydrodynamics method.

//Main resources used:
//https://www.cs.cornell.edu/~bindel/class/cs5220-f11/code/sph-derive.pdf
//https://software.intel.com/en-us/articles/fluid-simulation-for-video-games-part-15
//http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.2.7720&rep=rep1&type=pdf

import java.util.*;

final int RESOLUTION = 6;
final float e = 2.71828182845; 
PShape bdy;   
float mx, my;

Scene test = new Scene();

void setup()
{
  //hint(DISABLE_DEPTH_TEST);
  background(0);
  size(1024,768, P3D);

  bdy = loadShape("bdy.obj");
  bdy.setFill(color(0,200,0));
  Random rand = new Random();
  for(int i= 0; i < RESOLUTION; i++)
  {
   for(int j = 0; j < RESOLUTION; j++)
   {
     for(int k =0; k < RESOLUTION; k++)
     {
        test.scene.add(new Particle(i*50 + 900,j*50-1500, k*50 + 1400));
     }
    }
  }
  noStroke();
  sphereDetail(6);
  mx = mouseX;
  my = mouseY;    
}
float tx = 0, ty = 0, tz = 0;
float rtx = 0, rty = 0;

void draw()
{
  background(255);

  translate(width/2 + rtx, tz+height/2, -1100 + rty);
  rotateX(-ty);
  rotateY(tx);
  lights();
   shape(bdy,0,0);
  float dmx = mouseX - mx, dmy = mouseY - my;
  
  mx = mouseX;
  my = mouseY;
  if(keyPressed)
  {
    if(key == '=')
    {
      test.PREST--;
    }
    if(keyCode == UP)
    {
      ty += 0.01;
    }
    else if(keyCode == DOWN)
    {   
      ty -= 0.01;
    }
    else if(keyCode == LEFT)
    {
      tx += 0.01;
    }
    else if(keyCode == RIGHT)
    {  
      tx -= 0.01;
    }
    if(key == 'w')
    {
      rty+=10;
    }
    if(key == 'a')
    {
      rtx+=10;
    }
    if(key == 's')
    {
      rty-=10; 
    }
    if(key == 'd')
    {
      rtx-=10;
    }    
    if(key == '-')
    {
      tz -= 10;
    }
    if(key == '=')    
      tz+=10;
  }
  if(keyPressed && key == ' ')
  {
    test.simulate();
  }
  test.draw();
  translate(-width/2, -height/2, 820);
}

float poly6(PVector r, float h) // f : R^3 -> R
{
  float d2 = r.x*r.x + r.y*r.y+ r.z*r.z;
    
  if(sqrt(d2) > h)
    return 0;
  else
    return pow(h*h-d2,3)*315/(64*PI*pow(h,9));
}

float[] spiky(PVector r, float h) // f : R^3 -> R^3
{
  float d = sqrt(r.x*r.x + r.y*r.y + r.z*r.z);
  float mul = 0;
  //println(d);
  
  if(d < h)
    mul = -45*(h-d)*(h-d)/(PI*pow(h,6));
  
  float[] grad = {mul*r.x,
                  mul*r.y,
                  mul*r.z};      
  return grad;
}

float laplace(float[] r, float h)
{
  float x = r[0]*r[0] + r[1]*r[1] + r[2]*r[2];
  return 8*pow(2,-4*x/(h*h)) * (8*x - 3*h*h)/(h*h*h*h);
}