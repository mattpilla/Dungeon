/**
 * class for push blocks
 */
class PushBlock {
    Boolean _exists = false;
    int _xDir = 0, _yDir = 0;
    float _x, _y;
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
            $fire.unleash(_x, _y);
        }
        _frame = 0;
        _exists = false;
    }

    void explode() {
        explode(false);
    }

    void unleash(float bX, float bY) {
        _exists = true;
        _x = bX;
        _y = bY;
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
            image(_images.get(_frame), _x, _y);
            Tile[][] tBounds = $tileMap.getBounds(_x, _y, $tSize, $tSize);
            Tile[][] oBounds = $objMap.getBounds(_x, _y, $tSize, $tSize);
            tileCases(tBounds);
            tileCases(oBounds);
        }
    }

    float x() {
        return _x;
    }

    float y() {
        return _y;
    }

    void push(int xDir, int yDir, float speed) {
        _xDir = xDir;
        _yDir = yDir;
        float nextX = _x;
        float nextY = _y;
        nextX += _xDir*speed;
        nextY += _yDir*speed;
        Tile[][] bounds = $tileMap.getBounds(nextX, nextY, $tSize, $tSize);
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                if (bounds[i][j].isBlock()) {
                    nextX = _x;
                    nextY = _y;
                }
            }
        }
        _x = nextX;
        _y = nextY;
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
            return touch(_x, x, w) && touch(_y, y, h);
        }
        return false;
    }

    /**
     * handles interacting with tile types
     */
    void tileCases(Tile[][] bounds) {
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                bounds[i][j].interact("block");
            }
        }
    }
}