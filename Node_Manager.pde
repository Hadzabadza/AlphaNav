class NodeManager {
  PImage map_binary;
  ArrayList<Node> preliminary_nodes;
  ArrayList<PVector> pixel_position;
  Node[] nodes;
  int w, h, l;

  // int left_border, right_border, top_border, bottom_border;

  int slider_width;
  int slider_height;
  int slider_padding_x;
  int slider_padding_y;
  int sliders_starting_x;
  int sliders_starting_y;

  boolean nm_toggled = false;

  PVector position;
  PVector move_to = new PVector(0, 0);
  float move_speed = 0.1;

  controlP5.Controller[] node_handlers;

  NodeManager(MainMap origin) {
    position = origin.position;

    int control_columns = 8;
    int free_vertical_space = height - origin.h;

    position = new PVector(origin.position.x, height);
    move_to = position.copy();

    slider_width = width/12;
    slider_height = slider_width/6;

    slider_padding_x = slider_width/2;
    slider_padding_y = min(slider_height, (free_vertical_space-slider_height*2)/3);

    sliders_starting_x = (width-(control_columns*slider_width+(control_columns-1)*slider_padding_x))/2;
    sliders_starting_y = round(position.y) + origin.h + slider_padding_y;

    create_controllers();
    // generate_starting_binary_warning();
  }

  void draw() {
    if (nm_toggled) move_to.y = 0; 
    else move_to.y = height;
    if (position.x!=move_to.x || position.y!=move_to.y) move_panel();
    if (nodes!=null) for (Node n : nodes) n.draw(origin.position);
  }

  void build_nodes() {

    preliminary_nodes = new ArrayList<Node>();
    map_binary = fm.binary_screen.get().copy();
    w = map_binary.get().width;
    h = map_binary.get().height;
    map_binary.loadPixels();
    l = map_binary.pixels.length;
    for (int i=0; i<l; i++) if (red(map_binary.pixels[i])!=0)
    {
      Node n = calculate_node(i);
      if (n!=null) preliminary_nodes.add(n);
    }
    map_binary.updatePixels();

    ArrayList<Node> nodes_to_remove = new ArrayList<Node>();
    for (Node n : preliminary_nodes)
      for (Node other : preliminary_nodes) {
        Node to_remove = n.attempt_to_remove_collided_node(other);
        if (to_remove!=null)nodes_to_remove.add(to_remove);
      }
    for (Node n : nodes_to_remove) preliminary_nodes.remove(n);
    nodes = new Node[preliminary_nodes.size()];

    for (int i=0; i<preliminary_nodes.size(); i++) nodes[i] = preliminary_nodes.get(i);
    nodes_built = true;
  }

  void pixel_step(int _x, int _y) {
    int pix = _x+_y*w;
    map_binary.pixels[pix] = color(0);
    pixel_position.add(new PVector(_x, _y));
    if (_x!=0) if (red(map_binary.pixels[pix-1])>0) pixel_step(_x-1, _y);
    if (_y!=0) if (red(map_binary.pixels[pix-_y*w])>0) pixel_step(_x, _y-1);
    if (_x!=map_binary.width-1) if (red(map_binary.pixels[pix+1])>0) pixel_step(_x+1, _y);
    if (_y!=map_binary.height-1) if (red(map_binary.pixels[pix+w])>0) pixel_step(_x, _y+1);
  }

  Node calculate_node(int pix) {
    int x = pix%w;
    int y = pix/w;
    pixel_position = new ArrayList();
    pixel_step(x, y);
    int pix_mass = pixel_position.size();
    if (pix_mass>=node_min_mass) {
      PVector center_of_mass = new PVector(0, 0);
      for (PVector n : pixel_position) center_of_mass.add(n);
      center_of_mass.div(pix_mass);
      return new Node(center_of_mass, pix_mass);
    } else return null;
  }

  void create_controllers() {
    node_handlers = new controlP5.Controller[1]; 
    node_handlers[0] = cp5.addButton("build_nodes")
      .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 0, 
      sliders_starting_y + (slider_height+slider_padding_y)*0)
      .setSize(slider_width, slider_height)
      .setColorBackground(nm_background_color)
      .setColorForeground(nm_foreground_color)
      .setColorActive(nm_active_controls_color)
      .plugTo(this); 

    // node_handlers[1] = cp5.addSlider("green_lpf")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 1, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setRange(0, 255)
    //   .setValue(green_lpf)
    //   .plugTo(this); 

    // node_handlers[2] = cp5.addSlider("blue_lpf")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 2, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setRange(0, 255)
    //   .setValue(blue_lpf)
    //   .plugTo(this); 

    // node_handlers[3] = cp5.addSlider("red_hpf")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 3, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setRange(0, 255)
    //   .setValue(red_hpf)
    //   .plugTo(this); 

    // node_handlers[4] = cp5.addSlider("green_hpf")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 4, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setRange(0, 255)
    //   .setValue(green_hpf)
    //   .plugTo(this); 

    // node_handlers[5] = cp5.addSlider("blue_hpf")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 5, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setRange(0, 255)
    //   .setValue(blue_hpf)
    //   .plugTo(this); 

    // node_handlers[6] = cp5.addToggle("show_blend")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 6, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .setValue(true)
    //   .plugTo(this); 
    // node_handlers[6].getCaptionLabel().align(CENTER, CENTER); 

    // node_handlers[7] = cp5.addToggle("show_binary")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 7, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*0)
    //   .setSize(slider_width, slider_height)
    //   .plugTo(this); 
    // node_handlers[7].getCaptionLabel().align(CENTER, CENTER); 

    // node_handlers[8] = cp5.addToggle("full_fill")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 0, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*1)
    //   .setSize(slider_width, slider_height)
    //   .setValue(true)
    //   .plugTo(this); 
    // node_handlers[8].getCaptionLabel().align(CENTER, CENTER); 

    // node_handlers[9] = cp5.addButton("load_filters")
    //   .setBroadcast(false)
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 1, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*1)
    //   .setSize(slider_width, slider_height)
    //   .setBroadcast(true)
    //   .plugTo(this); 

    // node_handlers[10] = cp5.addButton("build_filters_csv")
    //   .setBroadcast(false)
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 2, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*1)
    //   .setSize(slider_width, slider_height)
    //   .setBroadcast(true)
    //   .plugTo(this); 

    // node_handlers[11] = cp5.addTextfield("filter_name")
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 5, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*1)
    //   .setSize(slider_width*2, slider_height)
    //   .setValue(filter_name)

    //   .plugTo(this); 
    // node_handlers[11].getCaptionLabel().getStyle().setPaddingLeft(10); 
    // node_handlers[11].getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, CENTER); 

    // node_handlers[12] = cp5.addButton("save_filtered_image")
    //   .setBroadcast(false)
    //   .setPosition(sliders_starting_x + (slider_width+slider_padding_x)* 7, 
    //   sliders_starting_y + (slider_height+slider_padding_y)*1)
    //   .setSize(slider_width, slider_height)
    //   .setBroadcast(true)
    //   .plugTo(this);
}

void move_panel() {
  PVector move_diff = position.copy().lerp(move_to, move_speed); 
  move_diff.sub(position); 
  for (int i=0; i<node_handlers.length; i++) {
    float[] pos = node_handlers[i].getPosition(); 
    pos[0]+=move_diff.x; 
    pos[1]+=move_diff.y; 
    node_handlers[i].setPosition(pos);
  }
  position.add(move_diff);
}
}
