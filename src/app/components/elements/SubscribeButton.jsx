import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import * as transactionActions from 'app/redux/TransactionReducer';
import * as globalActions from 'app/redux/GlobalReducer';

class SubscribeButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = { loading: false };
    }

    onClick = () => {
        const { subscribed } = this.props;
        const community = this.props.community.get('name');

        this.setState({ loading: true });

        this.props.toggleSubscribe(
            !subscribed,
            community,
            this.props.username,
            () => {
                const key = ['community', community, 'context', 'subscribed'];
                this.props.stateSet(key, !subscribed);
                this.setState({ loading: false });
            },
            () => {
                this.setState({ loading: false });
            }
        );
    };

    render() {
        const { subscribed } = this.props;
        const { loading } = this.state;

        if (loading) {
            return (
                <button
                    disabled
                    className="button slim hollow secondary"
                    type="button"
                >
                    Loading...
                </button>
            );
        }

        return (
            <button
                onClick={this.onClick}
                className="button slim hollow secondary"
                type="button"
            >
                {subscribed ? 'Unsubscribe' : 'Subscribe'}
            </button>
        );
    }
}

SubscribeButton.propTypes = {
    username: PropTypes.string.isRequired,
    subscribed: PropTypes.bool.isRequired,
    community: PropTypes.object.isRequired, //TODO: Define this shape
};

export default connect(
    (state, ownProps) => {
        return {
            ...ownProps,
            username: state.user.getIn(['current', 'username']),
            subscribed: state.global.getIn(
                ['community', ownProps.community, 'context', 'subscribed'],
                false
            ),
            community: state.global.getIn(
                ['community', ownProps.community],
                {}
            ),
        };
    },
    dispatch => ({
        stateSet: (key, value) => {
            dispatch(globalActions.set({ key, value }));
        },
        toggleSubscribe: (
            subscribeToCommunity,
            community,
            account,
            successCallback,
            errorCallback
        ) => {
            let action = 'unsubscribe';
            if (subscribeToCommunity) action = 'subscribe';

            const payload = [
                action,
                {
                    community,
                },
            ];

            return dispatch(
                transactionActions.broadcastOperation({
                    type: 'custom_json',
                    operation: {
                        id: 'community',
                        required_posting_auths: [account],
                        json: JSON.stringify(payload),
                    },
                    successCallback,
                    errorCallback,
                })
            );
        },
    })
)(SubscribeButton);