
//A fluid simulation based on the smoothed particle hydrodynamics method.

//Resources used:
//https://www.cs.cornell.edu/~bindel/class/cs5220-f11/code/sph-derive.pdf
//https://software.intel.com/en-us/articles/fluid-simulation-for-video-games-part-15
//http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.2.7720&rep=rep1&type=pdf

import java.util.*;

final int RESOLUTION = 5;
final float e = 2.71828182845; 
PShape bdy;
float mx, my;

Scene test = new Scene();

void setup()
{
  background(0);
  size(1024,768, P3D);
 // Random rand = new Random();
  bdy = loadShape("bdy.obj");
  bdy.setFill(color(255,255,250));
  for(int i= 0; i < RESOLUTION; i++)
  {
   for(int j = 0; j < RESOLUTION; j++)
   {
     for(int k =0; k < RESOLUTION; k++)
     {
        test.scene.add(new Particle(i*60,j*60-500, k*60 - 400));
     }
    }
  }
  noStroke();
  sphereDetail(6);
  mx = mouseX;
  my = mouseY;    
}
float tx = 0, ty = 0;
float rtx = 0, rty = 0;

void draw()
{
  background(255);

  translate(width/2 + rtx, height/2, -420 + rty);
  rotateX(-ty);
  rotateY(tx);
  lights();
   shape(bdy,0,0);
  float dmx = mouseX - mx, dmy = mouseY - my;
  
  //bdy.rotateX(dmy/100);
  //bdy.rotateY(-dmx/100);
  
  //tx += dmx/100;
  //ty += dmy/100;
  
  mx = mouseX;
  my = mouseY;
  if(keyPressed)
  {
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
  }
  if(keyPressed && key == ' ')
  {
    test.simulate();
 }
 // test.rotate(dmx,dmy,0);
  test.draw();

  //saveFrame("drop6-######.jpg");
  translate(-width/2, -height/2, 420);

}

float ker(float[] r, float h) // f : R^3 -> R
{
  float x = -4*(r[0]*r[0] + r[1]*r[1] + r[2]*r[2])/(h*h);
  return pow(e,x);
}

float wpoly6(float[] r, float h) // f : R^3 -> R
{
  float d2 = r[0]*r[0] + r[1]*r[1] + r[2]*r[2];
  if(d2 > h)
    return 0;
  else
    return 315*(h*h - d2)*(h*h - d2)*(h*h - d2)/(64*PI*pow(h,2));
}

float[] kerg(float[] r, float h) // f : R^3 -> R^3
{
  float x = -4*(r[0]*r[0] + r[1]*r[1] + r[2]*r[2])/(h*h);
  
  float[] grad = {-8*r[0]*pow(e,x)/(h*h),
                  -8*r[1]*pow(e,x)/(h*h),
                  -8*r[2]*pow(e,x)/(h*h)};
    
  return grad;
}
float[] spiky(float[] r, float h) // f : R^3 -> R^3
{
  float x = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);
  float denom = PI*x;
  
  float[] grad = {-15*r[0]/denom,
                  -15*r[1]/denom,
                  -15*r[2]/denom};
             
  return grad;
}

float laplace(float[] r, float h)
{
  float x = r[0]*r[0] + r[1]*r[1] + r[2]*r[2];
  return 8*pow(2,-4*x/(h*h)) * (8*x - 3*h*h)/(h*h*h*h);
}

void keyPressed()
{
  //if(key == 'a')
  //{
  //  for(int i= 0; i < RESOLUTION; i++)
  //{
  // for(int j = 0; j < RESOLUTION; j++)
  // {
  //   for(int k =0; k < RESOLUTION; k++)
  //   {
  //      test.scene.add(new Particle(i*60 - 300,j*60 - 300,k*60 - 300));
  //   }
  //  }
  //}
  //}
}