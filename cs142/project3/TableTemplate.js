'use strict';

class TableTemplate {
    static fillIn( id, dict, columnName ) {
        const tab = document.getElementById(id);
        tab.style.visibility = 'visible';
        const header = tab.rows[0].children;
        for (let i = 0; i < header.length; i ++) {
            const ent = new Cs142TemplateProcessor(header[i].textContent);
            header[i].textContent = ent.fillIn(dict);
        }
        var rec = -1;
        for (let i = 0; i < header.length; i ++) {
            if (header[i].textContent === columnName) {
                rec = i; break;
            }
        }
        for (let ridx = 0; ridx < tab.rows.length; ridx ++) {
            const arr = tab.rows[ridx].children;
            if (rec === -1) {
                for (let i = 0; i < arr.length; i ++) {
                    const ent = new Cs142TemplateProcessor(arr[i].textContent);
                    arr[i].textContent = ent.fillIn(dict);
                }
            } else {
                const ent = new Cs142TemplateProcessor(arr[rec].textContent);
                arr[rec].textContent = ent.fillIn(dict);
            }
        }
    }
}
