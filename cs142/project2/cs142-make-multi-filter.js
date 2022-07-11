'use strict';

function cs142MakeMultiFilter(originalArray) {
    var currentArray = originalArray;
    function f( filterCriteria, callback ) {
        if (typeof filterCriteria === 'function') {
            currentArray = currentArray.filter(filterCriteria);
        }
        else if (typeof filterCriteria === 'undefined') {
            return currentArray;
        }
        if (typeof callback === 'function') {
            callback.call(originalArray, currentArray);
        }
        return f; // return itself
    }
    return f;
}
