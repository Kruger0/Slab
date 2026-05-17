
if (keyboard_check_pressed(vk_f5)) room_restart();

if (keyboard_check_pressed(vk_f9)) {
    SlabDebugSetEnabled(!SlabDebugGetEnabled());
    show_debug_overlay(global.debug);
}
