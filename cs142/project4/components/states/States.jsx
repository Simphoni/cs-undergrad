import React from 'react';
import './States.css';

/**
 * Define States, a React componment of CS142 project #4 problem #2.  The model
 * data for this view (the state names) is available
 * at window.cs142models.statesModel().
 */
class States extends React.Component {
    constructor(props) {
        super(props);
        console.log('window.cs142models.statesModel()', window.cs142models.statesModel());
        this.searchList = window.cs142models.statesModel(),
        this.state = {
            inputVal: "",
            searchResults: "",
            warningMsg: "",
        };
    }

    updateSearchResults(event) {
        const questStr = event.target.value.toLowerCase();
        var flag = true;
        for (let c of questStr)
            if (c < 'a' || c > 'z') {
                this.setState({warningMsg: "invalid char " + c})
                flag = false;
            }
        if (flag) {
            let result = new Array();
            for (let dst of this.searchList) {
                if (dst.toLowerCase().indexOf(questStr) !== -1) result.push(dst);
            }
            let output = result.map( (e) => <li className="cs142-states-search-result-entry">{e}</li> );
            if (result.length === 0)
                output = <p style={{fontSize: "13px", fontFamily:"Courier New",color:"blue"}}>No matching entry found</p>;
            this.setState({
                inputVal: event.target.value,
                searchResults: output,
                warningMsg: "",
            });
        }
    }
    
    render() {
        return (
            <div>
                <div className='cs142-states-input-wrapper'>
                    <div className="cs142-states-input-frame">
                        <input id="cs142-states-inbox" type="text" value={this.state.inputVal} onChange={(e) => {this.updateSearchResults(e)}} />
                    </div>
                    <div className="cs142-states-input-frame" id="cs142-states-warning-msg">
                        {this.state.warningMsg}
                    </div>
                </div>
                <div className="cs142-states-search-result-list">
                    <ul>{this.state.searchResults}</ul>
                </div>
            </div>
        );
    }
}

export default States;
