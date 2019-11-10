class Contour {

  ArrayList<Point> points; // массив масштабированных пикселей контура
  ArrayList<Dir> dirs;
  int cols, rows;

  Contour() {
    points = new ArrayList<Point>();
    dirs = new ArrayList<Dir>();
    dirs.add(Dir.RIGHT);
    dirs.add(Dir.UP);
    dirs.add(Dir.LEFT);
    dirs.add(Dir.DOWN);
    cols = width/scale;
    rows = height/scale;
  }

  void addPoint(float x, float y) {
    Point p = new Point(floor(x/scale), floor(y/scale), color(0));
    points.add(p);
  }

  void display() {
    if (points.size() == 1) {
      Point p = points.get(0);
      plot(p.coord.x, p.coord.y, p.col);
      return;
    }
    for (int i = 0; i < points.size()-1; i++) {
      Point a = points.get(i);
      Point b = points.get(i+1);
      vecBresenham(a.coord.x, a.coord.y, b.coord.x, b.coord.y);
    }
  }

  // выводит масштабированный пиксель
  void plot(int x, int y, color c) {
    loadPixels();
    int startX = x * scale;
    int startY = y * scale;
    int endX = startX + scale;
    int endY = startY + scale;
    for (int py = startY; py < endY; py++) {
      for (int px = startX; px < endX; px++) {
        int index = py * width + px;
        pixels[index] = c;
      }
    }
    updatePixels();
  }

  void plot(float x, float y, color c) {
    plot(int(x), int(y), c);
  }

  void plot(Point p, color c) {
    plot(p.coord.x, p.coord.y, c);
  }  

  void vecBresenham(int x1, int y1, int x2, int y2) {
    int x = x1;
    int y = y1;
    int dx = abs(x2 - x1);
    int dy = abs(y2 - y1);
    int s1 = sign(x2 - x1);
    int s2 = sign(y2 - y1);
    boolean swap = false;
    if (dy > dx) {
      int temp = dx;
      dx = dy;
      dy = temp;
      swap = true;
    }
    int e = 2 * dy - dx;
    for (int i = 1; i <= dx; i++) {
      plot(x, y, color(0));
      while (e >= 0) {
        if (swap) {
          x += s1;
        } else {
          y += s2;
        }
        e = e - 2 * dx;
      }
      if (swap) {
        y += s2;
      } else {
        x += s1;
      }
      e = e + 2 * dy;
    }
  }

  int sign(int val) {
    if (val < 0) {
      return -1;
    } else if (val > 0) {
      return 1;
    } else {
      return 0;
    }
  }

  void vecBresenham(float x1, float y1, float x2, float y2) {
    vecBresenham(int(x1), int(y1), int(x2), int(y2));
  }

  // заливает замкнутый контур. Подробнее http://expace.narod.ru/imageprocessing/algoritm.html
  void fillClosed(boolean showOuter) {
    if (points.isEmpty()) return;
    // индекс текущего направления
    int di;
    Dir curDir, nextDir = null;
    Point first, current, next = null;
    ArrayList<Point> outer = new ArrayList<Point>();

    // сканируем изображение для попадание на любую точку контура
    loadPixels();
    // первая найденная точка "внешнего" контура
    first = findFirstPoint(); //<>//
    if (first == null) {
      return;
    }
    
    outer.add(first);

    plot(first, first.col);
    current = first;
    di = 0;

    while (true) {
      curDir = dirs.get(di);
      if (curDir == Dir.RIGHT) {
        next = getPoint(current.coord.x + 1, current.coord.y);
        nextDir = Dir.DOWN;
      } else if (curDir == Dir.UP) {
        next = getPoint(current.coord.x, current.coord.y - 1);
        nextDir = Dir.RIGHT;
      } else if (curDir == Dir.LEFT) {
        next = getPoint(current.coord.x - 1, current.coord.y);
        nextDir = Dir.UP;
      } else { // if (curDir == Dir.DOWN) {
        next = getPoint(current.coord.x, current.coord.y + 1);
        nextDir = Dir.LEFT;
      }
      if (next.isBlack()) {
        di = (di + 1) % dirs.size();
        continue;
      }
      current = next;
      di = dirs.indexOf(nextDir);
      //if (current.equals(first)) {
      if (current.coord.x == first.coord.x && current.coord.y == first.coord.y) { 
        break;
      }
      
      outer.add(current);
      
      plot(current, color(0, 255, 0));
    }
    
    for (int row = 0; row < rows; row++) {
      fillRow(row);
    }
    
    if (!showOuter) {
      for (Point p : outer) {
        plot(p, color(255));
      }
    }

    updatePixels();
  }

  Point findFirstPoint() {
    for (int y = 0; y < height; y += scale) {
      for (int x = 0; x < width; x += scale) {
        int ind = y * width + x;
        color cur = pixels[ind];
        Point p = new Point(x/scale, y/scale, cur);
        if (p.isBlack()) {
          return new Point(p.coord.x - 1, p.coord.y, color(0, 255, 0));
        }
      }
    }
    return null;
  }
  
  Point getPoint(float x, float y) {
    color c = pixels[int(y) * scale * width + int(x) * scale];
    return new Point(x, y, c);
  }
  
  void fillRow(int r) {
    ArrayList<Point> greens = new ArrayList<Point>();
    ArrayList<Point> buffer = new ArrayList<Point>();
    ArrayList<ArrayList<Point>> buffers = new ArrayList<ArrayList<Point>>();
    boolean blackFound;
    
    for (int c = 0; c < cols; c++) {
      Point p = getPoint(c, r);
            
      if (p.isGreen()) {
        if (!greens.isEmpty()) {
          buffers.add(buffer);
          buffer = new ArrayList<Point>();
        }
        greens.add(p);
      } else if (!greens.isEmpty()) {
        buffer.add(p);
      }
    }
        
    for (ArrayList<Point> buf : buffers) {
      blackFound = false;
      for (Point p : buf) {
        if (p.isBlack()) {
          blackFound = true;
        } else if (blackFound) {
          plot(p, color(200, 0, 100));
        }
      }      
    }
    
  }
}
