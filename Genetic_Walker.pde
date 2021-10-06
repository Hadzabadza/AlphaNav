class GeneticWalker {
  Node[] nodes;
  int[] sequence;
  PGraphics lines;
  float distance = 0;

  GeneticWalker(Node[] _nodes) {
    nodes = _nodes;
    generate_path();
    calculate_path_length();
  }

  void generate_path(){
    lines = null;
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
  }

  void calculate_path_length() {
    distance = 0;
    Node start;
    Node end;
    for (int i = 0; i < sequence.length-1; ++i) {
      start = nodes[sequence[i]];
      end = nodes[sequence[i+1]];
      distance += dist(start.position.x, start.position.y, end.position.x, end.position.y);
    }
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

  void draw(int opacity) {
    // calculate_path_length();
    if (lines == null) generate_lines();
    tint(255,opacity);
    image(lines, wm.position.x, wm.position.y);
  }

  void splice_genes(GeneticWalker with, float copy_level) {
    int copy_length = ceil(random(0.99, with.sequence.length*copy_level));
    int starting_index = ceil(random(0.99, sequence.length-copy_length));
    int[] copied_sequence = new int[copy_length];
    HashMap<Integer,Boolean> removed_nodes = new HashMap<Integer,Boolean>();
    for (int i=0; i<copied_sequence.length; i++) {
      copied_sequence[i] = with.sequence[i+starting_index];
      removed_nodes.put(copied_sequence[i],true);
    }
    // println(removed_nodes.keySet());
    int[] resulting_sequence = new int[with.sequence.length];
    arrayCopy(sequence, resulting_sequence);
    int best_subseq_start = 0;
    int best_subseq_end = 0;
    int best_subseq_length = 0;
    int current_subseq_start = 0;
    for (int i=0; i<resulting_sequence.length; i++) {
      if (removed_nodes.containsKey(resulting_sequence[i])
        ||((i>=starting_index)&&(i<=starting_index+copied_sequence.length))) {
        best_subseq_start = current_subseq_start;
        best_subseq_end = i;
        best_subseq_length = best_subseq_end - best_subseq_start + 1;
        current_subseq_start = i + 1;
      }
    }
    int[][] seqs = new int[1][3];
    seqs[0][0] = starting_index;
    seqs[0][1] = starting_index + copy_length - 1;
    // seqs[1][0] = best_subseq_start;
    // seqs[1][1] = best_subseq_end;
    shuffle_genes_around_subsequences(seqs);
    calculate_path_length();
  }

  // void shuffle_genes_around_subsequence(int subsequence_starting_index, int subsequence_ending_index) {
  //   int subsequence_length = subsequence_ending_index-subsequence_starting_index+1;
  //   int sequence_index = 0;
  //   int[] temp_indices = new int[sequence.length-subsequence_length];
  //   for (int i = 0; i < temp_indices.length; ++i) {
  //     if (i>=subsequence_starting_index) sequence_index = i+subsequence_length;
  //     else sequence_index = i;
  //     // println(temp_indices.length, subsequence_length, i, sequence_index);
  //     temp_indices[i]=sequence[sequence_index];
  //   } 
  //   for (int i = temp_indices.length-1; i>=0; i--) {
  //     int random_node = ceil(random(-0.99, i));
  //     if (i>=subsequence_starting_index) sequence_index = i+subsequence_length;
  //     else sequence_index = i;
  //     sequence[sequence_index]=temp_indices[random_node];
  //     for (int j = random_node; j<i; j++) temp_indices[j]=temp_indices[j+1];
  //   }
  // }

  void shuffle_genes_around_subsequences(int[][] subsequences) {
    int total_subsequences_length = 0;
    for (int i = 0; i<subsequences.length; i++) 
    {
      int subsequence_length = subsequences[i][1]-subsequences[i][0]+1;
      subsequences[i][2] = subsequence_length;
      total_subsequences_length += subsequence_length;
      // println(subsequences[i][0], subsequences[i][1], subsequences[i][2]);
    }
    // println();
    if (sequence.length!=total_subsequences_length) {
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
        // println(sequence_index,i,sequence_skip,temp_indices.length,subsequences_reached);
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
  }

  // int subsequence_skip(int index, int subse){

  // }
}
