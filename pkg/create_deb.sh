#!/bin/sh
PACKAGE=cosmos-redis
PACKAGE_ROOT="./cosmos-redis-pkg"
VERSION=$GO_PIPELINE_LABEL
ARCH=all

echo "Creating temp packaging directory ${PACKAGE_ROOT} ..."
mkdir -p $PACKAGE_ROOT
mkdir -p $PACKAGE_ROOT/DEBIAN
mkdir -p $PACKAGE_ROOT/var/lib/$PACKAGE
mkdir -p $PACKAGE_ROOT/etc/init.d

echo "Copying debian files to ${PACKAGE_ROOT} ..."
cp pkg/deb/$PACKAGE.control $PACKAGE_ROOT/DEBIAN/control
cp pkg/deb/$PACKAGE.postinst $PACKAGE_ROOT/DEBIAN/postinst
cp pkg/deb/$PACKAGE.postrm $PACKAGE_ROOT/DEBIAN/postrm
cp pkg/deb/$PACKAGE.preinst $PACKAGE_ROOT/DEBIAN/preinst
cp pkg/deb/$PACKAGE.prerm $PACKAGE_ROOT/DEBIAN/prerm
cp pkg/deb/$PACKAGE-init $PACKAGE_ROOT/etc/init.d/$PACKAGE

echo "Updating version in control file ..."
sed -e "s/VERSION/${VERSION}/" -i $PACKAGE_ROOT/DEBIAN/control

echo "Copying scripts to ${PACKAGE_ROOT} ..."
cp src/* $PACKAGE_ROOT/var/lib/$PACKAGE/

echo "Building debian ..."
dpkg-deb -b $PACKAGE_ROOT

echo "Removing older debians ..."
rm pkg/*.deb

echo "Renaming debian ..."
mv $PACKAGE_ROOT.deb pkg/${PACKAGE}_${VERSION}_${ARCH}.deb

echo "Removing temp directory ${PACKAGE_ROOT} ..."
rm -r $PACKAGE_ROOT

echo "Done."
