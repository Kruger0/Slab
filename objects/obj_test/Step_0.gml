
if (keyboard_check_pressed(vk_f9)) {
    global.debug ^= 1;
    show_debug_overlay(global.debug);
}


var _cr = cr_arrow
switch (mainMenu.MouseGetState()) {
    case MENU_MOUSE.INACTIVE:   _cr = cr_none; break;
    case MENU_MOUSE.IDLE:       _cr = cr_arrow; break;
    case MENU_MOUSE.HOVER:      _cr = cr_handpoint; break;
}
window_set_cursor(_cr);

if (keyboard_check_pressed(vk_f5)) room_restart()

keyboard_set_numlock(!keyboard_get_numlock())