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

  //PGraphics filter_screen = createGraphics(origin.map.width, origin.map.height);
  PGraphics blend_screen = createGraphics(origin.map.width, origin.map.height);
  PGraphics binary_screen = createGraphics(origin.map.width, origin.map.height);

  int red_lpf = 50;
  int green_lpf = 255;
  int blue_lpf = 255;

  int red_hpf = 0;
  int green_hpf = 0;
  int blue_hpf = 0;  

  boolean full_fill = true;
  boolean fm_toggled = false;
  boolean show_blend = true;
  boolean show_binary = false;

  PVector position;
  controlP5.Controller[] filter_builders;
  ControlPanel fm_panel;

  FilterManager(MainMap origin) {
    create_controllers();
    generate_starting_binary_warning();
    update();
  }

  void load_filters() {
    binary_screen.beginDraw();
    binary_screen.clear();
    binary_screen.image(origin.map, 0, 0);

    String[] filter_names = filters_folder.list(extfilter);
    filters = new PImage[filter_names.length];
    for (int i=0; i<filter_names.length; i++) {
      filters[i] = loadImage(filters_folder+"\\"+filter_names[i]);
      binary_screen.blend(filters[i], 0, 0, filters[i].width, filters[i].height, 0, 0, origin.w, origin.h, SUBTRACT);
      println("Loaded filter \""+filter_names[i]+"\"");
    }
    binary_screen.filter(THRESHOLD, 0.01);
    binary_screen.endDraw();
    filters_loaded = true;
  } 

  void build_filters_csv() {
    Table csv = loadTable(sketchPath("data\\"+csv_name));
    //int w = csv.getColumnCount();
    int h = csv.getRowCount();
    //int rlpf, glpf, blpf, rhpf, ghpf, bhpf;
    for (int i = 0; i<h; i++) { 
      int rlpf = red_lpf;
      int glpf = green_lpf;
      int blpf = blue_lpf;
      int rhpf = red_hpf;
      int ghpf = green_hpf;
      int bhpf = blue_hpf; 
      red_lpf = csv.getInt(i, 0);
      green_lpf = csv.getInt(i, 1);
      blue_lpf = csv.getInt(i, 2);
      red_hpf = csv.getInt(i, 3);
      green_hpf = csv.getInt(i, 4);
      blue_hpf = csv.getInt(i, 5);
      re_generate_filtered_map();
      save_filtered_image_using_name("autoFilter"+i+".png");
      red_lpf = rlpf;
      green_lpf = glpf;
      blue_lpf = blpf;
      red_hpf = rhpf;
      green_hpf = ghpf;
      blue_hpf = bhpf;
    }
    re_generate_filtered_map();
  }

  void update() {
    re_generate_filtered_map();
    blend_screen.beginDraw(); 
    blend_screen.clear(); 
    blend_screen.image(origin.map, 0, 0); 
    blend_screen.blend(map_filtered, 0, 0, map_filtered.width, map_filtered.height, 0, 0, origin.map.width, origin.map.height, SUBTRACT); 
    blend_screen.endDraw();
  }

  void re_generate_filtered_map() {
    map_filtered = origin.map.copy(); 
    map_filtered.loadPixels(); 
    for (int i=0; i<map_filtered.pixels.length; i++) {
      float r = red(map_filtered.pixels[i]); 
      float g = green(map_filtered.pixels[i]); 
      float b = blue(map_filtered.pixels[i]); 
      int pix_bright = ceil(max(r, g, b)); 
      if (full_fill) pix_bright = 255; 
      if ((r<=red_lpf && g<=green_lpf && b<=blue_lpf)&&(r>=red_hpf && g>=green_hpf && b>=blue_hpf)) map_filtered.pixels[i] = color(r, g, b, pix_bright);
      else map_filtered.pixels[i] = color(0, pix_bright);
    }
    map_filtered.updatePixels();
  }

  void controlEvent(ControlEvent theEvent) {
    if (fm_toggled) fm_panel.move_to.y = 0; 
    else fm_panel.move_to.y = height+2; 
    update();
  }

  void draw() {
    fill (255, 180); 
    textSize(24); 
    fm_panel.draw();
    if (show_binary) {
      image(binary_screen, position.x, position.y+1); 
      text("Binary map mode", position.x+20, position.y+40);
    } else
      if (show_blend) {
        image(blend_screen, position.x, position.y+1); 
        text("Blend map mode", position.x+20, position.y+40);
      } else {
        image(map_filtered, position.x, position.y+1); 
        text("Filter demo mode", position.x+20, position.y+40);
      }
  }

  void draw_blend_screen() {
    image(blend_screen, position.x, position.y); 
  }

  void create_controllers() {
    fm_panel = new ControlPanel(8, 2, fm_active_controls_color);
    position = fm_panel.position;
    filter_builders = new controlP5.Controller[13]; 
    filter_builders[0] = cp5.addSlider("red_lpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 0, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(red_lpf)
      .plugTo(this); 

    filter_builders[1] = cp5.addSlider("green_lpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 1, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(green_lpf)
      .plugTo(this); 

    filter_builders[2] = cp5.addSlider("blue_lpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 2, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(blue_lpf)
      .plugTo(this); 

    filter_builders[3] = cp5.addSlider("red_hpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 3, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(red_hpf)
      .plugTo(this); 

    filter_builders[4] = cp5.addSlider("green_hpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 4, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(green_hpf)
      .plugTo(this); 

    filter_builders[5] = cp5.addSlider("blue_hpf")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 5, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setRange(0, 255)
      .setValue(blue_hpf)
      .plugTo(this); 

    filter_builders[6] = cp5.addToggle("show_blend")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 6, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setValue(true)
      .plugTo(this); 
    filter_builders[6].getCaptionLabel().align(CENTER, CENTER); 

    filter_builders[7] = cp5.addToggle("show_binary")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 7, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*0)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .plugTo(this); 
    filter_builders[7].getCaptionLabel().align(CENTER, CENTER); 

    filter_builders[8] = cp5.addToggle("full_fill")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 0, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*1)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setValue(true)
      .plugTo(this); 
    filter_builders[8].getCaptionLabel().align(CENTER, CENTER); 

    filter_builders[9] = cp5.addButton("load_filters")
      .setBroadcast(false)
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 1, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*1)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setBroadcast(true)
      .plugTo(this); 

    filter_builders[10] = cp5.addButton("build_filters_csv")
      .setBroadcast(false)
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 2, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*1)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setBroadcast(true)
      .plugTo(this); 

    filter_builders[11] = cp5.addTextfield("filter_name")
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 5, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*1)
      .setSize(fm_panel.control_width*2, fm_panel.control_height)
      .setValue(filter_name)

      .plugTo(this); 
    filter_builders[11].getCaptionLabel().getStyle().setPaddingLeft(10); 
    filter_builders[11].getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER); 

    filter_builders[12] = cp5.addButton("save_filtered_image")
      .setBroadcast(false)
      .setPosition(fm_panel.controls_starting_x + (fm_panel.control_width+fm_panel.control_padding_x)* 7, 
      fm_panel.controls_starting_y + (fm_panel.control_height+fm_panel.control_padding_y)*1)
      .setSize(fm_panel.control_width, fm_panel.control_height)
      .setBroadcast(true)
      .plugTo(this);

    fm_panel.controllers = filter_builders;
  }

  void save_filtered_image() {
    filter_name = cp5.get(Textfield.class, "filter_name").getText(); 
    println("Saving filter as: "+filter_name); 
    map_filtered.save(sketchPath("Filters\\"+filter_name));
  }

  void save_filtered_image_using_name(String name) {
    println("Saving filter as: "+name); 
    map_filtered.save(sketchPath("Filters\\"+name));
  }

  void generate_starting_binary_warning() {
    binary_screen.beginDraw();
    binary_screen.background(0, 150);
    binary_screen.fill(230, 0, 0);
    binary_screen.textSize(48);
    binary_screen.textAlign(CENTER);
    binary_screen.text("Binary map not generated!", binary_screen.width/2, binary_screen.height/2);
    binary_screen.fill(230);
    binary_screen.textSize(24);
    binary_screen.text("Click \"Load filters\" to load filters and generate a binary map.", binary_screen.width/2, binary_screen.height/2+40);
    binary_screen.endDraw();
  }

  void fm_toggle() {
    fm_toggled = !fm_toggled;
    // nm_switch.setState(false);
    // wm_switch.setState(false);
  }
}
