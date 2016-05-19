/**
 * Main character class
 */
class Girl {
    ArrayList<ArrayList<PImage>> _sprites; //character sprites
    int _index, _indexRoom, _indexInit; //current sprite
    int _width, _height; //size of sprite
    float _xRoom, _yRoom;
    float _xInit, _yInit; //saved locations of girl
    int _rowMapInit = 0, _colMapInit = 0; //saved map location of girl
    float _x, _y; //character position
    float _oSpeed; //original speed
    float _speed = 0; //controls how fast character moves
    String _direction = "down";
    Boolean _moving = false;
    int _frame = -1;
    int _lim;
    float _accel = 0.2;
    int _pastXDir, _pastYDir;

    Girl(int w, int h, int x, int y, float speed) {
        _width = w;
        _height = h;
        _index = _indexRoom = _indexInit = 2;
        _x = _xRoom = _xInit = x;
        _y = _yRoom = _yInit = y;
        _oSpeed = speed;
        _sprites = $sprites.getGirlSprites();
        _pastXDir = _pastYDir = 0;
    }

    void fall() {
        if (_frame < 8) {
            if (_frame < 0 || millis()/125 != _lim) {
                _lim = millis()/125;
                _frame++;
            }
            image(_sprites.get(4).get(_frame), _x, _y, _width, _height);
        }
    }

    void resetFrame() {
        _frame = -1;
    }

    /**
     * pulls up next frame for animation
     */
    int animate(int sprite) {
        if (_moving) {
            return (millis()/150 % _sprites.get(sprite).size());
        }
        return 0;
    }

    /**
     * draw updated character sprite
     */
    void updateSprite(int i) {
        if (($action[0] && $zText == "PUSH") || $canSave ||  $canSwitch) {
            if ($gSwitch) {
                tint(255, 255, 0);
            } else {
                tint(0, 255, 255);
            }
        }
        if (_direction == "down") {
            image(_sprites.get(i).get(animate(i)), _x, _y, _width, _height);
        } else if (_direction == "up") {
            goUp();
        } else if (_direction == "left") {
            goLeft(-1);
        } else {
            goRight();
        }
        noTint();
    }

    void updateSprite() {
        updateSprite(_index);
    }

    void stick() {
        if (_index < 5) {
            _index += 9;
        }
        if (_index < 9) {
            _index += 4;
        }
        int[] mags = getMag(_index-9);
        int a = 0, b = 0;
        if (_index-9 < 2) {
            a = _width;
            b = (_height-14)/2;
        } else {
            a = _width/2-7;
            b = _height;
        }
        if (_index-9 == 0) {
            a = -1*a;
        } else if (_index-9 == 2) {
            b = -1*b;
        }
        if (!$stick.exists() && $canStick) {
            $stick.unleash(_index-9, mags[0], mags[1], _x+a, _y+b);
        }
        Tile[][] tBounds = $tileMap.getBounds(_x, _y, _width, _height);
        tileCases(tBounds);
        Tile[][] oBounds = $objMap.getBounds(_x, _y, _width, _height);
        tileCases(oBounds);
    }

    void magnet() {
        if (_index > 8) {
            _index -= 4;
        }
        if (_index < 5) {
            _index += 5;
        }
        int[] mags = getMag(_index-5);
        if ($tileMap.nextBlockMagnet(mags[0], mags[1], _x, _y, _width, _height)) {
            incX(mags[0]*16);
            incY(mags[1]*16);
        } else {
            Tile[][] tBounds = $tileMap.getBounds(_x, _y, _width, _height);
            tileCases(tBounds);
        }
        Tile[][] oBounds = $objMap.getBounds(_x, _y, _width, _height);
        tileCases(oBounds);
    }

    int[] getMag(int index) {
        int[] mags = new int[2];
        int xMag = 0, yMag = 0;
        switch (index) {
            case 0:
                if (_direction == "right" || _direction == "left") {
                    yMag = -1;
                } else {
                    xMag = -1;
                }
                break;
            case 1:
                if (_direction == "right" || _direction == "left") {
                    yMag = 1;
                } else {
                    xMag = 1;
                }
                break;
            case 2:
                if (_direction == "down") {
                    yMag = -1;
                } else if ( _direction == "up") {
                    yMag = 1;
                } else if (_direction == "right") {
                    xMag = -1;
                } else {
                    xMag = 1;
                }
                break;
            case 3:
                if (_direction == "down") {
                    yMag = 1;
                } else if ( _direction == "up") {
                    yMag = -1;
                } else if (_direction == "right") {
                    xMag = 1;
                } else {
                    xMag = -1;
                }
                break;
        }
        mags[0] = xMag;
        mags[1] = yMag;
        return mags;
    }

