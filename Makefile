# SPDX-License-Identifier: GPL-3.0-only
#
# LuCI app for JXUST Portal Login
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-jxustportal
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=yuhiemm <yuhiemm@gmail.com>
LUCI_TITLE:=JXUST Portal LuCI Plugin
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+bash +curl

include $(TOPDIR)/feeds/luci/luci.mk

# 指定源码目录
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

# 安装文件到正确位置
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luci/controller/jxustportal.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/jxustportal
	$(INSTALL_DATA) ./luci/view/jxustportal/index.htm $(1)/usr/lib/lua/luci/view/jxustportal/
endef

# 注册包信息
$(eval $(call BuildPackage,$(PKG_NAME)))
