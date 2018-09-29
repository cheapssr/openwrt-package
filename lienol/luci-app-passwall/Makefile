# Copyright (C) 2018 Lienol
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-passwall
PKG_VERSION:=1.6
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PO2LMO:=$(BUILD_DIR)/luci-base/po2lmo
 
include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/config
menu "Configuration"
	depends on PACKAGE_$(PKG_NAME)
	
config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR
	bool "Include ShadowsocksR"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_V2ray
	bool "Include V2ray"
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_haproxy
	bool "Include haproxy"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_ChinaDNS
	bool "Include ChinaDNS"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_pdnsd
	bool "Include pdnsd"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_cdns
	bool "Include cdns"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_Pcap_dnsproxy
	bool "Include pcap-dnsproxy"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_dnsproxy
	bool "Include dnsproxy"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_dns-forwarder
	bool "Include dns-forwarder"
	default y
	
config PACKAGE_$(PKG_NAME)_INCLUDE_dns2socks
	bool "Include dns2socks"
	default y

endmenu
endef


#  +PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR:shadowsocksr-libev-alt \
#  +PACKAGE_$(PKG_NAME)_INCLUDE_Pcap_dnsproxy:pcap-dnsproxy
define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Shadowsocks By Lienol
  PKGARCH:=all
  DEPENDS:=+curl +libcurl +libmbedtls +ca-bundle +ca-certificates +resolveip +iptables-mod-tproxy +kmod-ipt-tproxy +ip +ipset-lists +coreutils +coreutils-base64 +coreutils-nohup \
  +shadowsocks-libev-ss-local +shadowsocks-libev-ss-redir +shadowsocks-libev-ss-tunnel \
  +dnsmasq-full \
  +PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR:shadowsocksr \
  +PACKAGE_$(PKG_NAME)_INCLUDE_V2ray:v2ray \
  +PACKAGE_$(PKG_NAME)_INCLUDE_haproxy:haproxy \
  +PACKAGE_$(PKG_NAME)_INCLUDE_ChinaDNS:ChinaDNS \
  +PACKAGE_$(PKG_NAME)_INCLUDE_pdnsd:pdnsd-alt \
  +PACKAGE_$(PKG_NAME)_INCLUDE_cdns:cdns \
  +PACKAGE_$(PKG_NAME)_INCLUDE_dnsproxy:dnsproxy \
  +PACKAGE_$(PKG_NAME)_INCLUDE_dns-forwarder:dns-forwarder \
  +PACKAGE_$(PKG_NAME)_INCLUDE_dns2socks:dns2socks \
  +pcap-dnsproxy
endef

define Build/Prepare
endef
 
define Build/Configure
endef
 
define Build/Compile
endef
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/passwall
	$(INSTALL_CONF) ./root/etc/config/passwall $(1)/etc/config/passwall
	$(INSTALL_CONF) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/init.d/passwall $(1)/etc/init.d/passwall
	
	$(INSTALL_BIN) ./root/usr/sbin/gfwlist $(1)/usr/sbin/gfwlist
	cp -pR ./root/usr/share/passwall/* $(1)/usr/share/passwall
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(PO2LMO) ./po/zh-cn/passwall.po $(1)/usr/lib/lua/luci/i18n/passwall.zh-cn.lmo
	
ifdef CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_cdns
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./config/cdns/etc/* $(1)/etc
endif
	
ifdef CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Pcap_dnsproxy
	$(INSTALL_DIR) $(1)/etc/pcap-dnsproxy
	$(INSTALL_BIN) ./config/pcap-dnsproxy/etc/pcap-dnsproxy/* $(1)/etc/pcap-dnsproxy
endif
endef
$(eval $(call BuildPackage,$(PKG_NAME)))

#include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


