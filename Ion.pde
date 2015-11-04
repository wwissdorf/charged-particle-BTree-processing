class Ion {
  PVector location;
  float charge;
  float diffCoeff;
  float mobility;
  int state; 
  final static float elemCharge = 1.0;//1.6e-19;
  
  
  void init(){
    state = 1; //1 means "active", 0 means "stopped"
    charge = 1*elemCharge;
    mobility = 10.0; //2e-4;
    diffCoeff = 1.0;//5e-6;
  }
  
  Ion(){
    init();
    float startBoxSize= boxSize * 1.3;
    location = new PVector(worldCenter.x+random(startBoxSize)-startBoxSize/2, worldCenter.y+random(startBoxSize)-startBoxSize/2);
    this.setLocation(location);
  }
  
  Ion(float charge){
    this();
    this.charge = charge*elemCharge;
  }
  
  Ion(PVector loc){
    init();
    location = loc;
  }
  
  Ion(PVector loc,float charge){
    init();
    location = loc;
    this.charge = charge*elemCharge;
  }
  
  
  void setLocation(PVector loc){
    this.location = loc; 
  }
  
  
  void diffuse(float dt){
    float phi = random(2*PI);
    float r = sqrt(diffCoeff*dt);
    location.x += r*cos(phi);
    location.y += r*sin(phi);
  }
  
  void coulombRepulsionBruteForce(float dt,ArrayList<Ion> ions){
    PVector eField = new PVector(0,0);
    for (Ion other : ions) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) ) { //if d>0 == other != me
        PVector r21 = PVector.sub(location,other.location);
        float len_r21 = r21.mag();
        float len_r21_pow3 = pow(len_r21,3);
        PVector E = new PVector(
          other.charge * r21.x / len_r21_pow3,
          other.charge * r21.y / len_r21_pow3);
          
        eField.add(E);
      }
    }
    location.x += eField.x * mobility * dt;
    location.y += eField.y * mobility * dt;
  }
  
  void coulombRepulsion(float dt,PVector eField){
    eField.limit(100);
    //print(eField+" "+charge+" "+mobility+" "+dt+"\n");
    location.x += eField.x* charge * mobility * dt;
    location.y += eField.y* charge * mobility * dt;
  }
  
  void wallCollision(){
    if (
      location.x < worldCenter.x-boxSize ||
      location.x > worldCenter.x+boxSize ||
      location.y < worldCenter.y-boxSize ||
      location.y > worldCenter.y+boxSize)
      {
        state = 0;
        //print("state "+state+"\n");
      }
  }
   
  void render(){
    if (charge > 0){
      fill(250,0,0, 100);
    }
    else {
      fill(0,250,250, 100);
    }
    
    //stroke(255,20);
    noStroke();
    ellipse(scaleX(location.x),scaleY(location.y),2,2);
  }
  
  float run(float dt, PVector eField){
    if (state ==1){
      diffuse(dt);
      coulombRepulsion(dt,eField);
      wallCollision();
      //print(eField+" ");
      return(eField.mag());
    }      
    else{
      return(0);
    }
  }
}