
var _cr = cr_arrow;
switch (pauseMenu.GetMouseState()) {
    case MENU_MOUSE.INACTIVE:   _cr = cr_none; break;
    case MENU_MOUSE.IDLE:       _cr = cr_arrow; break;
    case MENU_MOUSE.HOVER:      _cr = cr_handpoint; break;
}
window_set_cursor(_cr);

if (!global.pause) {
    global.pause = true;
}