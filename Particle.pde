class Particle
{
  float pos[] = new float[3];
  float vel[] = new float[3];
  float accel[] = new float[3];
  float pAccel[] = new float[3];
  float pf[] = new float[3];
  float mass, density, pressure;
  float temp;
  
  public Particle(float _x, float _y, float _z)
  {
    pos[0] = _x;
    pos[1] = _y;
    pos[2] = _z;
    vel[0] = vel[1] = vel[2] = 0;
    accel[0] = accel[1] = accel[2] = 0;
    pAccel[0] = pAccel[1] = pAccel[2] = 0;
    temp = 100;
    mass = 1;
    density = 4;
    pressure = 10;
  }
  
  void draw()
  {    
    pushMatrix();
    translate(pos[0],pos[1],pos[2]);
    fill(0,0,temp);
    sphere(30);
    popMatrix();
  }
  
  void rotateY(float theta)
  {
    float cost = cos(theta), sint = sin(theta);
    float xi =pos[0];
    pos[0] = pos[0]*cost+pos[2]*sint;
    pos[2] = -xi*sint+pos[2]*cost;
  }
   void rotateZ(float theta)
  {
    float cost = cos(theta), sint = sin(theta);
    float xi = pos[0];
    pos[0] =  pos[0]*cost-pos[1]*sint;
    pos[1] = xi*sint+pos[1]*cost;
  }
  void rotateX(float theta)
  {
    float cost = cos(theta), sint = sin(theta);
    float yi =pos[1];
    pos[1] = pos[1]*cost-pos[2]*sint;
    pos[2] = yi*sint+pos[2]*cost;
  }
}