    void setDirection(String direction) {
        _direction = direction;
    }

    void goUp() {
        pushMatrix();
        translate(0, _height);
        scale(1.0, -1.0);
        image(_sprites.get(_index).get(animate(_index)), _x, -_y, _width, _height);
        popMatrix();
    }

    void goLeft(int xDir) {
        pushMatrix();
        translate(_width/2, _height/2);
        rotate(PI/2);
        translate(-_width/2, -_height/2);
        image(_sprites.get(_index).get(animate(_index)), _y, xDir*_x, _width, _height);
        popMatrix();
    }

    void goRight() {
        pushMatrix();
        translate(_width, 0);
        scale(-1.0, 1.0);
        goLeft(1);
        popMatrix();
    }

    /**
     * increases x position of girl
     */
    void incX(float amount) {
        float nextX = _x + amount;
        Tile[][] tBoundsX = $tileMap.getBounds(nextX, _y, _width, _height);
        _x = checkX(floor(amount/abs(amount)), tBoundsX, nextX);
    }

    /**
     * increases y position of girl
     */
    void incY(float amount) {
        float nextY = _y + amount;
        Tile[][] tBoundsY = $tileMap.getBounds(_x, nextY, _width, _height);
        _y = checkY(floor(amount/abs(amount)), tBoundsY, nextY);
    }

    void setPos(float x, float y) {
        _x = x+($tSize-_width)/2;
        _y = y+($tSize-_height)/2;
    }

    /**
     * checks future x, y position, and sets current x, y to an acceptable position
     */
    void updateXY(int xDir, int yDir) {
        $zText = "ACTION";
        if ($fire.isTouching(_x, _y, _width, _height)) {
            $mode = "dead";
        }
        if ($magnet == 2) {
            magnet();
        } else if ($nStick == 2) {
            stick();
        } else {
            if (_index > 8) {
                _index -= 4;
            }
            if (_index > 4) {
                _index -= 5;
            }
            if ((_pastXDir*-1 == xDir && yDir == 0) || (_pastYDir*-1 == yDir && xDir == 0)) {
                _speed = 0;
            }
            _pastXDir = xDir;
            _pastYDir = yDir;
            if (xDir == 0 && yDir == 0) {
                _moving = false;
            } else {
                _moving = true;
            }
            float nextX = _x + xDir*_speed, nextY = _y + yDir*_speed;
            if (yDir != 0) {
                nextX = _x + xDir*sqrt(sq(_speed)/2);
            }
            if (xDir != 0) {
                nextY = _y + yDir*sqrt(sq(_speed)/2);
            }
            Tile[][] tBoundsX = $tileMap.getBounds(nextX, _y, _width, _height);
            Tile[][] oBoundsX = $objMap.getBounds(nextX, _y, _width, _height);
            speedUp();
            if (xDir != 0) {
                if (xDir == -1) {
                    switch (_direction.charAt(0)) {
                        case 'u':
                        case 'd':
                            _index = 0;
                            break;
                        case 'l':
                            _index = 3;
                            break;
                        case 'r':
                            _index = 2;
                    }
                } else {
                    switch (_direction.charAt(0)) {
                        case 'u':
                        case 'd':
                            _index = 1;
                            break;
                        case 'l':
                            _index = 2;
                            break;
                        case 'r':
                            _index = 3;
                    }
                }
                _x = checkX(xDir, tBoundsX, nextX);
            }
            tileCases(tBoundsX);
            tileCases(oBoundsX);
            Tile[][] tBoundsY = $tileMap.getBounds(_x, nextY, _width, _height);
            Tile[][] oBoundsY = $objMap.getBounds(_x, nextY, _width, _height);
            if (yDir != 0) {
                if (yDir == -1) {
                    switch (_direction.charAt(0)) {
                        case 'l':
                        case 'r':
                            _index = 0;
                            break;
                        case 'u':
                            _index = 3;
                            break;
                        case 'd':
                            _index = 2;
                            break;
                    }
                } else {
                    switch (_direction.charAt(0)) {
                        case 'l':
                        case 'r':
                            _index = 1;
                            break;
                        case 'u':
                            _index = 2;
                            break;
                        case 'd':
                            _index = 3;
                            break;
                    }
                }
                _y = checkY(yDir, tBoundsY, nextY);
            }
            tileCases(tBoundsY);
            tileCases(oBoundsY);
        }
    }

