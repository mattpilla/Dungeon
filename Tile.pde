/**
 * class for Tiles
 */
class Tile {
    String _type; //type of tile
    char _index; //number of tile
    char _indexInit;
    float _tX, _tY;
    ArrayList<PImage> _frame; //list of frames for tile
    int _lim;

    Tile(String type, char index, float tX, float tY) {
        _indexInit = index;
        if (type == "object" && index == 'X') {
            $block.unleash(tX, tY);
            index = '0';
        }
        if (type == "object" && index == 'S') {
            if ($gSwitch) {
                index = '8';
            } else {
                index = '7';
            }
        }
        _type = type;
        _index = index;
        _tX = tX;
        _tY = tY;
        _frame = $sprites.getSprites(_type, _index);
    }

    /**
     * gives tile number
     */
    char index() {
        return _index;
    }

    Boolean isBlock() {
        if (_type == "tile") {
            if (_index == '1' || _index == '9') {
                return true;
            }
        }
        return false;
    }

    Boolean isGravityPanel() {
        if (_type == "tile") {
            if (_index < '4' || _index > '7') {
                return false;
            }
        }
        return true;
    }

    Boolean hitbox(int top, int side, int bottom) {
        if ($girl._y + $girl._height > _tY + top && $girl._y < _tY + $tSize - bottom) {
            if ($girl._x < _tX && _tX+side < $girl._x + $girl._width) { //left
                return true;
            }
            if ($girl._x+$girl._width > _tX+$tSize && _tX+$tSize-side > $girl._x) { //right
                return true;
            }
        }
        if ($girl._x + $girl._width > _tX + side && $girl._x < _tX + $tSize - side) {
            if ($girl._y < _tY && _tY+top < $girl._y + $girl._height) { //up
                return true;
            }
            if ($girl._y+$girl._height > _tY+$tSize && _tY+$tSize-bottom > $girl._y) { //down
                return true;
            }
        }
        return false;
    }

    Boolean boxHitbox(int side) {
        if ($block._y + $tSize > _tY + side && $block._y < _tY + $tSize - side) {
            if ($block._x < _tX && _tX+side < $block._x + $tSize) { //left
                return true;
            }
            if ($block._x+$tSize > _tX+$tSize && _tX+$tSize-side > $block._x) { //right
                return true;
            }
        }
        if ($block._x + $tSize > _tX + side && $block._x < _tX + $tSize - side) {
            if ($block._y < _tY && _tY+side < $block._y + $tSize) { //up
                return true;
            }
            if ($block._y+$tSize > _tY+$tSize && _tY+$tSize-side > $block._y) { //down
                return true;
            }
        }
        return false;
    }

    void tileManage() {
        if (_type == "tile") {
            if (_index == '0') {
                if ($gSwitch) {
                    tint($bg[2], $bg[1], $bg[0]);
                } else {
                    tint($bg[0], $bg[1], $bg[2]);
                }
            }
            if ($gSwitch) {
                if (_indexInit == '4' && _index == '4') {
                    transform('5');
                } else if (_indexInit == '5' && _index == '5') {
                    transform('4');
                } else if (_indexInit == '6' && _index == '6') {
                    transform('7');
                } else if (_indexInit == '7' && _index == '7') {
                    transform('6');
                }
            } else {
                if (_indexInit == '5' && _index == '4') {
                    transform('5');
                }
                else if (_indexInit == '4' && _index == '5') {
                    transform('4');
                }
                else if (_indexInit == '7' && _index == '6') {
                    transform('7');
                }
                else if (_indexInit == '6' && _index == '7') {
                    transform('6');
                }
            }
        } else {
            if (_index == '3' && $magnet > 0) {
                transform('0');
            } else if (_index == '6' && $nStick > 0) {
                transform('0');
            }
        }
    }

    /**
     * draws tile to screen
     */
    void paint(float x, float y) {
        tileManage();
        int a = animate();
        image(_frame.get(a), x, y, $tSize, $tSize);
        noTint();
    }

    void paint() {
        paint(_tX, _tY);
    }

    /**
     * pulls up next frame for animation
     */
    int animate() {
        return (millis()/150 % _frame.size());
    }

