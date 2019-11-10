int scale = 8; // масштаб пикселя
enum Dir { 
  RIGHT, UP, LEFT, DOWN
};
Contour contour;

void setup() {
  size(2000, 1600, P2D);
  contour = new Contour();
}

void draw() {
  background(255);
  contour.display();
  contour.fillClosed(true);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (mouseX > scale - 1      && 
        mouseX < width - scale  && 
        mouseY > scale - 1      && 
        mouseY < height - scale
      ) {
      contour.addPoint(mouseX, mouseY);
    }
  }
}
