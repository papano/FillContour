class Point {
  
  PVector coord;
  color col;
  
  Point(float x, float y, color col) {
    coord = new PVector(int(x), int(y));
    this.col = col;
  }
  
  boolean isBlack() {
    // учитываем альфа канал
    return (col & 0xFFFFFFFF) == 0xFF000000;
  }
  
  boolean isGreen() {
    // учитываем альфа канал
    return (col & 0xFFFFFFFF) == 0xFF00FF00;
  }
  
  
}
