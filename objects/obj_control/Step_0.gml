
if (keyboard_check_pressed(vk_f5)) room_restart()

if (keyboard_check_pressed(vk_f9)) {
    global.debug ^= 1;
    show_debug_overlay(global.debug);
}
