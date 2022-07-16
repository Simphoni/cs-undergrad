'use strict';

class DatePicker {
    constructor ( tgt_id, callback_fn ) {
        this.tgt_id = tgt_id;
        this.callback_fn = callback_fn;
        this.daystr = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    }
    static getPrevDay( date ) {
        const ret = new Date();
        ret.setTime(date.getTime() - 24 * 60 * 60 * 1000);
        return ret;
    }
    static getNextDay( date ) {
        const ret = new Date();
        ret.setTime(date.getTime() + 24 * 60 * 60 * 1000);
        return ret;
    }
    genWeek( date ) {
        // `date` is in the week to be generate
        let ptr = new Date(date);
        for (let i = 0; i < 7; i ++) {
            if (ptr.getDay() === 0) break;
            else ptr = DatePicker.getPrevDay(ptr);
        }
        let code = "<div class='body empty'></div>";
        for (let i = 0; i < 7; i ++) {
            if (this.date.getMonth() === ptr.getMonth()) {
                code += "<div class='body current-month'>" + ptr.getDate() + "</div>";
            } else {
                code += "<div class='body other-month'>" + ptr.getDate() + "</div>";
            }
            ptr = DatePicker.getNextDay(ptr);
        }
        code += "<div class='body empty'></div>";
        return { code: code, edate: ptr };
    }
    genCallendar() {
        let code = '';
        let date = new Date(this.date);
        date.setDate(1);
        const wrapper = "<div class='row'>";
        // title
        code += "<div class='title'>" + date.toLocaleString('en-GB', { month: 'long' })
            + ' ' + date.getFullYear() + '</div>';
        // header
        code += wrapper + "<div class='header btn-prev-month'><</div>";
        for (let i = 0; i < 7; i ++) {
            code += "<div class='header'>" + this.daystr[i] + ".</div>";
        }
        code += "<div class='header btn-next-month'>></div>";
        code += "</div>";
        // body
        while (date.getMonth() === this.date.getMonth()) {
            const dict = this.genWeek(date);
            date = dict.edate;
            code += wrapper + dict.code + "</div>";
        }
        // output
        const node = document.getElementById(this.tgt_id);
        node.innerHTML = code;
        // onclick event
        const avail_dates = node.getElementsByClassName('current-month');
        for (let i = 0; i < avail_dates.length; i ++) {
            avail_dates[i].onclick = (() => {
                this.callback_fn(this.tgt_id, {
                    day: Number(avail_dates[i].textContent),
                    month: this.date.getMonth() + 1,
                    year: this.date.getFullYear()
                });
            });
        }
        const lbtn = node.getElementsByClassName('btn-prev-month')[0];
        lbtn.onclick = (() => {
            if (this.date.getMonth() === 0) this.date.setFullYear(this.date.getFullYear() - 1);
            this.date.setMonth((this.date.getMonth() + 11) % 12);
            this.genCallendar();
        });
        const rbtn = node.getElementsByClassName('btn-next-month')[0];
        rbtn.onclick = (() => {
            if (this.date.getMonth() === 11) this.date.setFullYear(this.date.getFullYear() + 1);
            this.date.setMonth((this.date.getMonth() + 1) % 12);
            this.genCallendar();
        });
    }
    render( req_date ) {
        this.date = req_date;
        const mydate = {
            day: req_date.getDate(),
            month: req_date.getMonth() + 1,
            year: req_date.getFullYear()
        };
        this.callback_fn( this.tgt_id, mydate );
        this.genCallendar();
    }
}
