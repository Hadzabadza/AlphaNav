class Node {
  PVector position;
  float radius;
  int id;
  int mass = 0;
  float[] distances_to_nodes;
  float[] ordered_distance_ids;
  float[][] dist_zip;
  HashMap<Integer,Float> hashed_distances;
  float maxDist, minDist;

  Node(PVector _position, int _mass) {
    position = _position.copy();
    radius = calculate_radius(_mass);
    mass = _mass;
  } 

  Node check_collision_with_node(Node other) {
    if (other==this) return null;
    if (mass<other.mass) if (dist(position.x, position.y, other.position.x, other.position.y)<other.radius) return this; 
    else return null;
    else if (dist(position.x, position.y, other.position.x, other.position.y)<radius) return other; 
    else return null;
  }

  void merge_nodes(Node other) {
    position.add(other.position);
    position.div(2);
    mass+=other.mass;
    radius = calculate_radius(mass);
  }

  Node attempt_to_remove_collided_node(Node other) {
    Node collision_victim = check_collision_with_node(other);
    if (collision_victim!=null) {
      if (collision_victim == this) other.merge_nodes(this);
      else merge_nodes(other);
      return collision_victim;
    } else return null;
  }

  float calculate_radius(int mass) {
    return sqrt(mass/1.5);
  }

  void calculate_and_sort_distances_to_nodes(Node[] nodes) {
    distances_to_nodes = new float[nodes.length];
    minDist = Float.MAX_VALUE;
    maxDist = 0;
    for (int i=0; i<nodes.length; i++) 
    {
      distances_to_nodes[i] = dist(position.x, position.y, nodes[i].position.x, nodes[i].position.y);
      if (distances_to_nodes[i]>maxDist) maxDist = distances_to_nodes[i];
      if (distances_to_nodes[i]<minDist||distances_to_nodes[i]!=0) minDist = distances_to_nodes[i];
    }
    dist_zip = initiate_distances_sorting(distances_to_nodes);
  }

  void highlight(PVector offset, color c) {
    noFill();
    stroke(c);
    float frame_offset = float(frameCount)/10;
    for (int i=0; i<12; i+=4) arc(position.x+offset.x, position.y+offset.y, radius*2+4, radius*2+4, PI/6*(i+1)+frame_offset, PI/6*(i+2)+frame_offset);
  }

  void draw_distances_zip(float x, float y, float w, float h) {
    for (int i=0; i<dist_zip.length; i++) {
      float nodes_percentage = dist_zip[i][1]/dist_zip.length;
      // println(dist_zip[i][1], dist_zip.length, nodes_percentage);
      float power = dist_zip[i][0]/maxDist;
      color node_distance_color = color(
        255-125*sin(PI*nodes_percentage), 
        255-255*(1-nodes_percentage)*(1-nodes_percentage), 
        255*(sin(PI*nodes_percentage*5)));
      // 255-125*power);
      fill(node_distance_color);
      stroke(node_distance_color);
      rect(x+nm.position.x+i*nm.candle_width+i*nm.paddingX+nm.offsetX, 
        y+nm.paddingY+nm.position.y+nm.candle_height, 
        nm.candle_width, 
        -nm.candle_height*(power));
      if (nm.show_distances) {
        line(position.x+nm.position.x, position.y+nm.position.y, nm.nodes[int(dist_zip[i][1])].position.x+nm.position.x, nm.nodes[int(dist_zip[i][1])].position.y+nm.position.y);
      }
    }
    stroke(255);
    float lineX = nm.position.x+x;
    float lineY = nm.position.y+y+h/2;
    line(lineX+5, lineY, lineX+nm.offsetX-5, lineY);
    line(lineX+nm.distances_panel_dimensions.x-5, lineY, lineX+nm.distances_panel_dimensions.x-nm.offsetX+5, lineY);
  }

    void draw_distances(float x, float y, float w, float h) {
    for (int i=0; i<distances_to_nodes.length; i++) {
      float nodes_percentage = float(i)/distances_to_nodes.length;
      float power = distances_to_nodes[i]/maxDist;
      color node_distance_color = color(
        255-125*sin(PI*nodes_percentage), 
        255-255*(1-nodes_percentage)*(1-nodes_percentage), 
        255*(sin(PI*nodes_percentage*5)));
      // 255-125*power);
      fill(node_distance_color);
      stroke(node_distance_color);
      rect(x+nm.position.x+i*nm.candle_width+i*nm.paddingX+nm.offsetX, y+nm.paddingY+nm.position.y+nm.candle_height, nm.candle_width, -nm.candle_height*(distances_to_nodes[i]/maxDist));
      if (nm.show_distances) {
        noSmooth();
        line(position.x+nm.position.x, position.y+nm.position.y, nm.nodes[i].position.x+nm.position.x, nm.nodes[i].position.y+nm.position.y);
        smooth();
      }
    }
    stroke(255);
    float lineX = nm.position.x+x;
    float lineY = nm.position.y+y+h/2;
    line(lineX+5, lineY, lineX+nm.offsetX-5, lineY);
    line(lineX+nm.distances_panel_dimensions.x-5, lineY, lineX+nm.distances_panel_dimensions.x-nm.offsetX+5, lineY);
  }

  void draw(PVector offset) {
    noFill();
    stroke(0, 255, 0, round(130+40*sin(float(frameCount)/50)));
    strokeWeight(2);
    ellipse(position.x+offset.x, position.y+offset.y, radius*2, radius*2);
    strokeWeight(1);
  }

  float[][] initiate_distances_sorting(float[] initial_set){
    // distance_ids = new float[distances_to_nodes.length];
    float [][] distance_zipper= new float[distances_to_nodes.length][2];
    for (int i=0; i<distances_to_nodes.length; i++){
      distance_zipper[i][0] = distances_to_nodes[i];
      distance_zipper[i][1] = i;
    }
    distance_zipper = mergesort_distances(distance_zipper);
    return distance_zipper;
  }

  float[][] mergesort_distances(float[][] current_split){
    if (current_split.length>1) { //<>//
      float[][] left_side = new float[ceil(float(current_split.length)/2)][2];
      for (int i = 0; i<left_side.length; i++) 
        {
          left_side[i][0] = current_split[i][0];
          left_side[i][1] = current_split[i][1];
        }
      float[][] right_side = new float[current_split.length/2][2];
      for (int i = 0; i<right_side.length; i++) 
        {
          right_side[i][0] = current_split[i+left_side.length][0];
          right_side[i][1] = current_split[i+left_side.length][1];
        }
      left_side = mergesort_distances(left_side);
      right_side = mergesort_distances(right_side);
      int left_index = 0;
      int right_index = 0;
      for (int i = 0; i<left_side.length+right_side.length; i++){
        if ((right_index>=right_side.length)
          ||(left_index<left_side.length)
          &&(left_side[left_index][0]<right_side[right_index][0])) 
          {
            current_split[i][0] = left_side[left_index][0];
            current_split[i][1] = left_side[left_index][1];
            // print(current_split[i].distance+" ");
            left_index++;
          } else {
            current_split[i][0] = right_side[right_index][0];
            current_split[i][1] = right_side[right_index][1];
            // print(current_split[i].distance+" ");
            right_index++;
          }
          // println();
      }
    }
    return current_split;
  }
}
