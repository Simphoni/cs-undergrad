'use strict';

function Cs142TemplateProcessor( template ) {
    this.str = template;
    this.fillIn = ( rule ) => {
        const wildpat = /{{[^]+}}/;
        let ret = template;
        for (var p in rule) {
            if (typeof p === 'string') {
                ret = ret.replace("{{" + p + "}}", rule[p]); // replace with
            }
        }
        ret = ret.replace(wildpat, "");
        return ret;
    };
}
