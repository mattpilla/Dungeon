/**
* class for background maps
*/
class TileMap {
  int _rowPos, _colPos; //position of current tilemap, for use when scrolling
  Tile[][] _tiles, _tiles2; //2d array of tiles that make up the map
  String _type; //type of map
  
  TileMap(String type, int total) {
    _type = type;
    _tiles = new Tile[$rows][$cols];
    refresh();
  }
  
  int getRowPos() {
    return _rowPos;
  }
  
  int getColPos() {
    return _colPos;
  }
  
  /**
  * resets the tilemap
  */
  void refresh() {
    _tiles = getTiles();
    _rowPos = $rowMap;
    _colPos = $colMap;
  }
  
  Boolean nextBlockMagnet(int xMag, int yMag, float x, float y, int w, int h) {
    int x1 = floor(x/$tSize);
    int x2 = floor((x+w-1)/$tSize);
    int y1 = floor(y/$tSize);
    int y2 = floor((y+h-1)/$tSize);
    if (xMag == 1) {
      while (x2 < $cols) {
        if ($block.isTouching(x2*$tSize,y,w,h)) {
          return false;
        }
        if (_tiles[y1][x2].isBlock() || _tiles[y2][x2].isBlock()) {
          if (_tiles[y1][x2].index() == '9' || _tiles[y2][x2].index() == '9') {
            return true;
          }
          return false;
        }
        x2++;
      }
    }
    else if (xMag == -1) {
      while (x1 >= 0) {
        if ($block.isTouching(x1*$tSize,y,w,h)) {
          return false;
        }
        if (_tiles[y1][x1].isBlock() || _tiles[y2][x1].isBlock()) {
          if (_tiles[y1][x1].index() == '9' || _tiles[y2][x1].index() == '9') {
            return true;
          }
          return false;
        }
        x1--;
      }
    }
    else if (yMag == 1) {
      while (y2 < $rows) {
        if ($block.isTouching(x,y2*$tSize,w,h)) {
          return false;
        }
        if (_tiles[y2][x1].isBlock() || _tiles[y2][x2].isBlock()) {
          if (_tiles[y2][x1].index() == '9' || _tiles[y2][x2].index() == '9') {
            return true;
          }
          return false;
        }
        y2++;
      }
    }
    else {
      while (y1 >= 0) {
        if ($block.isTouching(x,y1*$tSize,w,h)) {
          return false;
        }
        if (_tiles[y1][x1].isBlock() || _tiles[y1][x2].isBlock()) {
          if (_tiles[y1][x1].index() == '9' || _tiles[y1][x2].index() == '9') {
            return true;
          }
          return false;
        }
        y1--;
      }
    }
    return false;
  }
  
  /**
  * creates 2d array of tiles
  */
  Tile[][] getTiles() {
    String[] tileMap;
    String fileName = "txt/"+_type+"Map"+$rowMap+","+$colMap+".map";
    File file = new File(dataPath(fileName));
    if (file.exists()) {
      tileMap = loadStrings(fileName);
    }
    else {
      tileMap = loadStrings("txt/"+_type+"MapError.map");
    }
    Tile[][] tiles = new Tile[$rows][$cols];
    for (int i = 0; i < $rows; i++) {
      for (int j = 0; j < $cols; j++) {
        tiles[i][j] = new Tile(_type, tileMap[i].charAt(j), j*$tSize, i*$tSize);
      }
    }
    if (_type == "tile") {
      for (int i = $rows; i < $rows+3; i++) {
        $bg[i-$rows] = Integer.parseInt(tileMap[i]);
      }
    }
    return tiles;
  }
  
  /**
  * draw the background of the map
  */
  void updateBG() {
    for (int i = 0; i < $rows; i++) {
      for (int j = 0; j < $cols; j++) {
        _tiles[i][j].paint(j*$tSize,i*$tSize);
      }
    }
  }
  
  /**
  * scrolling animation
  */
  void scroll() {
    int deltaX = $colMap - _colPos;
    int deltaY = $rowMap - _rowPos;
    if ($frame >= abs(deltaY*$rows)+abs(deltaX*$cols)) {
      $frame = -1;
      _rowPos = $rowMap;
      _colPos = $colMap;
      $objMap.refresh();
      $girl.saveRoomEntry();
      $mode = "play";
    }
    else {
      if ($frame == 0) {
        _tiles2 = getTiles();
        $girl.incX(deltaX*$tSize);
        $girl.incY(deltaY*$tSize);
      }
      if (deltaX == -1) {
        scrollLeft();
      }
      else if (deltaX == 1) {
        scrollRight();
      }
      else if (deltaY == 1) {
        scrollDown();
      }
      else {
        scrollUp();
      }
      updateBG();
      $girl.incX(-1*deltaX*$tSize);
      $girl.incY(-1*deltaY*$tSize);
      $girl.updateSprite();
    }
  }
  
  void scrollLeft() {
    for (int i = $cols-1; i > 0; i--) {
      for (int j = 0; j < $rows; j++) {
        _tiles[j][i] = _tiles[j][i-1];
      }
    }
    for (int i = 0; i < $rows; i++) {
      _tiles[i][0] = _tiles2[i][$cols-1-$frame];
    }
  }
  
  void scrollRight() {
    for (int i = 0; i < $cols-1; i++) {
      for (int j = 0; j < $rows; j++) {
        _tiles[j][i] = _tiles[j][i+1];
      }
    }
    for (int i = 0; i < $rows; i++) {
      _tiles[i][$cols-1] = _tiles2[i][$frame];
    }
  }
  
  void scrollUp() {
    for (int i = $rows-1; i > 0; i--) {
      for (int j = 0; j < $cols; j++) {
        _tiles[i][j] = _tiles[i-1][j];
      }
    }
    for (int i = 0; i < $cols; i++) {
      _tiles[0][i] = _tiles2[$rows-1-$frame][i];
    }
  }
  
  void scrollDown() {
    for (int i = 0; i < $rows-1; i++) {
      for (int j = 0; j < $cols; j++) {
        _tiles[i][j] = _tiles[i+1][j];
      }
    }
    for (int i = 0; i < $cols; i++) {
      _tiles[$rows-1][i] = _tiles2[$frame][i];
    }
  }
  
  /**
  * gives tile type at each corner of sprite
  */
  Tile[][] getBounds(float x, float y, float w, float h) {
    Tile[][] bounds = new Tile[2][2];
    int x1 = floor(x/$tSize);
    int x2 = floor((x+w-1)/$tSize);
    int y1 = floor(y/$tSize);
    int y2 = floor((y+h-1)/$tSize);
    if (x1 < 0) {
      x1 = x2 = 0;
    }
    if (x2 >= $cols) {
      x2 = x1 = $cols-1;
    }
    if (y1 < 0) {
      y1 = y2 = 0;
    }
    if (y2 >= $rows) {
      y2 = y1 = $rows - 1;
    }
    bounds[0][0] = _tiles[y1][x1];
    bounds[0][1] = _tiles[y1][x2];
    bounds[1][0] = _tiles[y2][x1];
    bounds[1][1] = _tiles[y2][x2];
    return bounds;
  }
}
