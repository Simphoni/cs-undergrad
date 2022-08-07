import React from 'react';
import './Header.css';

class Header extends React.Component {
    constructor(props) {
        super(props);
        this.img_url = 'https://s2.loli.net/2022/02/01/foyTbIuX4z69seH.png';
    }
    render() {
        console.log(this.img_url);
        const abs_height = document.body.clientWidth / 4;
        const font_height = abs_height / 5 * 3
        return (
            <div style={{ height: abs_height }}>
                <div style={{ width: "100%", height: abs_height, overflow: "hidden", position: "absolute", top: "0px", left: "0px" }}>
                    <img src={this.img_url} width="100%" style={{ position: "relative" }} />
                </div>
                <div style={{
                    position: "absolute", top: "0px", left: "0px", fontSize: font_height, color: "red", width: "100%", lineHeight: "100%", paddingTop: (abs_height - font_height) / 2, paddingBottom: (abs_height - font_height) / 2, textAlign: "center", letterSpacing: font_height / 2, fontFamily: "Source Han Sans CN Heavy"
                }}>
                    光翼展开
                </div>
            </div >
        )
    }
}

export default Header;