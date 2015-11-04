IonSystem ionSystem;
final int width = 640;
final int height = 640;
final PVector worldCenter = new PVector(width/2,height/2);
PVector viewBoxCenter = worldCenter;//PVector.sub(worldCenter,new PVector(120,120));
float viewBoxSize = 200;
float boxSize = 100;
PVector renderWindowMin = new PVector(viewBoxCenter.x-viewBoxSize,viewBoxCenter.y-viewBoxSize);
PVector renderWindowMax = new PVector(viewBoxCenter.x+viewBoxSize,viewBoxCenter.y+viewBoxSize);
float sX = width/ (renderWindowMax.x - renderWindowMin.x);
float sY = height/(renderWindowMax.y - renderWindowMin.y);
int step =0;
long startTime;
long endTime;
double duration;

ArrayList<Ion> ions;
int nIons= 100000;

float scaleX(float x){
  return((x- renderWindowMin.x)*sX);
}

float scaleY(float y){
  return((y- renderWindowMin.y)*sY);
}

void settings() {
  size(width, height);
}

void setup() {
  pixelDensity(2);
  frameRate(25);
  ionSystem = new IonSystem(nIons,1,0.01);  
}

long runTest(BHTree tree,int nIons){
  tree.reset(); 
  Ion targetIon = new Ion(new PVector(2.1,3.0));
  tree.insertIon(targetIon);
  long totalDuration=0;
  long startTime = System.nanoTime();
  for (int i=0;i<nIons;i++){
    tree.insertIon(new Ion(new PVector(2.0,i*1/(nIons*2.0)+0.1)));
  }
  long endTime = System.nanoTime();
  long duration = (endTime - startTime);
  totalDuration+=duration;
  println("insert particle duration:"+duration/1e9+" s for "+nIons+" ions");  
  
  startTime = System.nanoTime();
  tree.computeChargeDistribution();
  endTime = System.nanoTime();
  duration = (endTime - startTime);
  totalDuration+=duration;
  println("charge distribution duration:"+duration/1e9+" s for "+nIons+" ions");
  
  startTime = System.nanoTime();
  PVector EField= new PVector();
  for (int i=0;i<nIons;i++){
    EField = tree.calculateEFieldFromTree(targetIon);
  }  
  endTime = System.nanoTime();
  duration = (endTime - startTime);
  totalDuration+=duration;
  println("efield calculation:"+duration/1e9+" s for "+nIons+" ions");
  println(EField);
  
  return totalDuration;
}

float testRunRepeated(BHTree tree,int nIons){
  int nRuns = 6;
  float tElapsed = 0.0;
  for (int i=0; i<nRuns;i++){ 
    tElapsed += runTest(tree,nIons);
  }
  return (tElapsed/6);
}

void testRunScaled(BHTree tree){
  int nIons[] = {10000,50000,100000,250000,500000,1000000};
  double result[] = new double[6];
  for (int i=0;i<nIons.length;i++){
    result[i] = testRunRepeated(tree,nIons[i])/1e9;
  }
  
  println(result);
}

void draw() {
  background(50);
  startTime = System.nanoTime();
  ionSystem.run();
  endTime = System.nanoTime();
  duration = (endTime - startTime)/1e9;
  println("step "+step+" duration "+duration); 
  step++;

  //saveFrame("frames/####.png");
}