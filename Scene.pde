class Scene
{
  ArrayList<Particle> scene = new ArrayList<Particle>();
  
  final float g = 15;
  final float DAMP = 1;
  final float TSTEP = 0.05;
  final float h = 0.2;
  final float SPRING = 10;
  final float VISC = 500;
  final float PDAMP = 5;
  
  void simulate()
  {
    for(Particle p : scene)
    {
      //initialize accelerations
      p.accel[0] = p.accel[1] = p.accel[2] = 0;

      //calculate density
      float dNew = 0;

      for(Particle q : scene)
      {
        PVector ppn = new PVector(p.pos[0], p.pos[1], p.pos[2]);
        PVector qpn = new PVector(q.pos[0], q.pos[1], q.pos[2]);

        ppn.mult(0.0033);
        qpn.mult(0.0033);
        
        PVector pd = ppn.sub(qpn);
                      
        dNew += q.mass*poly6(pd, h);
        
      }
      //calculate pressure from new density
      p.pressure = SPRING*(dNew - p.density);

      p.density  = dNew;
      
      p.temp = p.density/10;
      //add gravitational force
      p.accel[1] += p.density*g;
    }
    
    //compute pressure forces, viscous forces
    
    for(Particle p : scene)
    {
      float[] pf = {0,0,0};
      float[] vf = {0,0,0};
      float[] rf = {0,0,0};
      
      for(Particle q : scene)
      {
        PVector ppn = new PVector(p.pos[0], p.pos[1], p.pos[2]);
        PVector qpn = new PVector(q.pos[0], q.pos[1], q.pos[2]);

        ppn.mult(0.0033);
        qpn.mult(0.0033);
        
        PVector pd = ppn.sub(qpn);
        
        float[] grad = spiky(pd, h);
        pf[0] -= q.mass*(p.pressure*p.pressure/(p.density*p.density) + q.pressure*q.pressure/(q.density*q.density))*grad[0];
        pf[1] -= q.mass*(p.pressure*p.pressure/(p.density*p.density) + q.pressure*q.pressure/(q.density*q.density))*grad[1];
        pf[2] -= q.mass*(p.pressure*p.pressure/(p.density*p.density) + q.pressure*q.pressure/(q.density*q.density))*grad[2];
        
      }
      vf[0] *= VISC;
      vf[1] *= VISC;
      vf[2] *= VISC;
      
      p.accel[0] += pf[0] + vf[0] - p.vel[0]*PDAMP;
      p.accel[1] += pf[1] + vf[1] - p.vel[1]*PDAMP;
      p.accel[2] += pf[2] + vf[2] - p.vel[2]*PDAMP;
    }  
    
    for(Particle p : scene)
    {
      //p.temp = 140;
      //calculate final accelerations
      p.accel[0] /= p.density;
      p.accel[1] /= p.density;
      p.accel[2] /= p.density;
      //update positions, leapfrog
      p.pos[0] += TSTEP*(p.vel[0] + p.pAccel[0]*TSTEP/2);
      p.pos[1] += TSTEP*(p.vel[1] + p.pAccel[1]*TSTEP/2);
      p.pos[2] += TSTEP*(p.vel[2] + p.pAccel[2]*TSTEP/2);
      //update velocities, use leapfrog integration
      p.vel[0] += TSTEP*(p.accel[0] + p.pAccel[0])/2;
      p.vel[1] += TSTEP*(p.accel[1] + p.pAccel[1])/2;
      p.vel[2] += TSTEP*(p.accel[2] + p.pAccel[2])/2;
      //apply boundary forces
      
      for(int i =0; i < bdy.getChildCount(); i++)
      {
         PVector a = bdy.getChild(i).getVertex(0),
                 b = bdy.getChild(i).getVertex(1),
                 c = bdy.getChild(i).getVertex(2);
                          
         PVector ppv = new PVector(p.pos[0], p.pos[1], p.pos[2]);

         if(tri_sphere_ix(a,b,c,ppv))
         {
            PVector norm = (b.sub(a).cross(c.sub(a))).normalize();

            float pt2pln = ppv.sub(a).dot(norm);//distance to the plane through a,b,c
            PVector testDir = a.add(norm);
            float testMag = testDir.sub(a).dot(norm);
            if(!((pt2pln > 0 && testMag > 0) || (testMag < 0 && pt2pln < 0)))
            {//normal points in opposite direction of P
              norm.mult(-1);
            }
             
            float dn = norm.x*p.vel[0] + norm.y*p.vel[1] + norm.z*p.vel[2];
             
            p.vel[0] -= 2*dn*norm.x;
            p.vel[1] -= 2*dn*norm.y;
            p.vel[2] -= 2*dn*norm.z;
  
            p.pos[0] += p.vel[0]*TSTEP;
            p.pos[1] += p.vel[1]*TSTEP;
            p.pos[2] += p.vel[2]*TSTEP;
  
            p.vel[0] *= DAMP;
            p.vel[1] *= DAMP;
            p.vel[2] *= DAMP;
         }
      } 
      p.pAccel[0] = p.accel[0];
      p.pAccel[1] = p.accel[1];
      p.pAccel[2] = p.accel[2];
    }      
  }
  
  void rotate(float xr, float yr, float zr)
  {
    for(Particle p : scene)
    {
      p.rotateY(xr/100);
      p.rotateX(-yr/100);
      p.rotateZ(-zr/100);
    }
  }
  
  void draw()
  {
    for(Particle p : scene)
    {
      p.draw();
    }
  }
}

