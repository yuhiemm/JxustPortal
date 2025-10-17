# SPDX-License-Identifier: MIT
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-jxustportal
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=JXUST Portal
LUCI_DEPENDS:=+luci-base +wget

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/luci.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  LuCI plugin for JXUST campus portal login/logout.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/jxustportal
	$(INSTALL_BIN) ./luci/controller/jxustportal.lua $(1)/usr/lib/lua/luci/controller/jxustportal.lua
	$(INSTALL_DATA) ./luci/view/jxustportal/index.htm $(1)/usr/lib/lua/luci/view/jxustportal/index.htm
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
