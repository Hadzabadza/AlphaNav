class NodeManager {
  PImage map_binary;
  ArrayList<Node> preliminary_nodes;
  Node[] nodes;
  int w, h, l;

  PVector node_offset;
  int left_border, right_border, top_border, bottom_border;
  ArrayList<PVector> pixel_position;

  NodeManager() {
    preliminary_nodes = new ArrayList<Node>();
    node_offset = origin.position;
  }

  void draw() {
    if (nodes!=null) for (Node n : nodes) n.draw(node_offset);
  }

  void build_nodes(PImage _map_binary) {
    map_binary = _map_binary.copy();
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
    //println(l, w, h);
    //println(pix, _x, _y);
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
}
