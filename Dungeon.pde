/**
 *************************************************
 * dungeon, ok
 *
 * Main class
 * might add things to this. not particularly
 * interested in code comment style as opposed to
 * what it has to say so i intentionally make the asterisks
 * not line up
 *****************************************
 */

/**
 * imports
 */
import processing.sound.*;

/**
 * global variables
 * - variables beginning with $ are global variables
 * - variables also ending with _ are instance variables of other classes. easy
 */
SoundFile $music;
float $amp; //volume level for music
Sprites $sprites;
Boolean[] $dir = new Boolean[4]; //keyboard directions
int $xPriority, $yPriority; //determines which direction on the axis was done first
Boolean[] $action = new Boolean[4]; //other inputs (z, x, c);
int[] $bg; //color holder
Girl $girl; //instance of main character
Stick $stick;
PushBlock $block;
Fire $fire;
TileMap $tileMap; //controls the tilemaps in the background
TileMap $objMap; //controls the objects on top of the tilemaps
Timer $gameTimer;
Timer $deathTimer;
Boolean $canSave;
Boolean $canStick;
Boolean $gSwitch;
Boolean $canSwitch;
Boolean $initSwitch;
int $magnet;
int $nStick;
PImage $start;
PImage $end;
PImage $loading;
PImage $banner;
PImage $magnetIcon;
PImage $stickIcon;
PImage $border;
PImage $zAction;
String $zText;
String $time;

/**
 * Mode Names:
 * reset: resets the game to start screen
 * play: normal gameplay
 * scroll: screen is scrolling in a transition between 2 tilemaps
 * dead: game over transition
 * fall: falling into a void
 * done: beat the game OK
 */
String $mode; //game behaves differently depending on the mode

int $frame; //counts frames to time duration of modes
int $lim; //limits amount of times _frame is incremented

/**
 * dependent on TileMap, for use of other classes
 */
int $tSize; //size of background tiles
int $rows, $cols; //amount of rows and columns of background
int $rowMap, $colMap; //location of tile map

void setup() {
    $sprites = new Sprites();
    $tSize = 36; //size of background tiles
    $rows = 12;
    $cols = 16; //amount of rows and columns of background
    $amp = 0.5;
    $music = new SoundFile(this, "sounds/dungeon.mp3");
    $music.amp($amp);
    restart();
    size(576, 504); //sets window size based on map size
    $start = loadImage("images/start.png");
    $end = loadImage("images/end.png");
    $banner = loadImage("images/banner.png");
    $border = loadImage("images/border.png");
    $magnetIcon = loadImage("images/object3a.png");
    $stickIcon = loadImage("images/object6a.png");
    $zAction = loadImage("images/zAction.png");
}

void draw() {
    if ($mode == "reset") {
        image($start, 0, 0);
        textSize(10);
        text("2012\nMatt Pilla\nMusic by Bobby Kevilovski", 20, 455);
        if ($action[0]) {
            $music.loop();
            $mode = "play";
            $gameTimer.start();
        }
    }
    if ($mode == "play") {
        $tileMap.updateBG();
        $objMap.updateBG();
        $fire.update();
        $stick.update();
        $girl.updateSprite();
        $girl.updateXY(xVal(), yVal());
        if ($magnet > 0) {
            $magnet = 1;
            if ($action[2]) {
                $magnet = 2;
            }
        }
        if ($nStick > 0) {
            $nStick = 1;
            if ($action[1]) {
                $nStick = 2;
            } else {
                $canStick = true;
            }
        }
        if ($zText == "SAVE" && !$action[0]) {
            $canSave = true;
        } else {
            $canSave = false;
        }
        if ($zText == "SWITCH" && !$action[0]) {
            $canSwitch = true;
        } else {
            $canSwitch = false;
        }
    } else if ($mode == "scroll" && millis()/40 % 2 != $lim) {
        $fire.withdraw();
        $block.withdraw();
        $stick.withdraw();
        $lim = millis()/40 % 2;
        $tileMap.scroll();
        $frame++;
    } else if ($mode == "dead") {
        $stick.withdraw();
        $block.withdraw();
        $fire.withdraw();
        background(0);
        if (millis()/70 % 2 == 0) {
            tint(255, 0, 0);
        } else {
            tint(0, 255, 0);
        }
        $girl.fall();
        if (!$deathTimer.start()) {
            $deathTimer.reset();
            $girl.resetFrame();
            $girl.loadPos();
            $girl.saveRoomEntry();
            $tileMap.refresh();
            $objMap.refresh();
            $mode = "play";
        }
    } else if ($mode == "fall") {
        $stick.withdraw();
        $tileMap.updateBG();
        $objMap.updateBG();
        $fire.update();
        $girl.fall();
        if (!$deathTimer.start()) {
            $deathTimer.reset();
            $girl.resetFrame();
            $girl.loadRoomEntry();
            $mode = "play";
        }
    }
    if ($mode != "reset") {
        noTint();
        $block.update();
        image($banner, 0, 432);
        image($zAction, 230, 448);
        image($border, 456, 440);
        image($border, 525, 440);
        textSize(20);
        fill(255);
        text("TIME: "+$gameTimer.readTime(), 36, 474);
        text($zText, 273, 474);
        text("X", 471, 500);
        text("C", 540, 500);
        if ($magnet > 0) {
            image($magnetIcon, 529, 444);
        }
        if ($nStick > 0) {
            image($stickIcon, 460, 444);
        }
        if ($mode == "done") {
            $tileMap.updateBG();
            $objMap.updateBG();
            $girl.fall();
            if (!$deathTimer.start()) {
                if ($time == "") {
                    $time = $gameTimer.readTime();
                }
                end();
            }
        }
    }
}

