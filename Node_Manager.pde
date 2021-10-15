class NodeManager {
  PImage map_binary;
  ArrayList<Node> preliminary_nodes;
  ArrayList<PVector> pixel_position;
  Node[] nodes;
  Node start, finish, highlighted;
  int w, h, l;
  PVector nm_mouse;

  PVector distances_panel_position;
  PVector distances_panel_dimensions;

  int pixels_per_candle;
  int paddingX;
  int paddingY;
  int candle_width;
  int candle_height;
  int offsetX;

  boolean mouse_in_area = false;
  boolean nm_toggled = false;
  boolean show_distances = false;
  boolean selecting = false;

  controlP5.Controller[] node_handlers;
  PVector position;
  ControlPanel nm_panel;

  NodeManager(MainMap origin) {
    create_controllers();
    nm_mouse = new PVector(0, 0);
    distances_panel_dimensions = new PVector(nm_panel.control_width*(nm_panel.columns-1)+nm_panel.control_padding_x*(nm_panel.columns-1), nm_panel.free_vertical_space-nm_panel.control_padding_y*2-4 );
    distances_panel_position = new PVector(nm_panel.controls_starting_x+nm_panel.control_width-position.x+nm_panel.control_padding_x/4, origin.h+nm_panel.control_padding_y/2+3);
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
      Node n = compose_node(i);
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

    for (int i=0; i<preliminary_nodes.size(); i++) {
      nodes[i] = preliminary_nodes.get(i);
      nodes[i].id = i;
    }
    for (int i=0; i<nodes.length; i++) nodes[i].calculate_and_sort_distances_to_nodes(nodes);
    recalculate_distances_panel_properties();
    nodes_built = true;
  }

  Node compose_node(int pix) {
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

  void pixel_step(int _x, int _y) {
    int pix = _x+_y*w;
    map_binary.pixels[pix] = color(0);
    pixel_position.add(new PVector(_x, _y));
    if (_x!=0) if (red(map_binary.pixels[pix-1])>0) pixel_step(_x-1, _y);
    if (_y!=0) if (red(map_binary.pixels[pix-_y*w])>0) pixel_step(_x, _y-1);
    if (_x!=map_binary.width-1) if (red(map_binary.pixels[pix+1])>0) pixel_step(_x+1, _y);
    if (_y!=map_binary.height-1) if (red(map_binary.pixels[pix+w])>0) pixel_step(_x, _y+1);
  }


  Node get_node_near_mouse(PVector mouse) {
    int node_index = 0; 
    float min_dist = dist(nodes[0].position.x, nodes[0].position.y, mouse.x, mouse.y);
    float dist;
    for (int i=1; i<nodes.length; i++) {
      dist = dist(nodes[i].position.x, nodes[i].position.y, mouse.x, mouse.y);
      if (min_dist>dist) {
        min_dist = dist;
        node_index = i;
      }
    }
    return nodes[node_index];
  }

  void recalculate_distances_panel_properties() {
    pixels_per_candle = floor(distances_panel_dimensions.x/nodes.length);
    paddingX = pixels_per_candle/2;
    paddingY = floor(distances_panel_dimensions.y/20);
    candle_width = pixels_per_candle - paddingX;
    candle_height = floor(distances_panel_dimensions.y-paddingY*2);
    offsetX = (floor(distances_panel_dimensions.x)-pixels_per_candle*nodes.length)/2;
  }

  void controlEvent(ControlEvent theEvent) {
    if (nm_toggled) nm_panel.move_to.y = 0; 
    else nm_panel.move_to.y = height+2;
  }

  void mouseEvent() {
    if (mouse_in_area && selecting && highlighted!=null) {
      if (mouseButton == RIGHT) finish = highlighted;
      if (mouseButton == LEFT) start = highlighted;
    }
  }

  void draw() {
    recalculate_mouse_relative_to_position(nm_mouse, position);
    mouse_in_area = mouse_in_area(nm_mouse.x,nm_mouse.y,w,h);
    nm_panel.draw();
    if (nm_panel.is_moving||nm_toggled) {
      noFill();
      stroke(nm_active_controls_color);
      rect(distances_panel_position.x+position.x, distances_panel_position.y+position.y, distances_panel_dimensions.x, distances_panel_dimensions.y);
      strokeWeight(1);
      if (nodes!=null) {
        fill(nm_active_controls_color);
        textAlign(CENTER);
        text("Nodes:", position.x+origin.w+(width-origin.w)/4, position.y+20);
        text(nodes.length, position.x+origin.w+(width-origin.w)/4, position.y+50);
        if (highlighted!=null) text("ID: "+highlighted.id, position.x+origin.w+(width-origin.w)/4, position.y+80);

        if (start!=null) 
        { 
          start.highlight(position, color(255, 0, 0));
          if (finish!=null) {
            text("Distance:", position.x+w+(width-origin.w)/4, position.y+h-50);
            text(round(dist(start.position.x, start.position.y, finish.position.x, finish.position.y)), position.x+w+(width-origin.w)/4, position.y+h-20);
            textAlign(LEFT);
            finish.highlight(position, color(0, 255, 0));
            stroke(255);
            float rads = atan2(finish.position.y-start.position.y, finish.position.x-start.position.x);
            float startX = start.position.x+position.x+start.radius*cos(rads);
            float startY = start.position.y+position.y+start.radius*sin(rads);
            float finishX = finish.position.x+position.x+finish.radius*cos(rads+PI);
            float finishY = finish.position.y+position.y+finish.radius*sin(rads+PI);
            line(startX, startY, finishX, finishY);
          }
        } else {
          if (finish!=null) finish.highlight(position, color(0, 255, 0));
        }

        if (selecting) {
          float hintY;
          if (nm_mouse.y>origin.h/2) hintY = position.y+40; 
          else hintY = position.y+origin.h-40;
          textAlign(LEFT);
          fill(255, 0, 0);
          text("Lclick to select start.", position.x+20, hintY);
          textAlign(RIGHT);
          fill(0, 255, 0);
          text("Rclick to select finish.", position.x+origin.w-20, hintY);
        }
        textAlign(LEFT);

        if (mouse_in_area) {
          highlighted = get_node_near_mouse(nm_mouse);
          highlighted.highlight(position, color(255));
          highlighted.draw_distances_zip(distances_panel_position.x, distances_panel_position.y, distances_panel_dimensions.x, distances_panel_dimensions.y);
        } else {
          highlighted = null;
        }
        for (Node n : nodes) n.draw(position);
      } else {
        fill(255, 0, 0);
        textAlign(CENTER);
        text("Build nodes to show distances", distances_panel_position.x+position.x+distances_panel_dimensions.x/2, distances_panel_position.y+position.y+distances_panel_dimensions.y/2);
        textAlign(LEFT);
      }
    }
  }

  void create_controllers() {
    nm_panel = new ControlPanel(4, 3, nm_active_controls_color);
    node_handlers = new controlP5.Controller[3]; 
    position = nm_panel.position;
    node_handlers[0] = cp5.addButton("build_nodes")
      .setPosition(nm_panel.controls_starting_x + (nm_panel.control_width+nm_panel.control_padding_x)* 0, 
      nm_panel.controls_starting_y + (nm_panel.control_height+nm_panel.control_padding_y)*0)
      .setSize(nm_panel.control_width, nm_panel.control_height)
      .setColorBackground(nm_background_color)
      .setColorForeground(nm_foreground_color)
      .setColorActive(nm_active_controls_color)
      .plugTo(this);
    node_handlers[0].getCaptionLabel().setSize(24);

    node_handlers[1] = cp5.addToggle("show_distances")
      .setPosition(nm_panel.controls_starting_x + (nm_panel.control_width+nm_panel.control_padding_x)* 0, 
      nm_panel.controls_starting_y + (nm_panel.control_height+nm_panel.control_padding_y)*1)
      .setSize(nm_panel.control_width, nm_panel.control_height)
      .setColorBackground(nm_background_color)
      .setColorForeground(nm_foreground_color)
      .setColorActive(nm_active_controls_color)
      .plugTo(this);
    node_handlers[1].setCaptionLabel("Show distances");
    node_handlers[1].getCaptionLabel().setSize(24);
    node_handlers[1].getCaptionLabel().align(CENTER, CENTER);
    node_handlers[1].getCaptionLabel().setSize(24);

    node_handlers[2] = cp5.addToggle("selecting")
      .setPosition(nm_panel.controls_starting_x + (nm_panel.control_width+nm_panel.control_padding_x)* 0, 
      nm_panel.controls_starting_y + (nm_panel.control_height+nm_panel.control_padding_y)*2)
      .setSize(nm_panel.control_width, nm_panel.control_height)
      .setColorBackground(nm_background_color)
      .setColorForeground(nm_foreground_color)
      .setColorActive(nm_active_controls_color)
      .plugTo(this);
    node_handlers[2].setCaptionLabel("Select start/finish");
    node_handlers[2].getCaptionLabel().setSize(24);
    node_handlers[2].getCaptionLabel().align(CENTER, CENTER);

    nm_panel.controllers = node_handlers;
  }

  void nm_toggle() {
    nm_toggled = !nm_toggled;
    // fm_switch.setState(false);
    // wm_switch.setState(false);
  }
}
