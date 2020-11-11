import React from 'react';
import PropTypes from 'prop-types';

const SteemLogo = ({ nightmodeEnabled }) => {
    const logo = nightmodeEnabled
        ? '/images/wethex-logo-nightmode.svg'
        : '/images/wethex-logo.svg';

    return (
        <span className="logo">
            {/* <svg width="150" height="40" viewBox="0 0 150 40" version="1.1">
                <title>Home</title>
                <g id="logo" />
            </svg> */}
            <img alt="logo" width="50" height="50" style={{marginTop: '8px'}} src={logo} />
        </span>
    );
};

export default SteemLogo;
