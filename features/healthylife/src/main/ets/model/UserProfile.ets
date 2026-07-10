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

export class UserProfile {
  avatarUri: string = '';
  nickname: string = '';
  gender: number = 0;
  birthday: string = '';
  height: number = 0;
  weight: number = 0;

  constructor(avatarUri: string, nickname: string, gender: number, birthday: string, height: number, weight: number) {
    this.avatarUri = avatarUri;
    this.nickname = nickname;
    this.gender = gender;
    this.birthday = birthday;
    this.height = height;
    this.weight = weight;
  }
}
