class GeneticWalker {
  Node[] nodes;
  int[] sequence;
  PGraphics lines;
  float distance = 0;

  GeneticWalker(Node[] _nodes) {
    nodes = _nodes;
    int[] temp_indices = new int[nodes.length];
    for (int i = 0; i < nodes.length; ++i) {
      temp_indices[i]=i;
    } 
    sequence = new int[nodes.length];
    for (int i = temp_indices.length-1; i>0; i--) {
      int random_node = ceil(random(0, i));
      // println(random_node);
      sequence[temp_indices.length-1-i]=temp_indices[random_node];
      for (int j = random_node; j<i; j++) temp_indices[j]=temp_indices[j+1];
    }
    update();
  }

  void update() {
    Node start;
    Node end;
    for (int i = 0; i < sequence.length-1; ++i) {
      start = nodes[sequence[i]];
      end = nodes[sequence[i+1]];
      float x1 = start.position.x;//+start.radius*cos(angle+PI);
      float y1 = start.position.y;//+start.radius*sin(angle+PI);
      float x2 = end.position.x;//+end.radius*cos(angle);
      float y2 = end.position.y;//+end.radius*sin(angle);
      distance += dist(x1, y1, x2, y2);
    }
    println(distance);
  }

  void generate_lines() {
    lines = createGraphics(origin.w, origin.h);
    Node start;
    Node end;
    lines.beginDraw();
    lines.clear();
    lines.stroke(255, 0, 0);
    for (int i = 0; i < sequence.length-1; ++i) {
      start = nodes[sequence[i]];
      end = nodes[sequence[i+1]];
      float angle = PVector.angleBetween(start.position, end.position);//+float(frameCount)/50;
      float x1 = start.position.x;//+start.radius*cos(angle+PI);
      float y1 = start.position.y;//+start.radius*sin(angle+PI);
      float x2 = end.position.x;//+end.radius*cos(angle);
      float y2 = end.position.y;//+end.radius*sin(angle);
      lines.line(x1, y1, x2, y2);
    }
    lines.endDraw();
  }

  void draw() {
    // update();
    image(lines, nm.position.x, nm.position.y);
  }
}
