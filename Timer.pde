/**
 * class for timing things
 */
class Timer {
    int _start, _end;
    float _stop;
    Boolean _on = false;
    Boolean _done = false;

    Timer() {
    }

    Timer(float stop) {
        _stop = stop;
    }

    /**
     * gets state of timer
     */
    void reset() {
        _done = false;
    }

    /**
     * starts the timer
     */
    Boolean start() {
        if (!_on) {
            _start = millis();
            _on = true;
        } else if ((millis()-_start)/1000 >= _stop) {
            _end = millis();
            _on = false;
            _done = true;
        }
        return !_done;
    }

    /**
     * ends the timer and returns time passed
     */
    String end() {
        if (!_done) {
            _end = getMillis();
            _on = false;
            _done = true;
        }
        return readTime();
    }

    /**
     * time passed in milliseconds
     */
    int getMillis() {
        if (_on) {
            return millis()-_start;
        }
        return _end-_start;
    }

    /**
     * makes time readable to humans
     */
    String readTime() {
        return getHour()+":"+getMin()+":"+getSec();
    }

    String getHour() {
        return ""+getMillis()/(60*60*1000);
    }

    String getMin() {
        int m = getMillis()/(60*1000) % 60;
        return ((m < 10)? "0":"")+m;
    }

    String getSec() {
        int s = getMillis()/1000 % 60;
        return ((s < 10)? "0":"")+s;
    }
}
