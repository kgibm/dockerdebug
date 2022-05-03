#!/bin/sh
# usage: podfspath.sh ROOTFS PATH
# We need to get the absolute path because symlinks won't work as it assumes
# a chroot, and we can't chroot, because then we can't do anything with the files like
# copy them out. In addition, dirname doesn't work if there isn't an actual filename,
# so check if it's a dir.
REALPATH="$(chroot "/host/${1}/" sh -c "if [ -d \"${2}\" ]; then cd \"${2}\"; else cd \$(dirname \"${2}\"); fi && pwd -P")"
if [ "${REALPATH}" != "" ]; then
  # First condition: Same as when getting the REALPATH above
  # Second condition: Outside the chroot, -d won't be able to resolve directory symlinks, so check explicitly
  # Third condition: Outside the chroot, a trailing slash won't be able to resolve the directory, so assume it's one
  if [ -d "/host/${1}/${2}" ] || [ -L "/host/${1}/${2}" ] || [ "${2%/}" != "${2}" ]; then
    echo "/host/${1}/${REALPATH}/"
  else
    echo "/host/${1}/${REALPATH}/$(basename "${2}")"
  fi
fi
