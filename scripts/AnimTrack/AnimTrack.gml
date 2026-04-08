
function AnimTrack(curve, channel, duration) constructor {
    self.channel    = animcurve_get_channel(curve, channel);
    self.duration   = duration;
    posx            = 0;
    playing         = false;
    currValue       = 0;
    targetValue     = 0;
    startValue      = 0;
    
    static Play = function(to) {
        if (targetValue == to && playing) exit;
        startValue  = currValue;
        targetValue = to;
        posx        = 0;
        playing     = true;
        return self;
    }
    static Snap = function(to) {
        startValue  = to;
        targetValue = to;
        currValue   = to;
        posx        = 1;
        playing     = false;
        return self;
    }
    static Update = function() {
        var _dt = delta_time/1000000;
        if (!playing) exit;
        posx      = clamp(posx + _dt / duration, 0, 1);
        var _t    = animcurve_channel_evaluate(channel, posx);
        currValue = lerp(startValue, targetValue, _t);
        playing   = (posx < 1);
    }
    static GetValue = function() {
        return currValue;
    }
    static GetPosition = function() {
        return posx;
    }
}