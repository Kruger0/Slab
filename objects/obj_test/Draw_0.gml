
mainMenu.Render();

if (global.debug) {
    draw_text(8, 64, json_stringify(global.options, true));
}
