class NodeManager {
  PImage source;
  PGraphics map_binary_screen;
  ArrayList<Node> preliminary_nodes;
  Node[] nodes;
  int w, h, l;

  PVector node_offset;
  int left_border, right_border, top_border, bottom_border;
  ArrayList<PVector> pixel_position;

  NodeManager(PGraphics _source) {
    w = _source.get().width;
    h = _source.get().height;
    map_binary_screen = createGraphics(w, h);
    map_binary_screen.beginDraw();
    map_binary_screen.image(_source.get(), 0, 0 );
    map_binary_screen.filter(THRESHOLD, 0.01);
    map_binary_screen.endDraw();
    node_offset = origin.position;
    source = map_binary_screen.get();
    preliminary_nodes = new ArrayList<Node>();
    build_nodes();
    nodes_built = true;
    _source.beginDraw();
    _source.image(source, 0, 0);
    _source.endDraw();
  }

  void draw() {
    for (Node n : nodes) n.draw(node_offset);
  }

  void build_nodes() {
    source.loadPixels();
    l = source.pixels.length;
    for (int i=0; i<l; i++) if (red(source.pixels[i])!=0)
    {
      Node n = calculate_node(i);
      if (n!=null) preliminary_nodes.add(n);
    }
    source.updatePixels();

    ArrayList<Node> nodes_to_remove = new ArrayList<Node>();
    for (Node n : preliminary_nodes)
      for (Node other : preliminary_nodes) {
        Node to_remove = n.attempt_to_remove_collided_node(other);
        if (to_remove!=null)nodes_to_remove.add(to_remove);
      }
    for (Node n:nodes_to_remove) preliminary_nodes.remove(n);
    nodes = new Node[preliminary_nodes.size()];
    
    for (int i=0; i<preliminary_nodes.size(); i++) nodes[i] = preliminary_nodes.get(i);
  }

  void pixel_step(int _x, int _y) {
    int pix = _x+_y*w;
    source.pixels[pix] = color(0);
    pixel_position.add(new PVector(_x, _y));
    //println(l, w, h);
    //println(pix, _x, _y);
    if (_x!=0) if (red(source.pixels[pix-1])>0) pixel_step(_x-1, _y);
    if (_y!=0) if (red(source.pixels[pix-_y*w])>0) pixel_step(_x, _y-1);
    if (_x!=source.width-1) if (red(source.pixels[pix+1])>0) pixel_step(_x+1, _y);
    if (_y!=source.height-1) if (red(source.pixels[pix+w])>0) pixel_step(_x, _y+1);
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
      return new Node(center_of_mass, node_radius, pix_mass);
    } else return null;
  }
}
