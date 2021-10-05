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
    // println(distance);
  }

  void generate_lines() {
    lines = createGraphics(origin.w, origin.h);
    Node start;
    Node end;
    lines.beginDraw();
    lines.clear();
    lines.stroke(255);
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
    if (lines == null) generate_lines();
    image(lines, wm.position.x, wm.position.y);
  }

  void splice_genes(GeneticWalker with) {
  }

  void shuffle_genes_around_subsequence(int subsequence_starting_index, int subsequence_ending_index) {
    int subsequence_length = subsequence_ending_index-subsequence_starting_index+1;
    int sequence_index = 0;
    int[] temp_indices = new int[sequence.length-subsequence_length];
    for (int i = 0; i < temp_indices.length; ++i) {
      if (i>=subsequence_starting_index) sequence_index = i+subsequence_length;
      else sequence_index = i;
      // println(temp_indices.length, subsequence_length, i, sequence_index);
      temp_indices[i]=sequence[sequence_index];
    } 
    for (int i = temp_indices.length-1; i>=0; i--) {
      int random_node = ceil(random(-0.99, i));
      if (i>=subsequence_starting_index) sequence_index = i+subsequence_length;
      else sequence_index = i;
      sequence[sequence_index]=temp_indices[random_node];
      for (int j = random_node; j<i; j++) temp_indices[j]=temp_indices[j+1];
    }
  }

  void shuffle_genes_around_subsequences(int[][] subsequences) {
    int total_subsequences_length = 0;
    for (int i = 0; i<subsequences.length; i++) 
    {
      int subsequence_length = subsequences[i][1]-subsequences[i][0]+1;
      subsequences[i][2] = subsequence_length;
      total_subsequences_length += subsequence_length;
    }

    int[] temp_indices = new int[sequence.length-total_subsequences_length];
    int sequence_index = 0;

    int subsequences_reached = 0;
    int sequence_skip = 0;
    for (int i = 0; i < temp_indices.length; ++i) {
      for (int j = subsequences_reached; j<subsequences.length; j++) 
        if (i+sequence_skip>=subsequences[j][0]) 
        {
          sequence_skip += subsequences[j][2];
          subsequences_reached ++;
        }
      sequence_index = i+sequence_skip;

      temp_indices[i]=sequence[sequence_index];
    } 

    for (int i = temp_indices.length-1; i>=0; i--) {

      subsequences_reached = 0;
      sequence_skip = 0;
      for (int j = subsequences_reached; j<subsequences.length; j++) 
        if (i+sequence_skip>=subsequences[j][0]) 
        {
          sequence_skip += subsequences[j][2];
          subsequences_reached ++;
        }
      sequence_index = i+sequence_skip;

      int random_node = ceil(random(-0.99, i));
      sequence[sequence_index] = temp_indices[random_node];
      for (int j = random_node; j<i; j++) temp_indices[j] = temp_indices[j+1];
    }
  }

  // int subsequence_skip(int index, int subse){

  // }
}
