#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "PhotoPickerPlus/PhotoPickerPlus/Configuration/GCConfiguration-Sample.plist"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/album_default.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/camera.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/chute.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/defaultThumb.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/dropbox.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/dropbox@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/facebook.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/facebook@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/flickr.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/flickr@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/google.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/google@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/googledrive.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/googledrive@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/gradient_blue.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/instagram.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/instagram@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/overlay.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/overlay@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/picasa.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/picasa@2x.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/popover_arrow.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/popover_border.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/skydrive.png"
install_resource "PhotoPickerPlus/PhotoPickerPlus/Resources/skydrive@2x.png"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ `xcrun --find actool` ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in 
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;  
  esac 
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
