class WalkerManager {
  boolean wm_toggled = false;
  GeneticWalker[] walkers;
  GeneticWalker tester;

  PVector position;
  controlP5.Controller[] walker_handlers;
  ControlPanel wm_panel;

  WalkerManager() {
    walkers = new GeneticWalker[128];
    create_controllers();
  }

  void controlEvent(ControlEvent theEvent) {
    if (wm_toggled) wm_panel.move_to.y = 0; 
    else wm_panel.move_to.y = height+2; 
  }

  void create_walkers() {
    for (int i = 0; i < walkers.length; ++i) walkers[i] = new GeneticWalker(nm.nodes); 
    walkers_unleashed=true;
    update();
  }

  void update(){
    walkers = mergesort_walkers(walkers);
    // for (int i =0; i<walkers.length; i++) {
    //   println(i+" "+walkers[i].distance);
    // }
  }

  void draw() {
    wm_panel.draw();
    // if (walkers_unleashed) {
    //   GeneticWalker best_walker = null;
    //   float best_path = walkers[0].distance;
    //   for (GeneticWalker gw : walkers) {
    //     if (gw.distance<best_path) {
    //       best_walker = gw;
    //       best_path = gw.distance;
    //     }
    //   }
    //   if (best_walker.lines == null) best_walker.generate_lines();
    //   best_walker.draw();
    // }
    if (walkers_unleashed) walkers[0].draw();
  }

  void create_controllers() {
    wm_panel = new ControlPanel(1,1,wm_active_controls_color);
    position = wm_panel.position;
    walker_handlers = new controlP5.Controller[1]; 
    walker_handlers[0] = cp5.addButton("create_walkers")
      .setPosition(wm_panel.controls_starting_x + (wm_panel.control_width+wm_panel.control_padding_x)* 0, 
      wm_panel.controls_starting_y + (wm_panel.control_height+wm_panel.control_padding_y)*0)
      .setSize(wm_panel.control_width, wm_panel.control_height)
      .setColorBackground(wm_background_color)
      .setColorForeground(wm_foreground_color)
      .setColorActive(wm_active_controls_color)
      .plugTo(this);
    walker_handlers[0].getCaptionLabel().setSize(24);
    wm_panel.controllers = walker_handlers;
  }

  void wm_toggle() {
    wm_toggled = !wm_toggled;
    // fm_switch.setState(false);
    // wm_switch.setState(false);
  }

  GeneticWalker[] mergesort_walkers(GeneticWalker[] current_split){
    // println("poot");
    if (current_split.length>1) {
      GeneticWalker [] left_side = new GeneticWalker[current_split.length/2];
      for (int i = 0; i<left_side.length; i++) left_side[i] = current_split[i];
      GeneticWalker [] right_side = new GeneticWalker[current_split.length/2];
      for (int i = 0; i<right_side.length; i++) right_side[i] = current_split[i+left_side.length];
      left_side = mergesort_walkers(left_side);
      right_side = mergesort_walkers(right_side);
      int left_index = 0;
      int right_index = 0;
      for (int i = 0; i<left_side.length+right_side.length; i++){
        if ((right_index>=right_side.length)
          ||(left_index<left_side.length)
          &&(left_side[left_index].distance<right_side[right_index].distance)) 
          {
            current_split[i] = left_side[left_index];
            // print(current_split[i].distance+" ");
            left_index++;
          } else {
            current_split[i] = right_side[right_index];
            // print(current_split[i].distance+" ");
            right_index++;
          }
          // println();
      }
    }
    return current_split;
  }
}
