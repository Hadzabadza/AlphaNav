import controlP5.*;
import java.io.File;

///////////////////////////////////////////////////////////////
//                    SETTINGS HERE                          //
String map_name = "Mep.png";
String filters_folder = "filters";
int node_min_mass = 32;
//                                                           //
///////////////////////////////////////////////////////////////

ControlP5 cp5;

MainMap origin;
FilterManager fb;
NodeManager nb;

boolean filters_loaded = false;
boolean nodes_built = false;

void setup() {
  //size(1000, 1000);
  fullScreen();
  origin = new MainMap(map_name);
  cp5 = new ControlP5(this);
  fb = new FilterManager(origin);
  fb.filters_folder = new java.io.File(sketchPath(filters_folder));
  nb = new NodeManager();
}

void draw() {
  clear();
  if (!filters_loaded||nodes_built) {
    if (fb.show_origin||!fb.toggled) origin.draw();} 
    else origin.draw_blend_screen();
  fb.draw();
  nb.draw();
}

void keyReleased() {
  if (key==' ') fb.load_and_apply_filters();
  if (key=='b'|| key=='B') nb.build_nodes(origin.blend_screen.get());
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
