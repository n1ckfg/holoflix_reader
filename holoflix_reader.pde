PImage depthImg, rgbImg;
PGraphics depthGfx, rgbGfx;
boolean debug = false;

void setup() {
  size(512, 848, P2D);
  setupMoviePlayer("IHBH2323.MOV");
  depthImg = createImage(640, 480, RGB);
  rgbImg = createImage(640, 480, RGB);
  depthGfx = createGraphics(512, 424, P2D);
  rgbGfx = createGraphics(512, 424, P2D);
  imageMode(CENTER);
  rectMode(CENTER);
  noStroke();
}

void draw() {
    background(0);
    
    rgbImg = moviePlayer[0].movie.get(640, 120, 1280, 600);
    depthImg = processDepthMap(moviePlayer[0].movie.get(0, 120, 640, 600));
    
    rgbGfx.beginDraw();
    rgbGfx.image(rgbImg, 0, 0);
    rgbGfx.endDraw();
    
    depthGfx.beginDraw();
    depthGfx.image(depthImg, 0, 0);
    depthGfx.endDraw();
    
    pushMatrix();
    translate(width/2, height/4);
    rotate(radians(90));
    if (debug) {
      fill(255,0,0);
      rect(0, 0, 424, 512);
    } else {
      image(rgbGfx, 0, 0, 424, 512);
    }
    popMatrix();
    
    pushMatrix();
    translate(width/2, height/2 + height/4);
    rotate(radians(90));
    if (debug) {
      fill(0,0,255);
      rect(0, 0, 424, 512);
    } else {
      image(depthGfx, 0, 0, 424, 512);
    }
    popMatrix();
    
    //saveFrame("render/line-######.png");
}

void keyPressed() {
  if (key=='d') debug = !debug;
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 

PImage processDepthMap(PImage _img) {
  _img.loadPixels();
  for (int i=0; i<_img.pixels.length; i++) {
    float d = red(_img.pixels[i]);
    //~
    float r = remap(d, 0, 85);
    float g = remap(d, 85, 170);
    float b = remap(d, 170, 255);
    //~
    float r2 = depthFilter2((((255-r)/170) * (255-g)), r, 85);
    float g2 = depthFilter2(r+b, r, 85); // OK
    //float b2 = (d/127) * (255-(g+b)); // OK
    float b2 = depthFilter2((255-(g+b)), r, 85); // OK
    //~
    color c =  color(r2,g2,b2);
    _img.pixels[i] = c;
  }
  _img.updatePixels();
  return _img;
}


float remap(float f, float begin, float end) {
  f = map(f, begin, end, 0, 255);
  return f;
}

float thresholdMin(float f, float cutoff) {
  if (f < cutoff) f = 0;
  return f;
}

float thresholdMax(float f, float cutoff) {
  if (f > cutoff) f = 0;
  return f;
}

float depthFilter1(float f1, float f2, float cutoff) {
  if (f2 < cutoff) f1 = f2;
  return f1;
}

float depthFilter2(float f1, float f2, float cutoff) {
  if (f1 > cutoff && f2 <= cutoff) f1 = f2;
  return f1;
}
