
class IonSystem {
  ArrayList<Ion> ions;
  BHTree bhTree; 
  int step;
  int renderRate;
  float dt; 
  float mean_E;
  
  IonSystem(int nIons,int renderRate,float base_dt){
    ions = new ArrayList<Ion>();
    float startBoxSize= boxSize * 0.5;
    
    PVector location;
    for (int i = 0; i < nIons; i++) {
      location = new PVector(worldCenter.x+random(startBoxSize)-startBoxSize/2, worldCenter.y+random(startBoxSize)-startBoxSize/2);
      ions.add(new Ion(location,1.0));
    }

    bhTree = new BHTree();
    step =0;
    this.renderRate = renderRate;
    this.dt = base_dt; 
  }
  
  void run(){
    
    //if (mean_E <= 0){
    //  mean_E = 200;
    //}
    //float dt = this.dt * 20/mean_E;
    this.run(this.dt);
    
  }
  
  void run(float dt){
    bhTree.reset();
    bhTree.insertIons(this);
    bhTree.computeChargeDistribution();
    float E=0;
    float buf = 0;
    int active =0;
    for (Ion ion : ions) {
      
      buf= ion.run(dt,bhTree.calculateEFieldFromTree(ion));
      if (buf >0){
        active++;
        E+=buf;
      }
      mean_E = E/active;
    }
    
    if (step % renderRate ==0){
      this.render();
    }
  }
  
  void render(){
    int active = 0; 
    for (Ion ion : ions) {
      ion.render();
      if (ion.state == 1){
        active++;
      }
    }
    noFill();
    stroke(200,90);
    rect(scaleX(worldCenter.x-boxSize),scaleY(worldCenter.y-boxSize),sX*2*boxSize,sY*2*boxSize);
    bhTree.render();
    textSize(32); 
    fill(0, 102, 153);
    text(active, 10, height-30);
  }
}