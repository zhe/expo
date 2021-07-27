import { FaceFeature } from 'expo-face-detector';
declare const scaledFace: (scale: number) => ({ faceID, bounds, rollAngle, yawAngle }: FaceFeature) => JSX.Element;
declare const scaledLandmarks: (scale: number) => (face: FaceFeature) => JSX.Element;
declare const face: ({ faceID, bounds, rollAngle, yawAngle }: FaceFeature) => JSX.Element;
declare const landmarks: (face: FaceFeature) => JSX.Element;
export { face, landmarks, scaledFace, scaledLandmarks };
