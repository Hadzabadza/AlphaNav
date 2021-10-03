class MainMap {
  PVector position;
  PImage map;
  PGraphics map_screen;
  int w, h;

  MainMap(String name) {
    map = loadImage(sketchPath("data\\"+name));
    position= new PVector ((width-map.width)/2, 0);
    w = map.width;
    h = map.height;
  }

  void draw() {
    image(map, position.x, position.y);
    draw_bounds(int(position.x), int(position.y), w, h);
  }
}
