declare function Page({ children }: {
    children: any;
}): JSX.Element;
declare function ScrollPage({ children }: {
    children: any;
}): JSX.Element;
declare function Section({ title, children, row }: {
    title: string;
    children: any;
    row?: boolean;
}): JSX.Element;
export { Page, Section, ScrollPage };
