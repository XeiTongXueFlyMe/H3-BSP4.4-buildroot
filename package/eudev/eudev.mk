################################################################################
#
# eudev
#
################################################################################

EUDEV_VERSION = 3.2
EUDEV_SOURCE = eudev-$(EUDEV_VERSION).tar.gz
EUDEV_SITE = http://dev.gentoo.org/~blueness/eudev
EUDEV_LICENSE = GPLv2+ (programs), LGPLv2.1+ (libraries)
EUDEV_LICENSE_FILES = COPYING
EUDEV_INSTALL_STAGING = YES

# mq_getattr is in librt
EUDEV_CONF_ENV += LIBS=-lrt

EUDEV_CONF_OPTS = \
	--disable-manpages \
	--sbindir=/sbin \
	--libexecdir=/lib \
	--with-firmware-path=/lib/firmware \
	--disable-introspection \
	--enable-kmod \
	--enable-blkid

EUDEV_DEPENDENCIES = host-gperf host-pkgconf util-linux kmod
EUDEV_PROVIDES = udev

ifeq ($(BR2_ROOTFS_MERGED_USR),)
EUDEV_CONF_OPTS += --with-rootlibdir=/lib --enable-split-usr
endif

ifeq ($(BR2_PACKAGE_EUDEV_RULES_GEN),y)
EUDEV_CONF_OPTS += --enable-rule-generator
else
EUDEV_CONF_OPTS += --disable-rule-generator
endif

ifeq ($(BR2_PACKAGE_EUDEV_ENABLE_HWDB),y)
EUDEV_CONF_OPTS += --enable-hwdb
else
EUDEV_CONF_OPTS += --disable-hwdb
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
EUDEV_CONF_OPTS += --enable-selinux
EUDEV_DEPENDENCIES += libselinux
else
EUDEV_CONF_OPTS += --disable-selinux
endif

define EUDEV_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/eudev/S10udev $(TARGET_DIR)/etc/init.d/S10udev
endef

define EUDEV_REMOVE_V4L2_RULES
	rm $(TARGET_DIR)/lib/udev/rules.d/60-persistent-v4l.rules
endef

EUDEV_POST_INSTALL_TARGET_HOOKS += EUDEV_REMOVE_V4L2_RULES

define EUDEV_REMOVE_NET_RULES
	rm $(TARGET_DIR)/lib/udev/rules.d/75-persistent-net-generator.rules
endef

EUDEV_POST_INSTALL_TARGET_HOOKS += EUDEV_REMOVE_NET_RULES

# Required by default rules for input devices
define EUDEV_USERS
	- - input -1 * - - - Input device group
endef

$(eval $(autotools-package))
