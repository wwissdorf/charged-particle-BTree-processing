class BHNode {
  float charge;
  PVector centerOfCharge;
  float theta = 0.9;
  int numI;
  Ion ion;
  PVector min; 
  PVector max; 
  PVector center;
  ArrayList<BHNode> quadNodes;
  BHNode parent; 
  
  final static float epsilon0 =1.0;//= 8.854e-12;
  final static float elecConst = 4*PI*epsilon0; 

  
  
  BHNode(PVector min, PVector max, BHNode parent){
    charge = 0; 
    centerOfCharge = new PVector(0,0); 
    numI = 0; 
    this.min = min;
    this.max = max; 
    this.center = new PVector(min.x+(max.x-min.x)/2.0, min.y+(max.y-min.y)/2.0);
    quadNodes = new ArrayList<BHNode>();
    for (int i = 0; i < 4; i++) {
      quadNodes.add(null);
    }
  }
  
  boolean isRoot(){
    if (this.parent == null)
      return true;
    else
      return false; 
  }
  
  int getQuadrant(float x,float y){
      if (x<=center.x && y<=center.y)
      {
        return 0; //SW
      }
      else if (x<=center.x && y>=center.y)
      {
        return 1; //NW
      }
      else if (x>=center.x && y>=center.y)
      {
        return 2; //NE
      }
      else if (x>=center.x && y<=center.y)
      {
        return 3; //SE
      }
      else {
        return -1; //-1 means something wrong
      }
  }
  
  BHNode createQuadNode(int quadIndex){
      switch (quadIndex)
      {
        case 0: return new BHNode(min, center, this);
        case 1: return new BHNode(new PVector(min.x, center.y),
                                 new PVector(center.x, max.y),
                                 this);
        case 2: return new BHNode(center, max, this);
        case 3: return new BHNode(new PVector(center.x, min.y),
                                 new PVector(max.x, center.y),
                                 this);
        default: return null;
      }
      
  }
  
  void insert(Ion ion){
    if (numI > 1){
      int quad = getQuadrant(ion.location.x,ion.location.y);
      if (quadNodes.get(quad) == null){
        quadNodes.set(quad, createQuadNode(quad));
      }
      quadNodes.get(quad).insert(ion);
    }
    else if (numI == 1){
      Ion i2 = this.ion;
      Ion i1 = ion;
      if ( (i1.location.x == i2.location.x) && (i1.location.y == i2.location.y) ) //two bodys at the exact same position: put the second to the renegade vector
      {
        //s_renegades.push_back(newParticle);
        
      }
      else{
        // There is already a particle
        // subdivide the node and relocate that particle
        int eQuad = getQuadrant(i2.location.x, i2.location.y);
        if (quadNodes.get(eQuad)==null){
          quadNodes.set(eQuad,createQuadNode(eQuad));
        }
        quadNodes.get(eQuad).insert(i2);
        this.ion = null;

        eQuad = getQuadrant(ion.location.x, ion.location.y);
        if (quadNodes.get(eQuad)==null){
          quadNodes.set(eQuad,createQuadNode(eQuad));
        }
        quadNodes.get(eQuad).insert(ion);
      }
    }
    else if (numI == 0){
      this.ion = ion; 
    }
    numI++;
    
  }
  
  void computeChargeDistribution(){
    if (numI == 1){
      centerOfCharge = ion.location.copy();
      charge = ion.charge;
    }
    else {
      for (BHNode node : quadNodes) {
        if (node != null){
          node.computeChargeDistribution();
          charge += node.charge;
          centerOfCharge.x += node.charge * node.centerOfCharge.x;
          centerOfCharge.y += node.charge * node.centerOfCharge.y;
        }
      }
      if (charge != 0){
        centerOfCharge.x /= charge;
        centerOfCharge.y /= charge;
      }
      else {
        centerOfCharge.x = center.x;
        centerOfCharge.y = center.y;
      }
    }
  }
  
  PVector calculateEField(PVector r1, PVector r2, float charge2){
      float d = PVector.dist(r1, r2);
      PVector E;
      if (d>0){
        PVector r21 = PVector.sub(r1,r2);
        float d_pow3 = pow(d,3);
        E = new PVector(
          charge2/elecConst * r21.x / d_pow3,
          charge2/elecConst * r21.y / d_pow3);          
      }
      else{
        E = new PVector(0,0);
      }
      return(E);
  }
  
  PVector calculateEFieldFromTree(Ion targetIon){
    PVector eField;
    if (numI == 1){
      eField = calculateEField(targetIon.location,ion.location,ion.charge);
    }
    else {
      float r = PVector.sub(targetIon.location,centerOfCharge).mag();
      float d = max.x - min.x;
      
      if (d/r < theta){
        //print("ch "+charge+"\n");
        eField = calculateEField(targetIon.location,centerOfCharge,charge); 
      }
      else {
        eField = new PVector(0,0);
        for (BHNode node : quadNodes) {
          if (node != null){
            eField.add(node.calculateEFieldFromTree(targetIon));
          }
        }
      }
    }
    return eField;
  }
  
  void render(){
    //fill(10*charge,0,0,20);
    float alpha = 20;
    if (charge == 0.0){
      fill(255,0,0,alpha);
    }
    else if (charge > 0.0){
      fill(0,255,0,alpha);
      //noFill();
    }
    else{
      fill(0,0,255,alpha);
      //noFill();
    }
    
    //noFill();
    stroke(255,0,0);
    rect(scaleX(min.x),scaleY(min.y),scaleX(max.x-min.x),scaleY(max.y-min.y));
    ellipse(scaleX(centerOfCharge.x),scaleY(centerOfCharge.y),5,5);
    for (BHNode node : quadNodes) {
      if (node != null){
        node.render();
      }
    }
  }
  
  
  
  
}