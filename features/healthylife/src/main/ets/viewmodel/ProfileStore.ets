/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants as Const } from 'common';
import { PreferencesUtils } from 'common/src/main/ets/utils/PreferencesUtils';
import { UserProfile } from '../model/UserProfile';

@Observed
export class ProfileStore {
  public userProfile: UserProfile;

  constructor(userProfile: UserProfile) {
    this.userProfile = userProfile;
  }
}

export async function initProfileStore(): Promise<ProfileStore> {
  const avatarUri: string = await PreferencesUtils.getPreference(Const.USER_AVATAR_URI);
  const nickname: string = await PreferencesUtils.getPreference(Const.USER_NICKNAME);
  const genderStr: string = await PreferencesUtils.getPreference(Const.USER_GENDER);
  const birthday: string = await PreferencesUtils.getPreference(Const.USER_BIRTHDAY);
  const heightStr: string = await PreferencesUtils.getPreference(Const.USER_HEIGHT);
  const weightStr: string = await PreferencesUtils.getPreference(Const.USER_WEIGHT);

  const avatarValue: string = (avatarUri === 'default' || avatarUri === '') ? '' : avatarUri;
  const nicknameValue: string = (nickname === 'default' || nickname === '') ? '' : nickname;
  const genderValue: number = (genderStr === 'default' || genderStr === '' || genderStr === '0') ? 0 : Number(genderStr);
  const birthdayValue: string = (birthday === 'default' || birthday === '') ? '' : birthday;
  const heightValue: number = (heightStr === 'default' || heightStr === '' || heightStr === '0') ? 0 : Number(heightStr);
  const weightValue: number = (weightStr === 'default' || weightStr === '' || weightStr === '0') ? 0 : Number(weightStr);

  return new ProfileStore(new UserProfile(avatarValue, nicknameValue, genderValue, birthdayValue, heightValue, weightValue));
}

export async function updateProfileField(key: string, value: string): Promise<ProfileStore> {
  await PreferencesUtils.putPreference(key, value);
  return await initProfileStore();
}
