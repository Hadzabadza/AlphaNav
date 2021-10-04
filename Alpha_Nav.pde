import controlP5.*;
import java.io.File;

///////////////////////////////////////////////////////////////
//                    SETTINGS HERE                          //
String map_name = "Mep.png";
String csv_name = "BaseFilters.csv";
String filters_folder = "filters";
int node_min_mass = 32;

color fm_background_color = color(0, 45, 90);
color fm_foreground_color = color(0, 60, 130);
color fm_active_controls_color = color(0, 105, 180);

color nm_background_color = color(0, 90, 45);
color nm_foreground_color = color(0, 130, 60);
color nm_active_controls_color = color(0, 180, 105);
//                                                           //
///////////////////////////////////////////////////////////////

ControlP5 cp5;

MainMap origin;
FilterManager fm;
NodeManager nm;

GeneticWalker[] walkers;

controlP5.Controller fm_toggle;
controlP5.Controller nm_toggle;

boolean filters_loaded = false;
boolean nodes_built = false;
boolean walkers_unleashed = false;

int paddingX;
int paddingY;

void setup() {
  fullScreen();
  origin = new MainMap(map_name);

  cp5 = new ControlP5(this);

  cp5.setColorBackground(fm_background_color)  
    .setColorForeground(fm_foreground_color)
    .setColorActive(fm_active_controls_color);
  fm = new FilterManager(origin);
  fm.filters_folder = new java.io.File(sketchPath(filters_folder));
  fm_toggle = cp5.addToggle("fm_toggled")
    .setPosition(paddingX/8, paddingY + 20)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Filter manager")
    .plugTo(fm);
  fm_toggle.getCaptionLabel().align(CENTER, CENTER);

  nm = new NodeManager(origin);

  nm_toggle = cp5.addToggle("nm_toggled")
    .setPosition(paddingX/8, paddingY + 50)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Node manager")
    .setColorBackground(nm_background_color)  
    .setColorForeground(nm_foreground_color)
    .setColorActive(nm_active_controls_color)
    .plugTo(nm);
  nm_toggle.getCaptionLabel().align(CENTER, CENTER);
}

void draw() {
  clear();
  origin.draw();
  fm.draw();
  nm.draw();
  if (walkers_unleashed) {
    GeneticWalker best_walker = null;
    float best_path = walkers[0].distance;
    for (GeneticWalker gw : walkers) {
      if (gw.distance<best_path) {
        best_walker = gw;
        best_path = gw.distance;
      }
    }
    if (best_walker.lines == null) best_walker.generate_lines();
    best_walker.draw();
  }
}

void keyReleased() {
  if (key==' ') fm.build_filters_csv();
  if (key=='b'|| key=='B') {
    nm.build_nodes();
    walkers = new GeneticWalker[100];
    for (int i = 0; i < walkers.length; ++i) walkers[i] = new GeneticWalker(nm.nodes); 
    walkers_unleashed=true;
  }
}

void draw_bounds(int x, int y, int w, int h) {
  noFill();
  stroke(255);
  rect(x-1, y, w+2, h+2);
}
