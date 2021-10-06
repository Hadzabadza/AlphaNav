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
    walkers = mergesort_walkers(walkers);
  }

  void nextgen(){
    for (int i=1; i<100; i++) {
      float copy_level = float(max(10, i-4))/100;
      walkers[i].splice_genes(walkers[0], copy_level);
    }
    for (int i=100; i<walkers.length; i++) walkers[i].generate_path();
    walkers = mergesort_walkers(walkers);
  }

  void draw() {
    wm_panel.draw();
    if (walkers_unleashed) {
      // walkers[0].draw();
      fill(wm_active_controls_color);
      for (int i=0; i<10; i++) {
        if (i>0) walkers[i].draw(50);
        else walkers[i].draw(250);
        text(walkers[i].distance, position.x+origin.w, position.y+20+i*24);
      }
      tint(255);
      nextgen();
    }
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
