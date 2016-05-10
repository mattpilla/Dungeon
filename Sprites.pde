class Sprites {
  ArrayList<ArrayList<PImage>> _tiles;
  ArrayList<ArrayList<PImage>> _objects;
  ArrayList<ArrayList<PImage>> _girls;
  ArrayList<PImage> _blocks;
  ArrayList<PImage> _flames;
  
  Sprites() {
    _tiles = new ArrayList<ArrayList<PImage>>();
    String fileName = "images/tile0a.png";
    File file = new File(dataPath(fileName));
    int i = 0;
    char c = 'a';
    while(file.exists()) {
      _tiles.add(new ArrayList<PImage>());
      while (file.exists()) {
        _tiles.get(i).add(loadImage(fileName));
        c++;
        fileName = "images/tile"+i+c+".png";
        file = new File(dataPath(fileName));
      }
      c = 'a';
      i++;
      fileName = "images/tile"+i+c+".png";
      file = new File(dataPath(fileName));
    }
    
    _objects = new ArrayList<ArrayList<PImage>>();
    fileName = "images/object0a.png";
    file = new File(dataPath(fileName));
    i = 0;
    c = 'a';
    while(file.exists()) {
      _objects.add(new ArrayList<PImage>());
      while (file.exists()) {
        _objects.get(i).add(loadImage(fileName));
        c++;
        fileName = "images/object"+i+c+".png";
        file = new File(dataPath(fileName));
      }
      c = 'a';
      i++;
      fileName = "images/object"+i+c+".png";
      file = new File(dataPath(fileName));
    }
    
    _blocks = new ArrayList<PImage>();
    fileName = "images/block0a.png";
    file = new File(dataPath(fileName));
    c = 'a';
    while (file.exists()) {
      _blocks.add(loadImage(fileName));
      c++;
      fileName = "images/block"+0+c+".png";
      file = new File(dataPath(fileName));
    }
    
    _flames = new ArrayList<PImage>();
    fileName = "images/object4a.png";
    file = new File(dataPath(fileName));
    c = 'a';
    while (file.exists()) {
      _flames.add(loadImage(fileName));
      c++;
      fileName = "images/object"+4+c+".png";
      file = new File(dataPath(fileName));
    }
    
    _girls = new ArrayList<ArrayList<PImage>>();
    fileName = "images/sprite0a.png";
    file = new File(dataPath(fileName));
    i = 0;
    c = 'a';
    while(file.exists()) {
      _girls.add(new ArrayList<PImage>());
      while (file.exists()) {
        _girls.get(i).add(loadImage(fileName));
        c++;
        fileName = "images/sprite"+i+c+".png";
        file = new File(dataPath(fileName));
      }
      c = 'a';
      i++;
      fileName = "images/sprite"+i+c+".png";
      file = new File(dataPath(fileName));
    }
  }
  
  ArrayList<PImage> getSprites(String type, char index) {
    int i;
    if (index >= 'A') {
      i = index - 55;
    }
    else {
      i = index - 48;
    }
    if (type =="tile") {
      return _tiles.get(i);
    }
    return _objects.get(i);
  }
  
  ArrayList<PImage> getBlockSprites() {
    return _blocks;
  }
  
  ArrayList<PImage> getFireSprites() {
    return _flames;
  }
  
  ArrayList<ArrayList<PImage>> getGirlSprites() {
    return _girls;
  }
}
