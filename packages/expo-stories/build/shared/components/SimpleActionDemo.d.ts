declare type SimpleActionDemoProps = {
    title: string;
    action: (setValue: (value: any) => any) => any;
};
declare function SimpleActionDemo(props: SimpleActionDemoProps): JSX.Element;
export { SimpleActionDemo };