//http://realtimecollisiondetection.net/blog/?p=103
boolean tri_sphere_ix(PVector a, PVector b, PVector c, PVector p)
{
  float r = 35;

  a.sub(p);
  b.sub(p);
  c.sub(p);
  
  float rr = r*r;
  PVector v = PVector.sub(b,a).cross(PVector.sub(c,a));
  float d = a.dot(v);
  float e0 = v.dot(v);

  boolean sep1 = d * d > rr * e0;

  float aa = a.dot(a);
  float ab = a.dot(b);
  float ac = a.dot(c);
  
  float bb = b.dot(b);
  float bc = b.dot(c);
  float cc = c.dot(c);
  
  boolean sep2 = (aa > rr) && (ab > aa) && (ac > aa);
  boolean sep3 = (bb > rr) && (ab > bb) && (bc > bb);
  boolean sep4 = (cc > rr) && (ac > cc) && (bc > cc);

  PVector AB =  PVector.sub(b,a);
  PVector BC = PVector.sub(c,b);
  PVector CA = PVector.sub(a,c);

  float d1 = ab - aa;
  float d2 = bc - bb;
  float d3 = ac - cc;
  
  float e1 = AB.dot(AB);
  float e2 = BC.dot(BC);
  float e3 = CA.dot(CA);
  
  PVector Q1 = PVector.mult(a,e1).sub(PVector.mult(AB, d1));
  PVector Q2 = PVector.mult(b,e2).sub(PVector.mult(BC, d2));
  PVector Q3 = PVector.mult(c,e3).sub(PVector.mult(CA,d3));
  
  PVector QC = PVector.sub(PVector.mult(c,e1), Q1);
  PVector QA = PVector.sub(PVector.mult(a,e2), Q2);
  PVector QB = PVector.sub(PVector.mult(b,e3), Q3);
  
  boolean sep5 = (Q1.dot(Q1) > rr * e1 * e1) && (Q1.dot(QC) > 0);
  boolean sep6 = (Q2.dot(Q2) > rr * e2 * e2) && (Q2.dot(QA) > 0);
  boolean sep7 = (Q3.dot(Q3) > rr * e3 * e3) && (Q3.dot(QB) > 0);
  
  return (!(sep1 || sep2 || sep3 || sep4 || sep5 || sep6 || sep7));
}