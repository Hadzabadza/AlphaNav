class MainMap {
  PVector position;
  PImage map;
  PGraphics map_screen;
  PGraphics blend_screen;
  int w, h;

  MainMap(String name) {
    map = loadImage(sketchPath("data\\"+name));
    position= new PVector ((width-map.width)/2, 0);
    w = map.width;
    h = map.height;
  }

  void draw() {
    image(map, position.x, position.y);
    draw_bounds();
  }
  
  void draw_blend_screen(){
    image(blend_screen, position.x, position.y);
    draw_bounds();
  }
  
  void draw_bounds() {
    noFill();
    stroke(255);
    rect(position.x-1, position.y, w+2, h+2);
  }
}
