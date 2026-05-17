
/// @ignore
function __SlateCache() {
    static data = {
        pages:  {},
        styles: {},
    }
    return data;
}

if (debug_mode) {
    global.cache = __SlateCache()
}
