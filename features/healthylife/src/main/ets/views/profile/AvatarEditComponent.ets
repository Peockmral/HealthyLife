import { CommonConstants as Const } from 'common';
import { ProfileStore, updateProfileField } from '../../viewmodel/ProfileStore';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function avatarEditBuilder() {
  AvatarEditComponent();
}

@Component
export struct AvatarEditComponent {
  @Consume profileStore: ProfileStore;
  @Consume('pathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        // Title bar
        Row() {
          Image($r('app.media.ach_back'))
            .height($r('app.float.default_40'))
            .width($r('app.float.default_40'))
            .margin({
              right: $r('app.float.default_8')
            })
            .onClick(() => {
              this.pageStack.pop();
            })
          Text($r('app.string.edit_avatar'))
            .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('app.float.default_20'))
            .width(Const.THOUSANDTH_1000)
            .height($r('app.float.default_56'))
        }
        .margin({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })

        // Avatar display
        Column() {
          if (this.profileStore.userProfile.avatarUri !== '') {
            Image(this.profileStore.userProfile.avatarUri)
              .width(120)
              .height(120)
              .borderRadius('50%')
              .clip(true)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.person_crop_circle'))
              .width(120)
              .height(120)
          }
        }
        .margin({ top: 40 })

        // Select from gallery button
        Button($r('app.string.select_from_gallery'))
          .width(200)
          .height(44)
          .fontSize($r('app.float.default_16'))
          .margin({ top: 40 })
          .onClick(() => {
            this.selectAvatarFromGallery();
          })
      }
      .width(Const.THOUSANDTH_1000)
      .height(Const.THOUSANDTH_1000)
      .backgroundColor($r('sys.color.background_secondary'))
      .alignItems(HorizontalAlign.Center)
    }
    .size({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .padding({
      top: $r('app.float.default_40')
    })
  }

  private async selectAvatarFromGallery(): Promise<void> {
    try {
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result: photoAccessHelper.PhotoSelectResult = await photoPicker.select(options);
      if (result.photoUris.length > 0) {
        const srcUri: string = result.photoUris[0];
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        const avatarDir: string = context.filesDir + '/avatar';
        if (!fs.accessSync(avatarDir)) {
          fs.mkdirSync(avatarDir);
        }
        const destPath: string = avatarDir + '/avatar.jpg';
        const srcFile: fs.File = fs.openSync(srcUri, fs.OpenMode.READ_ONLY);
        const destFile: fs.File = fs.openSync(destPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        fs.copyFileSync(srcFile.fd, destFile.fd);
        fs.closeSync(srcFile);
        fs.closeSync(destFile);
        const fileUri: string = 'file://' + destPath;
        const newStore: ProfileStore = await updateProfileField(Const.USER_AVATAR_URI, fileUri);
        this.profileStore = newStore;
        this.pageStack.pop();
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Avatar select failed: code ${err.code}, message ${err.message}`);
    }
  }
}
