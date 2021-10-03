class FilterManager {

  String fileExtension = ".png";
  java.io.File filters_folder;
  java.io.FilenameFilter extfilter = new java.io.FilenameFilter() {
    boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(fileExtension);
    }
  };
  PImage[] filters;

  PImage map_filtered;
  String filter_name = "Filter1.png";

  PGraphics filter_screen = createGraphics(origin.map.width, origin.map.height);
  PGraphics blend_screen = createGraphics(origin.map.width, origin.map.height);

  int red_lpf = 50;
  int green_lpf = 255;
  int blue_lpf = 255;

  int red_hpf = 0;
  int green_hpf = 0;
  int blue_hpf = 0;  

  int slider_width;
  int slider_height;
  int slider_padding_x;
  int slider_padding_y;
  int sliders_starting_x;
  int sliders_starting_y;

  boolean full_fill = true;
  boolean toggled = false;
  boolean show_origin = true;

  PVector panel_position;
  PVector move_to = new PVector(0, 0);
  float move_speed = 0.1;

  controlP5.Controller[] filter_builders;

  FilterManager(MainMap origin) {
    //height-slider_height*2-90
    panel_position = origin.position.copy();
    move_to = panel_position.copy();
    sliders_starting_x = round(origin.position.x+20);
    sliders_starting_y = round(origin.position.y)+ height-height/50*2-60;
    slider_width = origin.map.width/12;
    slider_height = origin.map.height/50;
    slider_padding_x = slider_width/2;
    slider_padding_y = slider_height;
    create_controllers();
    update();
  }

  FilterManager(PVector _panel_position, int _sliders_starting_x, int _sliders_starting_y, int _slider_width, int _slider_height) {
    //height-slider_height*2-90
    panel_position = _panel_position.copy();
    move_to = panel_position.copy();
    sliders_starting_x = _sliders_starting_x;
    sliders_starting_y = _sliders_starting_y;
    slider_width = _slider_width;
    slider_height = _slider_height;
    slider_padding_x = slider_width/2;
    slider_padding_y = slider_height;
    create_controllers();
    update();
  }

  void load_and_apply_filters() {
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
    filters_loaded = true;
  } 

  void update() {
    map_filtered = origin.map.copy();
    map_filtered.loadPixels();
    for (int i=0; i<map_filtered.pixels.length; i++) {
      float r = red(map_filtered.pixels[i]);
      float g = green(map_filtered.pixels[i]);
      float b = blue(map_filtered.pixels[i]);
      int pix_bright = ceil(max(r, g, b));
      if (full_fill) pix_bright = 255; 
      if ((r<=red_lpf && g<=green_lpf && b<=blue_lpf)&&(r>=red_hpf && g>=green_hpf && b>=blue_hpf))
      { 
        map_filtered.pixels[i] = color(r, g, b, pix_bright);
      } else {
        map_filtered.pixels[i] = color(0, pix_bright);
      }
    }
    map_filtered.updatePixels();
    filter_screen.beginDraw();
    filter_screen.clear();
    filter_screen.image(map_filtered, 0, 0);
    filter_screen.endDraw();
    blend_screen.beginDraw();
    blend_screen.clear();
    blend_screen.image(origin.map, 0, 0);
    blend_screen.blend(map_filtered, 0, 0, map_filtered.width, map_filtered.height, 0, 0, origin.map.width, origin.map.height, SUBTRACT);
    blend_screen.endDraw();
  }

  void controlEvent(ControlEvent theEvent) {
    update();
  }

  void draw() {
    if (toggled) move_to.y = 0;
    else move_to.y = height;
    if (panel_position.x!=move_to.x || panel_position.y!=move_to.y) move_panel();

    noFill();
    stroke(255);
    rect(panel_position.x-1, panel_position.y, origin.map.width+2, origin.map.height+2);
    if (show_origin) image(blend_screen, panel_position.x, panel_position.y+1);
    else image(filter_screen, panel_position.x, panel_position.y+1);
  }


  void create_controllers() {
    filter_builders = new controlP5.Controller[11];
    filter_builders[0] = cp5.addSlider("red_lpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 0, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(red_lpf)
      .plugTo(this);

    filter_builders[1] = cp5.addSlider("green_lpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 1, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(green_lpf)
      .plugTo(this);

    filter_builders[2] = cp5.addSlider("blue_lpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 2, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(blue_lpf)
      .plugTo(this);

    filter_builders[3] = cp5.addSlider("red_hpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 3, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(red_hpf)
      .plugTo(this);

    filter_builders[4] = cp5.addSlider("green_hpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 4, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(green_hpf)
      .plugTo(this);

    filter_builders[5] = cp5.addSlider("blue_hpf")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 5, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setRange(0, 255)
      .setValue(blue_hpf)
      .plugTo(this);

    filter_builders[6] = cp5.addToggle("show_origin")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 6, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setValue(true)
      .plugTo(this);

    filter_builders[7] = cp5.addToggle("full_fill")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 0, 
      sliders_starting_y + (slider_height+slider_padding_y)*1)
      .setSize(slider_width, slider_height)
      .setValue(true)
      .plugTo(this);

    //filter_builders[8] = cp5.addToggle("reverse_fill")
    //  .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 1, 
    //  sliders_starting_y + (slider_height+slider_padding_y)*1)
    //  .setSize(slider_width, slider_height)
    //  .plugTo(this);

    filter_builders[8] = cp5.addTextfield("filter_name")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 5, 
      sliders_starting_y + (slider_height+slider_padding_y)*1)
      .setSize(slider_width*2, slider_height)
      .setValue(filter_name)
      .plugTo(this);

    filter_builders[9] = cp5.addButton("save_filtered_image")
      .setBroadcast(false)
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 7, 
      sliders_starting_y + (slider_height+slider_padding_y)*1)
      .setSize(slider_width, slider_height)
      .setBroadcast(true)
      .plugTo(this);

    filter_builders[10] = cp5.addToggle("toggled")
      .setPosition(panel_position.x+origin.map.width+40, 
      panel_position.y-slider_width/2)
      .setSize(slider_height, slider_width)
      .plugTo(this);
  }

  void move_panel() {
    PVector move_diff = panel_position.copy().lerp(move_to, move_speed);
    move_diff.sub(panel_position);
    for (int i=0; i<filter_builders.length; i++) {
      float[] pos = filter_builders[i].getPosition();
      pos[0]+=move_diff.x;
      pos[1]+=move_diff.y;
      filter_builders[i].setPosition(pos);
    }
    panel_position.add(move_diff);
  }

  void save_filtered_image() {
    filter_name = cp5.get(Textfield.class, "filter_name").getText();
    println("Saving filter as: "+filter_name);
    PGraphics image_buffer = createGraphics(map_filtered.width, map_filtered.height);
    image_buffer.beginDraw();
    image_buffer.background(0);
    image_buffer.image(map_filtered, 0, 0);
    image_buffer.endDraw();
    image_buffer.save(sketchPath("Filters\\"+filter_name));
  }
}
