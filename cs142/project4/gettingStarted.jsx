import React from 'react';
import ReactDOM from 'react-dom';
import './styles/main.css';

import Header from './components/header/Header';
import Example from './components/example/Example';

ReactDOM.render(
  <Example />,
  document.getElementById('reactapp'),
);

ReactDOM.render(
  <Header />,
  document.getElementById('cs142-header'),
)