void keyPressed() {
    if (key == CODED) {
        if (keyCode == LEFT) {
            $dir[0] = true;
            $xPriority = 1;
        }
        if (keyCode == RIGHT) {
            $dir[1] = true;
            $xPriority = -1;
        }
        if (keyCode == UP) {
            $dir[2] = true;
            $yPriority = 1;
        }
        if (keyCode == DOWN) {
            $dir[3] = true;
            $yPriority = -1;
        }
    } else {
        char k = Character.toLowerCase(key);
        if (k == 'z') {
            $action[0] = true;
        }
        if (k == 'x') {
            $action[1] = true;
        }
        if (k == 'c') {
            $action[2] = true;
        }
    }
}

void keyReleased() {
    if (key == CODED) {
        if (keyCode == LEFT) {
            $dir[0] = false;
        }
        if (keyCode == RIGHT) {
            $dir[1] = false;
        }
        if (keyCode == UP) {
            $dir[2] = false;
        }
        if (keyCode == DOWN) {
            $dir[3] = false;
        }
    } else {
        char k = Character.toLowerCase(key);
        if (k == 'z') {
            $action[0] = false;
        }
        if (k == 'x') {
            $action[1] = false;
        }
        if (k == 'c') {
            $action[2] = false;
        }
        if (k == 'r') {
            restart();
        }
    }
}

/**
 * gives direction
 */
int xVal() {
    if ($dir[0] && $dir[1]) {
        return $xPriority;
    }
    return $dir[0]? -1:($dir[1]? 1:0);
}

/**
 * gives direction
 */
int yVal() {
    if ($dir[2] && $dir[3]) {
        return $yPriority;
    }
    return $dir[2]? -1:($dir[3]? 1:0);
}

void stop() {
    $music.stop();
    super.stop();
}

void end() {
    $music.stop();
    image($end, 0, 0);
    fill(0, 255, 0);
    text("TIME: "+$time, 36, 474);
    fill(255);
}

void restart() {
    $time = "";
    $music.stop();
    $rowMap = 0;
    $colMap = 0; //location of tile map
    $frame = 0;
    $mode = "reset";
    $zText = "ACTION";
    $canSave = false;
    $canStick = false;
    $gSwitch = false;
    $canSwitch = false;
    $initSwitch = false;
    $bg = new int[3];
    for (int i=0; i<4; i++) {
        $action[i] = false;
        $dir[i] = false;
    }
    $magnet = 0;
    $nStick = 0;
    $gameTimer = new Timer(); //timer to time game completion
    $deathTimer = new Timer(1); //timer used for death transition
    $block = new PushBlock();
    $tileMap = new TileMap("tile");
    $objMap = new TileMap("object");
    $girl = new Girl(28, 32, $tSize*8, $tSize*10, 3);
    $stick = new Stick();
    $fire = new Fire();
}