    float checkX(int xDir, Tile[][] tBoundsX, float nextX) {
        Boolean push = $block.isTouching(nextX, _y, _width, _height);
        if (xDir == -1) {
            if (floor(nextX/$tSize) < 0 && $tileMap.getColPos() == $colMap) {
                $colMap--;
                $mode = "scroll";
                return 0;
            }
            if (push) {
                $zText = "PUSH";
                if ($action[0] && !(tBoundsX[0][0].isBlock() || tBoundsX[1][0].isBlock())) {
                    $block.push(-1, 0, 0.8);
                }
                nextX = $block.x()+$tSize;
            } else if (tBoundsX[0][0].isBlock() || tBoundsX[1][0].isBlock()) {
                nextX = (floor(nextX/$tSize)+1)*$tSize;
            }
        } else {
            if (floor((nextX+$tSize-1)/$tSize) > $cols-1 && $tileMap.getColPos() == $colMap) {
                $colMap++;
                $mode = "scroll";
                return nextX;
            }
            if (push) {
                $zText = "PUSH";
                if ($action[0]) {
                    $block.push(1, 0, 0.8);
                }
                nextX = $block.x()-_width;
            }
            if (tBoundsX[0][1].isBlock() || tBoundsX[1][1].isBlock()) {
                nextX = floor(nextX/$tSize)*$tSize+($tSize-_width);
            }
        }
        return nextX;
    }

    float checkY(int yDir, Tile[][] tBoundsY, float nextY) {
        Boolean push = $block.isTouching(_x, nextY, _width, _height);
        if (yDir == -1) {
            if (floor(nextY/$tSize) < 0 && $tileMap.getRowPos() == $rowMap) {
                $rowMap--;
                $mode = "scroll";
                return 0;
            }
            if (push) {
                $zText = "PUSH";
                if ($action[0] && !(tBoundsY[0][0].isBlock() || tBoundsY[0][1].isBlock())) {
                    $block.push(0, -1, 0.8);
                }
                nextY = $block.y()+$tSize;
            } else if (tBoundsY[0][0].isBlock() || tBoundsY[0][1].isBlock()) {
                nextY = (floor(nextY/$tSize)+1)*$tSize;
            }
        } else {
            if (floor((nextY+$tSize-1)/$tSize) > $rows-1 && $tileMap.getRowPos() == $rowMap) {
                $rowMap++;
                $mode = "scroll";
                return nextY;
            }
            if (push) {
                $zText = "PUSH";
                if ($action[0]) {
                    $block.push(0, 1, 0.8);
                }
                nextY = $block.y()-_height;
            }
            if (tBoundsY[1][0].isBlock() || tBoundsY[1][1].isBlock()) {
                nextY = floor(nextY/$tSize)*$tSize+($tSize-_height);
            }
        }
        return nextY;
    }

    /**
     * handles interacting with tile types
     */
    void tileCases(Tile[][] bounds) {
        Boolean gravity = false;
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                bounds[i][j].interact("girl");
                if (bounds[i][j].isGravityPanel()) {
                    gravity = true;
                }
            }
        }
        if (!gravity) {
            setDirection("down");
        }
    }

    void speedUp() {
        if (!_moving) {
            _speed = 0;
        } else {
            _speed += _accel;
            if (_speed > _oSpeed) {
                _speed = _oSpeed;
            }
        }
    }

    /**
     * saves progress of girl
     */
    void savePos() {
        _xInit = _x;
        _yInit = _y;
        _indexInit = _index;
        _rowMapInit = $rowMap;
        _colMapInit = $colMap;
    }

    /**
     * handles respawn of girl
     */
    void loadPos() {
        _x = _xInit;
        _y = _yInit;
        _index = _indexInit;
        $rowMap = _rowMapInit;
        $colMap = _colMapInit;
    }

    void saveRoomEntry() {
        _xRoom = _x;
        _yRoom = _y;
        _indexRoom = _index;
    }

    void loadRoomEntry() {
        _x = _xRoom;
        _y = _yRoom;
        _index = _indexRoom;
    }
}