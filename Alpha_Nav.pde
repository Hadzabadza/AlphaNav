import controlP5.*;
import java.io.File;

///////////////////////////////////////////////////////////////
//                    SETTINGS HERE                          //
String map_name = "Mep.png";
int node_radius = 10;
int node_min_mass = 32;
//                                                           //
///////////////////////////////////////////////////////////////

ControlP5 cp5;

MainMap origin;
FilterManager fb;
NodeManager nb;

//PImage map_origin;
//PVector origin.position;

boolean filters_loaded = false;
boolean nodes_built = false;

String fileExtension = ".png";


java.io.File filters_folder;
java.io.FilenameFilter extfilter = new java.io.FilenameFilter() {
  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(fileExtension);
  }
};

PImage[] filters;
//PGraphics map_blend_screen;

void setup() {
  //size(1000, 1000);
  fullScreen();
  origin = new MainMap(map_name);
  filters_folder = new java.io.File(sketchPath("filters"));
  cp5 = new ControlP5(this);
  fb = new FilterManager(origin);
}

void draw() {
  clear();
  if (!filters_loaded||nodes_built) {
    if (fb.show_origin||!fb.toggled) origin.draw();
  } else {
    origin.draw_blend_screen();
  }
  fb.draw();
  if (nb!=null) nb.draw();
}

void print_filter_pixel_from_mouse() {
  int searchX, searchY;
  searchX = mouseX-round(fb.panel_position.x);
  searchY = mouseY-round(fb.panel_position.y);
  if (searchX<0) searchX=0;
  if (searchY<0) searchY=0;
  if (searchX>origin.w) searchX=origin.w;
  if (searchY>origin.h) searchY=origin.h;
  //fill(200,0,0);
  stroke(0, 255, 0);
  ellipse(fb.panel_position.x+searchX, fb.panel_position.y+searchY, 10, 10);
  ellipse(fb.panel_position.x+searchX, fb.panel_position.y+searchY, 20, 20);
  ellipse(fb.panel_position.x+searchX, fb.panel_position.y+searchY, 40, 40);
  fb.map_filtered.loadPixels();
  int pix = fb.map_filtered.get(searchX, searchY); 
  //println(searchX+" "+searchY+" "+red(pix)+" "+green(pix)+" "+blue(pix)+" "+alpha(pix));
}

void keyReleased() {
  if (key==' ') load_filters();
  if (key=='b'|| key=='B') nb = new NodeManager(origin.blend_screen, origin.position);
}

void load_filters() {
  filters_loaded = true;
  println(sketchPath());
  println(filters_folder);
  origin.blend_screen = createGraphics(origin.w, origin.h);
  origin.blend_screen.beginDraw();
  origin.blend_screen.clear();
  origin.blend_screen.image(origin.map, 0, 0);
  origin.blend_screen.endDraw();

  String[] filter_names = filters_folder.list(extfilter);
  filters = new PImage[filter_names.length];
  for (int i=0; i<filter_names.length; i++) {
    origin.blend_screen.beginDraw();
    filters[i] = loadImage(filters_folder+"\\"+filter_names[i]);
    origin.blend_screen.blend(filters[i], 0, 0, filters[i].width, filters[i].height, 0, 0, origin.w, origin.h, SUBTRACT);
    println("Loaded filter \""+filter_names[i]+"\"");
    origin.blend_screen.endDraw();
  }
  origin.blend_screen.beginDraw();
  origin.blend_screen.filter(THRESHOLD, 0.01);
  origin.blend_screen.endDraw();
} 
