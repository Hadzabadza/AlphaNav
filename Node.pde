class Node {
  PVector position;
  float radius;
  int mass = 0;

  Node(PVector _position, int _mass) {
    position = _position.copy();
    radius = calculate_radius(_mass);
    mass = _mass;
  } 

  void draw(PVector offset) {
    noFill();
    stroke(0, 255, 0, round(130+40*sin(float(frameCount)/50)));
    strokeWeight(2);
    ellipse(position.x+offset.x, position.y+offset.y, radius*2, radius*2);
    strokeWeight(1);
  }

  Node check_collision_with_node(Node other) {
    if (other==this) return null;
    if (mass<other.mass) if (dist(position.x, position.y, other.position.x, other.position.y)<other.radius) return this; else return null;
    else if (dist(position.x, position.y, other.position.x, other.position.y)<radius) return other; else return null;
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
  
  float calculate_radius(int mass){
    return sqrt(mass/1.5);
  }
}
