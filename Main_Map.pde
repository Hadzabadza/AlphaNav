class MainMap {
  PVector position;
  PImage map;
  PGraphics map_screen;
  int w, h;

  MainMap(String name) {
    map = loadImage(sketchPath("data\\"+name));
    paddingX = (width-map.width)/2;
    paddingY = 0;
    position= new PVector (paddingX, paddingY);
    w = map.width;
    h = map.height;
  }

  void draw() {
    image(map, position.x, position.y);
    draw_bounds(int(position.x), int(position.y), w, h, main_map_bounds_color);
  }
}
