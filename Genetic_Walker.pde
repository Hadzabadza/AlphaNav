class GeneticWalker {
  Node[] nodes;
  int[] sequence;
  PGraphics lines;
  float distance = 0;
  int animation_frame = -1;
  int start_offset = 0;
  int start_id = 0;
  int finish_offset = 0;
  int finish_id = 0;

  GeneticWalker(Node[] _nodes) {
    nodes = _nodes;
    generate_sequence();
    calculate_path_length();
  }

  void generate_sequence() {
    if (nm.start!=null&&nm.finish!=null&&nm.start==nm.finish) sequence = new int[nodes.length+1];
    else sequence = new int[nodes.length];
    lines = null;
    start_offset = 0;
    start_id = 0;
    finish_offset = 0;
    finish_id = 0;
    if (nm.start!=null) {
      start_offset = 1;
      start_id = nm.start.id;
      sequence[0] = start_id;
    }
    if (nm.finish!=null) {
      finish_offset = 1;
      finish_id = nm.finish.id;
      sequence[sequence.length-1]=finish_id;
    }
    int[] temp_indices = new int[sequence.length-start_offset-finish_offset];
    int index_offset;
    for (int i = 0; i < temp_indices.length; ++i) {
      index_offset = 0;
      if(start_id<finish_id){
        if ((i+index_offset)>=start_id) index_offset+=start_offset;
        if ((i+index_offset)>=finish_id) index_offset+=finish_offset;
      } else {
        if ((i+index_offset)>=finish_id) index_offset+=finish_offset;
        if ((i+index_offset)>=start_id) index_offset+=start_offset;
      }
      temp_indices[i]=i+index_offset;
    } 
    int sequence_index;
    for (int i = temp_indices.length-1; i>=0; i--) {
      int random_node = ceil(random(-0.99, i));
      sequence_index = temp_indices.length-1-i;
      sequence[temp_indices.length-1-i+finish_offset]=temp_indices[random_node];
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

  void splice_genes(GeneticWalker with, float copy_level) {
    int copy_length = ceil(random(0.99, with.sequence.length*copy_level-0.99-start_offset-finish_offset));
    int starting_index = ceil(random(-0.99+start_offset, sequence.length-copy_length-finish_offset));
    int[] copied_sequence = new int[copy_length];
    HashMap<Integer, Boolean> removed_nodes = new HashMap<Integer, Boolean>();
    for (int i=0; i<copied_sequence.length; i++) {
      copied_sequence[i] = with.sequence[i+starting_index];
      removed_nodes.put(copied_sequence[i], true);
    }
    int[] resulting_sequence = new int[with.sequence.length];
    arrayCopy(sequence, resulting_sequence);
    // int best_subseq_start = 0;
    // int best_subseq_end = 0;
    // int best_subseq_length = 0;
    int current_subseq_start = 0;
    for (int i=0; i<resulting_sequence.length; i++) {
      if (removed_nodes.containsKey(resulting_sequence[i])
        ||((i>=starting_index)&&(i<=starting_index+copied_sequence.length))) {
        // best_subseq_start = current_subseq_start;
        // best_subseq_end = i;
        // best_subseq_length = best_subseq_end - best_subseq_start + 1;
        current_subseq_start = i + 1;
      }
    }
    int[][] seqs = new int[1+start_offset+finish_offset][3];
    if (start_offset!=0) {
      seqs[0][0] = 0;
      seqs[0][1] = 0;
    }
    seqs[0+start_offset][0] = starting_index;
    seqs[0+start_offset][1] = starting_index + copy_length - 1;
    if (finish_offset!=0) {
      seqs[0+start_offset+finish_offset][0] = sequence.length-1;
      seqs[0+start_offset+finish_offset][1] = sequence.length-1;
    }
    // seqs[1][0] = best_subseq_start;
    // seqs[1][1] = best_subseq_end;
    shuffle_genes_around_subsequences(seqs);
    calculate_path_length();
  }

  void shuffle_genes_around_subsequences(int[][] subsequences) {
    int total_subsequences_length = 0;
    for (int i = 0; i<subsequences.length; i++) 
    {
      subsequences[i][2] = subsequences[i][1]-subsequences[i][0]+1;
      total_subsequences_length += subsequences[i][2];
    }
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
    tint(255, opacity);
    if (animation_frame>=0&&animation_frame<sequence.length+98) {
      for (int i=0; i<animation_frame; i++) {
        stroke(255-255*(float)i/sequence.length*(float)i/sequence.length, 
          255*(float)i/sequence.length, 
          0, 
          80+170*max(0, i-animation_frame+50)/50);
        if (i<sequence.length-1)
        line(nodes[sequence[i]].position.x+wm.position.x, 
          nodes[sequence[i]].position.y+wm.position.y, 
          nodes[sequence[i+1]].position.x+wm.position.x, 
          nodes[sequence[i+1]].position.y+wm.position.y);
      }
      animation_frame++;
    } else {
      image(lines, wm.position.x, wm.position.y);
    }
  }

  // int subsequence_skip(int index, int subse){

  // }
}
