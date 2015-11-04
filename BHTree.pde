class BHTree{
  BHNode root; 
  
  BHTree(){

  }
  
  
  void reset(){
    PVector min = new PVector(0,0);
    PVector max = new PVector(width,height);
    root = new BHNode(min, max, null);
  }
  
  void insertIons(IonSystem ionSystem){
    reset();
    for (Ion ion : ionSystem.ions) {
      root.insert(ion);
    }
  }
  
  void insertIon(Ion ion){
    root.insert(ion);
  }
  
  void computeChargeDistribution(){
    root.computeChargeDistribution();
  }
  
  PVector calculateEFieldFromTree(Ion targetIon){
    return (root.calculateEFieldFromTree(targetIon));  
  }
  
  void render(){
    //root.render();
  }
}