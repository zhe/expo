import { TextStyle, ViewStyle } from 'react-native';
declare function TitleSwitch({ style, titleStyle, title, value, setValue, disabled, }: {
    style?: ViewStyle;
    titleStyle?: TextStyle;
    title?: string;
    value: boolean;
    disabled?: boolean;
    setValue: (value: boolean) => void;
}): JSX.Element;
export { TitleSwitch };
