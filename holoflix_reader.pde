PImage depthImg, rgbImg;
PGraphics depthBuffer, rgbBuffer; 
PGraphics depthGfx, rgbGfx;
boolean debug = false;
boolean ruttetra = true;

void setup() {
  size(512, 848, P2D);
  setupMoviePlayer("12876458_568439199999797_1099287423_n.mp4");//"IHBH2323.MOV");
  depthImg = createImage(640, 480, RGB);
  depthBuffer = createGraphics(640, 480, P2D);
  rgbBuffer = createGraphics(640, 480, P2D);
  rgbImg = createImage(640, 480, RGB);
  depthGfx = createGraphics(512, 424, P2D);
  rgbGfx = createGraphics(512, 424, P2D);
  
  setupSyphon();
  setupShaders();
  
  tex.imageMode(CENTER);
  tex.rectMode(CENTER);
  tex.noStroke();
}

void draw() {
  background(0);
  
  
  if (ruttetra) {
    rgbImg = moviePlayer[0].movie.get();
    
    rgbBuffer.beginDraw();
    rgbBuffer.image(rgbImg, 0, 0, 640, 480);
    rgbBuffer.endDraw();
    
    depthBuffer.beginDraw();
    depthBuffer.image(rgbImg, 0, 0, 640, 480);
    depthBuffer.filter(GRAY);
    depthBuffer.endDraw();
    
    updateShaders();
    
    depthBuffer.beginDraw();
    depthBuffer.filter(shader_depth_color);
    depthBuffer.endDraw();
  } else {
    rgbImg = moviePlayer[0].movie.get(640, 120, 1280, 600);
    //depthImg = processDepthMap(moviePlayer[0].movie.get(0, 120, 640, 600));
    depthImg = moviePlayer[0].movie.get(0, 120, 640, 600);
    
    rgbBuffer.beginDraw();
    rgbBuffer.image(rgbImg, 0, 0);
    rgbBuffer.endDraw();
    
    depthBuffer.beginDraw();
    depthBuffer.image(depthImg, 0, 0);
    depthBuffer.endDraw();
    
    updateShaders();
    
    depthBuffer.beginDraw();
    depthBuffer.filter(shader_depth_color);
    depthBuffer.endDraw();
  }
  
  rgbGfx.beginDraw();
  rgbGfx.image(rgbBuffer, 0, 0);
  rgbGfx.endDraw();
  
  depthGfx.beginDraw();
  depthGfx.image(depthBuffer, 0, 0);
  depthGfx.endDraw();
  
  tex.beginDraw();
  tex.pushMatrix();
  tex.translate(width/2, height/4);
  tex.rotate(radians(90));
  if (debug) {
    tex.fill(255,0,0);
    tex.rect(0, 0, 424, 512);
  } else {
    tex.image(rgbGfx, 0, 0, 424, 512);
  }
  tex.popMatrix();
  
  tex.pushMatrix();
  tex.translate(width/2, height/2 + height/4);
  tex.rotate(radians(90));
  if (debug) {
    tex.fill(0,0,255);
    tex.rect(0, 0, 424, 512);
  } else {
    tex.image(depthGfx, 0, 0, 424, 512);
  }
  tex.popMatrix();
  tex.endDraw();
  
  updateSyphon();
  image(tex, 0, 0);
  
  //saveFrame("render/line-######.png");
}

void keyPressed() {
  if (key=='d') debug = !debug;
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 
// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 

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
