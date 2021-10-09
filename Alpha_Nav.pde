import controlP5.*;
import java.io.File;
import java.util.Map;

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

color wm_background_color = color(90, 0, 45);
color wm_foreground_color = color(130, 0, 60);
color wm_active_controls_color = color(180, 0, 105);
//                                                           //
///////////////////////////////////////////////////////////////

ControlP5 cp5;

MainMap origin;
FilterManager fm;
NodeManager nm;
WalkerManager wm;

controlP5.Toggle fm_switch;
controlP5.Toggle nm_switch;
controlP5.Toggle wm_switch;

boolean filters_loaded = false;
boolean nodes_built = false;
boolean walkers_unleashed = false;

int paddingX;
int paddingY;

color main_map_bounds_color = color(255);

void setup() {
  fullScreen();
  origin = new MainMap(map_name);

  cp5 = new ControlP5(this);

  cp5.setColorBackground(fm_background_color)  
    .setColorForeground(fm_foreground_color)
    .setColorActive(fm_active_controls_color);
  fm = new FilterManager(origin);
  fm.filters_folder = new java.io.File(sketchPath(filters_folder));
  fm_switch = cp5.addToggle("fm_toggle")
    .setPosition(paddingX/8, paddingY + 20)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Filter manager")
    .plugTo(fm);
  fm_switch.getCaptionLabel().align(CENTER, CENTER);

  nm = new NodeManager(origin);

  nm_switch = cp5.addToggle("nm_toggle")
    .setPosition(paddingX/8, paddingY + 50)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Node manager")
    .setColorBackground(nm_background_color)  
    .setColorForeground(nm_foreground_color)
    .setColorActive(nm_active_controls_color)
    .plugTo(nm);
  nm_switch.getCaptionLabel().align(CENTER, CENTER);

  wm = new WalkerManager();

  wm_switch = cp5.addToggle("wm_toggle")
    .setPosition(paddingX/8, paddingY + 80)
    .setSize(paddingX/4*3, 25)
    .setCaptionLabel("Walker manager")
    .setColorBackground(wm_background_color)  
    .setColorForeground(wm_foreground_color)
    .setColorActive(wm_active_controls_color)
    .plugTo(wm);
  wm_switch.getCaptionLabel().align(CENTER, CENTER);
}

void keyReleased() {
  if (key==' ') wm.nextgen();
}

void mouseReleased() {
  nm.mouseEvent();
}

void draw_bounds(int x, int y, int w, int h, color c) {
  noFill();
  stroke(c);
  rect(x-1, y, w+2, h+2);
}

void draw() {
  clear();
  origin.draw();
  fm.draw();
  nm.draw();
  wm.draw();
}
