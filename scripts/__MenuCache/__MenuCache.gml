
/// @ignore
function __MenuCache() {
    static data = {
        pages:  {},
        styles: {},
    }
    return data;
}

global.cache = __MenuCache()