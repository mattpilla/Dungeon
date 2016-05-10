/**
* class for burning box
*/
class Fire {
  Boolean _exists = false;
  float _fX, _fY;
  ArrayList<PImage> _images;
  
  Fire() {
    _images = $sprites.getFireSprites();
  }
  
  void unleash(float fX, float fY) {
    _exists = true;
    _fX = fX;
    _fY = fY;
  }
  
  Boolean exists() {
    return _exists;
  }
  
  void withdraw() {
    _exists = false;
  }
  
  void update() {
    if (_exists) {
      image(_images.get(millis()/150 % 2),_fX,_fY);
    }
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
      return touch(_fX,x,w) && touch(_fY,y,h);
    }
    return false;
  }
}
