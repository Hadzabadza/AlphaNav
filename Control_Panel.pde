class ControlPanel {
  controlP5.Controller [] controllers;

  int control_width;
  int control_height;
  int control_padding_x;
  int control_padding_y;
  int controls_starting_x;
  int controls_starting_y;

  PVector position;
  PVector move_to = new PVector(0, 0);
  float move_speed = 0.1;

  color bounds_color;

  ControlPanel(int columns, int rows, color _bounds_color){
    int free_vertical_space = height - origin.h;

    position = new PVector(origin.position.x, height);
    move_to = position.copy();

    control_width = width/round(columns*1.5);
    control_height = min(control_width/6, free_vertical_space/2);

    control_padding_x = control_width/2;
    control_padding_y = min(control_height, (free_vertical_space-control_height*rows)/(rows+1));

    controls_starting_x = (width-(columns*control_width+(columns-1)*control_padding_x))/2;
    controls_starting_y = round(position.y) + origin.h + control_padding_y;

    bounds_color = _bounds_color;
  }

  void draw(){
    if (position.x!=move_to.x || position.y!=move_to.y) move_panel(); 
    draw_bounds(int(position.x), int(position.y), origin.w, origin.h, bounds_color);  
  }

  void move_panel() {
    PVector move_diff = position.copy().lerp(move_to, move_speed); 
    move_diff.sub(position); 
    for (int i=0; i<controllers.length; i++) {
      float[] pos = controllers[i].getPosition(); 
      pos[0]+=move_diff.x; 
      pos[1]+=move_diff.y; 
      controllers[i].setPosition(pos);
    }
    position.add(move_diff);
  }
}
