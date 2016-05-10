/**
* class for push blocks
*/
class PushBlock {
  Boolean _exists = false;
  int _xDir = 0, _yDir = 0;
  float _bX, _bY;
  ArrayList<PImage> _images;
  int _frame = 0;
  int _lim;
  
  PushBlock() {
    _images = $sprites.getBlockSprites();
  }
  
  void explode(Boolean fire) {
    if (_frame < 5) {
      if (millis()/125 != _lim) {
        _lim = millis()/125;
        _frame++;
      }
      return;
    }
    if (fire == true) {
      $fire.unleash(_bX,_bY);
    }
    _frame = 0;
    _exists = false;
  }
  void explode() {
    explode(false);
  }
  
  void unleash(float bX, float bY) {
    _exists = true;
    _bX = bX;
    _bY = bY;
  }
  
  Boolean exists() {
    return _exists;
  }
  
  void withdraw() {
    _frame = 0;
    _exists = false;
  }
  
  void update() {
    if (_exists) {
      image(_images.get(_frame),_bX,_bY);
      Tile[][] tBounds = $tileMap.getBounds(_bX,_bY,$tSize,$tSize);
      Tile[][] oBounds = $objMap.getBounds(_bX,_bY,$tSize,$tSize);
      tileCases(tBounds,_xDir,_yDir);
      tileCases(oBounds,_xDir,_yDir);
    }
  }
  
  float x() {
    return _bX;
  }
  
  float y() {
    return _bY;
  }
  
  void push(int xDir, int yDir, float speed) {
    _xDir = xDir;
    _yDir = yDir;
    float nextX = _bX;
    float nextY = _bY;
    nextX += _xDir*speed;
    nextY += _yDir*speed;
    Tile[][] bounds = $tileMap.getBounds(nextX,nextY,$tSize,$tSize);
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        if (bounds[i][j].isBlock()) {
          nextX = _bX;
          nextY = _bY;
        }
      }
    }
    _bX = nextX;
    _bY = nextY;
  }
  
  Boolean touch(float axis, float axis2, int len) {
    if ((axis <= axis2 && axis + $tSize-1 >= axis2) ||
        (axis <= axis2+len-1 && axis + $tSize-1 >= axis2+len-1)) {
      return true;
    }
    return false;
  }
  
  Boolean isTouching(float x, float y, int w, int h) {
    if (_exists) {
      return touch(_bX,x,w) && touch(_bY,y,h);
    }
    return false;
  }
  
  /**
  * handles interacting with tile types
  */
  void tileCases(Tile[][] bounds, int xDir, int yDir) {
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        bounds[i][j].interact("block",i,xDir,yDir);
      }
    }
  }
}
