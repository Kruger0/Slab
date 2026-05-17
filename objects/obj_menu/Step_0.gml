
var _cr = cr_arrow
switch (mainMenu.GetMouseState()) {
    case SLAB_MOUSE.INACTIVE:   _cr = cr_none; break;
    case SLAB_MOUSE.IDLE:       _cr = cr_arrow; break;
    case SLAB_MOUSE.HOVER:      _cr = cr_handpoint; break;
}
window_set_cursor(_cr);
