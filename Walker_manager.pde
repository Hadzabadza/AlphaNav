class WalkerManager {
  boolean wm_toggled = false;
  GeneticWalker[] walkers;

  GeneticWalker test_subject;
  int manual_index = 0;

  PVector position;
  PVector wm_mouse; 
  controlP5.Controller[] walker_handlers;
  ControlPanel wm_panel;

  boolean manual_walker;
  boolean mouse_in_area = false;

  WalkerManager() {
    // walkers = new GeneticWalker[1];
    wm_mouse = new PVector(0,0);
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
    test_subject = new GeneticWalker(nm.nodes);
    walkers = mergesort_walkers(walkers);
  }

  void nextgen() {
    // for (int i=1; i<100; i++) {
    //   float copy_level = float(max(10, i-4))/100;
    //   walkers[i].splice_genes(walkers[0], copy_level);
    // }
    // for (int i=100; i<walkers.length; i++) walkers[i].generate_sequence();
    for (int i=1; i<walkers.length; i++) walkers[i].generate_sequence();
    walkers = mergesort_walkers(walkers);
  }

  GeneticWalker[] mergesort_walkers(GeneticWalker[] current_split) {
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
      for (int i = 0; i<left_side.length+right_side.length; i++) {
        if ((right_index>=right_side.length)
          ||(left_index<left_side.length)
          &&(left_side[left_index].distance<right_side[right_index].distance)) 
        {
          current_split[i] = left_side[left_index];
          left_index++;
        } else {
          current_split[i] = right_side[right_index];
          right_index++;
        }
      }
    }
    return current_split;
  }

  void animate_fittest() {
    if (walkers_unleashed) walkers[0].animation_frame=0;
  }

  void mouseEvent() {
    if (walkers_unleashed){
      if (mouseButton==CENTER) {
        for (int i=0; i<test_subject.sequence.length; i++){
          walkers[0].sequence[i]=test_subject.sequence[i];
        }
        walkers[0].calculate_path_length();
        walkers[0].generate_lines();

      }
      if (manual_walker && nm.highlighted!=null && mouse_in_area) {
        if (mouseButton==RIGHT){
          boolean removed_node = false;
          int last_non_empty = -1;
          for (int i=0; i<test_subject.sequence.length; i++)
          {
            if (nm.highlighted.id==test_subject.sequence[i]) removed_node = true;
            if (removed_node) if (i<test_subject.sequence.length-1) test_subject.sequence[i]=test_subject.sequence[i+1];
              else test_subject.sequence[i]=-1;
            if (test_subject.sequence[i]!=-1) last_non_empty = i;
          }
          if (!removed_node && last_non_empty>-1) test_subject.sequence[last_non_empty] = -1;
        }
        if (mouseButton==LEFT){
          int first_empty=-1;
          boolean node_already_in = false;
          for (int i=0; i<test_subject.sequence.length; i++)
          {
            if (test_subject.sequence[i]==nm.highlighted.id) node_already_in = true;
            if (test_subject.sequence[i]==-1 && first_empty==-1) first_empty=i;
          }
          if (first_empty!=-1 && !node_already_in) test_subject.sequence[first_empty]=nm.highlighted.id;
        }
      }
      test_subject.calculate_path_length();
      test_subject.generate_lines();
    }
  }

  void draw() {
    wm_panel.draw();
    if (manual_walker) 
    {
      recalculate_mouse_relative_to_position(wm_mouse, position);
      mouse_in_area = mouse_in_area(wm_mouse.x,wm_mouse.x,origin.w,origin.h);
      nm.highlighted = nm.get_node_near_mouse(wm_mouse);
      nm.highlighted.highlight(position, color(255));
      test_subject.draw(255);
      text(test_subject.distance, position.x+origin.w, position.y+20);
    } else {
      if (walkers_unleashed) {
        if (wm_panel.is_moving||wm_toggled) {
          fill(wm_active_controls_color);
          walkers[0].draw(200);
          for (int i=0; i<(min(10,walkers.length)); i++) {
            // if (i>0) walkers[i].draw(50);
            // else walkers[i].draw(250);
            text(walkers[i].distance, position.x+origin.w, position.y+20+i*24);
          }
          tint(255);
        }
        nextgen();
      }
    }
  }

  void create_controllers() {
    wm_panel = new ControlPanel(3, 1, wm_active_controls_color);
    walker_handlers = new controlP5.Controller[3]; 
    position = wm_panel.position;
    walker_handlers[0] = cp5.addButton("create_walkers")
      .setPosition(wm_panel.controls_starting_x + (wm_panel.control_width+wm_panel.control_padding_x)* 0, 
      wm_panel.controls_starting_y + (wm_panel.control_height+wm_panel.control_padding_y)*0)
      .setSize(wm_panel.control_width, wm_panel.control_height)
      .setColorBackground(wm_background_color)
      .setColorForeground(wm_foreground_color)
      .setColorActive(wm_active_controls_color)
      .plugTo(this);
    walker_handlers[0].setCaptionLabel("Create walkers");
    walker_handlers[0].getCaptionLabel().setSize(24);

    walker_handlers[1] = cp5.addButton("animate_fittest")
      .setPosition(wm_panel.controls_starting_x + (wm_panel.control_width+wm_panel.control_padding_x)* 1, 
      wm_panel.controls_starting_y + (wm_panel.control_height+wm_panel.control_padding_y)*0)
      .setSize(wm_panel.control_width, wm_panel.control_height)
      .setColorBackground(wm_background_color)
      .setColorForeground(wm_foreground_color)
      .setColorActive(wm_active_controls_color)
      .plugTo(this);
    walker_handlers[1].setCaptionLabel("Animate fittest");
    walker_handlers[1].getCaptionLabel().setSize(24);

    walker_handlers[2] = cp5.addToggle("manual_walker")
      .setPosition(wm_panel.controls_starting_x + (wm_panel.control_width+wm_panel.control_padding_x)* 2, 
      wm_panel.controls_starting_y + (wm_panel.control_height+wm_panel.control_padding_y)*0)
      .setSize(wm_panel.control_width, wm_panel.control_height)
      .setColorBackground(wm_background_color)
      .setColorForeground(wm_foreground_color)
      .setColorActive(wm_active_controls_color)
      .plugTo(this);
    walker_handlers[2].setCaptionLabel("Manual walker");
    walker_handlers[2].getCaptionLabel().setSize(24);
    walker_handlers[2].getCaptionLabel().align(CENTER, CENTER);

    wm_panel.controllers = walker_handlers;
  }

  void wm_toggle() {
    wm_toggled = !wm_toggled;
    // fm_switch.setState(false);
    // wm_switch.setState(false);
  }
}
