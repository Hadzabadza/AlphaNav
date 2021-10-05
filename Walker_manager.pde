class WalkerManager {
  GeneticWalker pops;
  boolean wm_toggled = false;

  WalkerManager() {
    
  }
  void wm_toggle() {
    wm_toggled = !wm_toggled;
    // fm_switch.setState(false);
    // nm_switch.setState(false);
  }
}
