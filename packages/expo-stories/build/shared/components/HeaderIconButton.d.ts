import * as React from 'react';
import { View } from 'react-native';
declare function HeaderContainerRight(props: React.ComponentProps<typeof View> & {
    children?: any;
}): JSX.Element;
declare type Props = {
    color?: string;
    disabled?: boolean;
    name: string;
    onPress: () => void;
    size?: number;
};
declare function HeaderIconButton({ color, disabled, name, onPress, size }: Props): JSX.Element;
export { HeaderContainerRight, HeaderIconButton };
