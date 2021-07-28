import path from 'path';

import { IOS_DIR } from '../../Constants';
import { copyFileWithTransformsAsync } from '../../Transforms';
import { getVersionedDirectory, getVersionPrefix } from './utils';

// Filename of the provider used by autolinking.
const MODULES_PROVIDER_FILENAME = 'ExpoModulesProvider.swift';

// Autolinking generates the unversioned provider at this path.
const UNVERSIONED_MODULES_PROVIDER_PATH = path.join(
  IOS_DIR,
  'Pods',
  'Target Support Files',
  'Pods-Expo Go-Expo Go (unversioned)',
  MODULES_PROVIDER_FILENAME
);

/**
 * Versions Swift modules provider into ExpoKit directory.
 */
export async function versionExpoModulesProviderAsync(sdkNumber: number) {
  const prefix = getVersionPrefix(sdkNumber);
  const targetDirectory = path.join(getVersionedDirectory(sdkNumber), 'ExpoModulesCore');

  await copyFileWithTransformsAsync({
    sourceFile: MODULES_PROVIDER_FILENAME,
    sourceDirectory: path.dirname(UNVERSIONED_MODULES_PROVIDER_PATH),
    targetDirectory,
    transforms: {
      content: [
        {
          find: /\bimport (Expo|EX)/g,
          replaceWith: `import ${prefix}$1`,
        },
        {
          find: /@objc\((Expo.*?)\)/g,
          replaceWith: `@objc(${prefix}$1)`,
        },
      ],
    },
  });
}
