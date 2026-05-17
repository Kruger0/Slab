global.options = {
    audio : {
        master  : 80,
        music   : 20,
        sfx     : 60,
    },
    video : {
        display : 1,
        resolution : 1,
        bloom : true,
        vsync : false,
    },
    language : "pt_BR",
}
global.debug = false;

scribble_font_set_default("fnt_test");

room_goto(rm_menu)