/**
* class for stick item
*/
class Stick {
  Boolean _exists = false;
  float _sX, _sY;
  int _xDir, _yDir;
  int _index;
  PImage[][] _images;
  
  Stick() {
    _images = new PImage[8][2];
    for (int i = 0; i < 8; i++) {
      for (char c = 'a'; c < 'c'; c++) {
        _images[i][c-97] = loadImage("images/stick"+i+c+".png");
      }
    }
  }
  
  void unleash(int index, int xDir, int yDir, float x, float y) {
    $canStick = false;
    _exists = true;
    _sX = x;
    _sY = y;
    _index = index;
    _xDir = xDir;
    _yDir = yDir;
  }
  
  Boolean exists() {
    return _exists;
  }
  
  void withdraw() {
    _exists = false;
  }
  
  /**
  * pulls up next frame for animation
  */
  int animate() {
    return (millis()/150 % 2);
  }
  
  void update() {
    if (_exists) {
      image(_images[_index][animate()],_sX,_sY);
      _sX += _xDir*8;
      _sY += _yDir*8;
      if (_sX >= width || _sX+$tSize < 0) {
        _exists = false;
      }
      if (_sY >= height || _sY+$tSize < 0) {
        _exists = false;
      }
      Tile[][] tBounds = $tileMap.getBounds(_sX,_sY,getW(),getH());
      Tile[][] oBounds = $objMap.getBounds(_sX,_sY,getW(),getH());
      tileCases(tBounds,_xDir,_yDir);
      tileCases(oBounds,_xDir,_yDir);
      if ($fire.isTouching(_sX,_sY,getW(),getH())) {
        if (_index < 4) {
          _index += 4;
        }
      }
      if ($block.isTouching(_sX,_sY,getW(),getH())) {
        $block.explode();
        if (_index >= 4) {
          $fire.unleash($block.x(),$block.y());
          $block.withdraw();
        }
        $stick.withdraw();
      }
    }
  }
  
  int getW() {
    if (_index < 2) {
      return 36;
    }
    return 14;
  }
  
  int getH() {
    if (_index < 2) {
      return 14;
    }
    return 36;
  }
  
  int getIndex() {
    return _index;
  }
  
  void incIndex(int x) {
    _index += x;
  }
  
  void setDir(int xDir, int yDir) {
    _xDir = xDir;
    _yDir = yDir;
    int a;
    if (xDir == -1) {
      a = 0;
    }
    else if (xDir == 1) {
      a = 1;
    }
    else if (yDir == -1) {
      a = 2;
    }
    else {
      a = 3;
    }
    _index = (_index/4 *4)+a;
  }
  
  /**
  * handles interacting with tile types
  */
  void tileCases(Tile[][] bounds, int xDir, int yDir) {
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        bounds[i][j].interact("stick",i,xDir,yDir);
      }
    }
  }
}
