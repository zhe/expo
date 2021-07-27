import React from 'react';
import { StyleProp, ViewStyle } from 'react-native';
declare class GoogleSignInButton extends React.PureComponent<{
    style?: StyleProp<ViewStyle>;
    disabled?: boolean;
}> {
    static defaultProps: {
        onPress(): void;
    };
    render(): JSX.Element;
}
export { GoogleSignInButton };