    /**
    * decides action based on type and number
    */
    void interact(String actor) {
        if (actor == "girl") {
            if (_type == "tile") {
                switch (_index) {
                    case '0': //normal floor
                        break;
                    case '1': //wall
                        break;
                    case '4': //right gravity panel
                        $girl.incX(1.5);
                        $girl.setDirection("right");
                        break;
                    case '5': //left gravity panel
                        $girl.incX(-1.5);
                        $girl.setDirection("left");
                        break;
                    case '6': //down gravity panel
                        $girl.incY(1.5);
                        $girl.setDirection("down");
                        break;
                    case '7': //up gravity panel
                        $girl.incY(-1.5);
                        $girl.setDirection("up");
                        break;
                    case '9': //magnet block
                        break;
                    case '2': //void
                        if (hitbox(10, 13, 17)) {
                            $girl.setPos(_tX, _tY);
                            $mode = "fall";
                        }
                        break;
                    case '3': //voided block
                        break;
                }
            } else {
                switch (_index) {
                    case '0': //no object
                        break;
                    case '1': //mine
                        if (hitbox(2, 5, 10)) {
                            $mode = "dead";
                        }
                        break;
                    case '2': //save point
                        if (hitbox(7, 10, 15)) {
                            $zText = "SAVE";
                            if ($action[0] && $canSave) {
                                $girl.savePos();
                                $girl.saveRoomEntry();
                            }
                        }
                        break;
                    case '3': //magnet item
                        if (hitbox(4, 7, 12)) {
                            $magnet = 1;
                            $girl.savePos();
                            $girl.saveRoomEntry();
                            transform('0');
                        }
                        break;
                    case '4': //fire
                        if (hitbox(7, 10, 15)) {
                            $mode = "dead";
                        }
                        break;
                    case '5': //ice
                        if (hitbox(2, 5, 10)) {
                            $mode = "dead";
                        }
                        break;
                    case '6': //stick item
                        if (hitbox(2, 5, 10)) {
                            $nStick = 1;
                            $girl.savePos();
                            $girl.saveRoomEntry();
                            transform('0');
                        }
                        break;
                    case '7': //blue gravity switch
                        if (hitbox(2, 5, 10)) {
                            $zText = "SWITCH";
                            if ($action[0] && $canSwitch) {
                                $canSwitch = false;
                                $gSwitch = true;
                                transform('8');
                                $girl.savePos();
                            }
                        }
                        break;
                    case '8': //red gravity switch
                        if (hitbox(2, 5, 10)) {
                            $zText = "SWITCH";
                            if ($action[0] && $canSwitch) {
                                $canSwitch = false;
                                $gSwitch = false;
                                transform('7');
                                $girl.savePos();
                            }
                        }
                        break;
                    case '9':
                        if (hitbox(7, 10, 15)) {
                            $girl.setPos(_tX, _tY);
                            $mode = "done";
                        }
                        break;
                    case 'A': //weak floor
                    case 'B':
                    case 'C':
                    case 'D':
                        if (hitbox(7, 10, 15) && millis()/150 != _lim) {
                            _lim = millis()/150;
                            transform(++_index);
                        }
                        break;
                    case 'E':
                        if (hitbox(7, 10, 15) && millis()/150 != _lim) {
                            _lim = millis()/150;
                            transform("tile", '2');
                        }
                        break;
                }
            }
        } else if (actor == "stick") {
            if (_type == "tile") {
                switch (_index) {
                    case '1': //wall
                        $stick.withdraw();
                        break;
                    case '4': //right gravity panel
                        $stick.setDir(1, 0);
                        break;
                    case '5': //left gravity panel
                        $stick.setDir(-1, 0);
                        break;
                    case '6': //down gravity panel
                        $stick.setDir(0, 1);
                        break;
                    case '7': //up gravity panel
                        $stick.setDir(0, -1);
                        break;
                    case '9': //magnet block
                        $stick.withdraw();
                        break;
                }
            } else {
                switch (_index) {
                    case '1': //mine
                        break;
                    case '4': //fire
                        if ($stick.getIndex() < 4) {
                            $stick.incIndex(4);
                        }
                        break;
                    case '5': //ice
                        if ($stick.getIndex() >= 4) {
                            transform('0');
                        }
                        $stick.withdraw();
                        break;
                }
            }
        } else if (actor == "block") {
            if (_type == "tile") {
                switch (_index) {
                    case '4': //right gravity panel
                        $block.push(1, 0, 3);
                        break;
                    case '5': //left gravity panel
                        $block.push(-1, 0, 3);
                        break;
                    case '6': //down gravity panel
                        $block.push(0, 1, 3);
                        break;
                    case '7': //up gravity panel
                        $block.push(0, -1, 3);
                        break;
                    case '2': //void
                        if (boxHitbox(17)) {
                            $block.withdraw();
                            transform('3');
                        }
                        break;
                }
            } else {
                switch (_index) {
                    case '1': //mine
                        $block.explode();
                        transform('0');
                        break;
                    case '4': //fire
                        $block.explode(true);
                        break;
                    case '5': //ice
                        $block.explode();
                        break;
                    case 'A': //weak floor
                    case 'B':
                    case 'C':
                    case 'D':
                    case 'E':
                        $block.withdraw();
                        transform("tile", '2');
                        break;
                }
            }
        }
    }

    void transform(char index) {
        _index = index;
        _frame = $sprites.getSprites(_type, _index);
    }

    void transform(String type, char index) {
        _type = type;
        transform(index);
    }
}
