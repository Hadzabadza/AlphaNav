import controlP5.*;
import java.io.File;

///////////////////////////////////////////////////////////////
//                    SETTINGS HERE                          //
String map_name = "Mep.png";
String csv_name = "BaseFilters.csv";
String filters_folder = "filters";
int node_min_mass = 32;
color active_controls_color = color(10,80,150);
//                                                           //
///////////////////////////////////////////////////////////////

ControlP5 cp5;

MainMap origin;
FilterManager fm;
NodeManager nb;

controlP5.Controller fm_toggle;

boolean filters_loaded = false;
boolean nodes_built = false;

int paddingX;
int paddingY;

void setup() {
  //size(1000, 1000);
  fullScreen();
  origin = new MainMap(map_name);
  cp5 = new ControlP5(this);
  fm = new FilterManager(origin);
  fm.filters_folder = new java.io.File(sketchPath(filters_folder));
  nb = new NodeManager();
  fm_toggle = cp5.addToggle("toggled")
    .setPosition(paddingX/8, paddingY + 20)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Filter manager")
    .setColorActive(active_controls_color)
    .plugTo(fm);
  fm_toggle.getCaptionLabel().align(CENTER, CENTER);
}

void draw() {
  clear();
  //if (!filters_loaded||nodes_built) {
  //  if (fm.show_origin||!fm.toggled) origin.draw();
  //} else origin.draw_blend_screen();
  origin.draw();
  fm.draw();
  nb.draw();
}

void keyReleased() {
  if (key==' ') fm.build_filters_csv();
  if (key=='b'|| key=='B') nb.build_nodes(fm.binary_screen.get());
}

void draw_bounds(int x, int y, int w, int h) {
  noFill();
  stroke(255);
  rect(x-1, y, w+2, h+2);
}

void print_filter_pixel_from_mouse() {
  int searchX, searchY;
  searchX = mouseX-round(fm.position.x);
  searchY = mouseY-round(fm.position.y);
  if (searchX<0) searchX=0;
  if (searchY<0) searchY=0;
  if (searchX>origin.w) searchX=origin.w;
  if (searchY>origin.h) searchY=origin.h;
  //fill(200,0,0);
  stroke(0, 255, 0);
  ellipse(fm.position.x+searchX, fm.position.y+searchY, 10, 10);
  ellipse(fm.position.x+searchX, fm.position.y+searchY, 20, 20);
  ellipse(fm.position.x+searchX, fm.position.y+searchY, 40, 40);
  fm.map_filtered.loadPixels();
  int pix = fm.map_filtered.get(searchX, searchY); 
  //println(searchX+" "+searchY+" "+red(pix)+" "+green(pix)+" "+blue(pix)+" "+alpha(pix));
}
