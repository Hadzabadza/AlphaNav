class WalkerManager {
  boolean wm_toggled = false;
  GeneticWalker[] walkers;
  GeneticWalker tester;

  WalkerManager() {
    walkers = new GeneticWalker[100];
  }
  void wm_toggle() {
    wm_toggled = !wm_toggled;
    // fm_switch.setState(false);
    // nm_switch.setState(false);
  }

  void create_walkers() {
    for (int i = 0; i < walkers.length; ++i) walkers[i] = new GeneticWalker(nm.nodes); 
    tester = new GeneticWalker(nm.nodes);
    println(tester.sequence.length);
    for (int i = 0; i<tester.sequence.length; i++) print(tester.sequence[i]+" ");
    println();
    int[][] subseqs = new int[3][3];

    subseqs[0][0] = 22;
    subseqs[0][1] = 31;
    subseqs[1][0] = 42;
    subseqs[1][1] = 51;
    subseqs[2][0] = 62;
    subseqs[2][1] = 71;

    tester.shuffle_genes_around_subsequences(subseqs);
    for (int i = 0; i<tester.sequence.length; i++) print(tester.sequence[i]+" ");
    println();
    walkers_unleashed=true;
  }

  void draw() {
    if (walkers_unleashed) {
      GeneticWalker best_walker = null;
      float best_path = walkers[0].distance;
      for (GeneticWalker gw : walkers) {
        if (gw.distance<best_path) {
          best_walker = gw;
          best_path = gw.distance;
        }
      }
      if (best_walker.lines == null) best_walker.generate_lines();
      best_walker.draw();
    }
  }
}
