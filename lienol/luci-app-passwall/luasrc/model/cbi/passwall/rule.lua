local e=require"nixio.fs"
local e=require"luci.sys"
local gfwlist_version=luci.sys.exec("uci get passwall.@global[0].gfwlist_version")
local chnroute_version=luci.sys.exec("uci get passwall.@global[0].chnroute_version")
local Pcap_Routing_version=luci.sys.exec("uci get passwall.@global[0].pcap_Routing_version")
local Pcap_WhiteList_version=luci.sys.exec("uci get passwall.@global[0].pcap_WhiteList_version")
--local t=luci.sys.exec("cat /usr/share/passwall/dnsmasq.d/gfwlist.conf|grep -c ipset")
local a=luci.sys.exec("/usr/bin/kcptun_client -v | awk '{print $3}'")
m=Map("passwall")
s=m:section(TypedSection,"global",translate("Rule status"))
s.anonymous=true
o=s:option(DummyValue,"satus1",nil)
o.description=translate("<style>p {margin-top:5px;margin-bottom:0px}</style><b>版本：</b><p>chnroute【 "..chnroute_version.."】 gfwlist【 "..gfwlist_version.."】</p><p>Pcap_Routing【 "..Pcap_Routing_version.."】 Pcap_WhiteList【 "..Pcap_WhiteList_version.."】</p>")
o=s:option(Button,"_start",translate("Manually update rules"))
o.inputstyle="apply"
function o.write(e,e)
luci.sys.call("/usr/share/passwall/rule_update.sh")
luci.http.redirect(luci.dispatcher.build_url("admin","vpn","passwall","log"))
end
o=s:option(Flag,"auto_update",translate("Enable auto update rules"))
o.default=0
o.rmempty=false
o=s:option(ListValue,"week_update",translate("Week update rules"))
o:value(7,translate("每天"))
for e=1,6 do
o:value(e,translate("周"..e))
end
o:value(0,translate("周日"))
o.default=0
o:depends("auto_update",1)
o=s:option(ListValue,"time_update",translate("Day update rules"))
for e=0,23 do
o:value(e,translate(e.."点"))
end
o.default=0
o:depends("auto_update",1)
s=m:section(TypedSection,"global",translate("KCP Update"))
s.anonymous=true
o=s:option(DummyValue,"satus22",nil,translate("当前KCP客户端版本【 "..a.."】，<font style='color:red'>KCP服务器端和客户端最好选用同一版本号，否则可能无法连接！</font>"))
o=s:option(Value,"kcptun_client_file",translate("Kcptun客户端路径"))
o.default="/usr/bin/kcptun_client"
o.rmempty=false
o = s:option(Button, "_check_kcptun", translate("手动更新"),
	translate("确保有足够的空间安装Kcptun"))
o.template = "passwall/kcptun"
o.inputstyle = "apply"
o.btnclick = "onKcptunBtnClick('kcptun', this);"
o.id = "_kcptun-check_kcptun"
--o=s:option(Button,"_kpup",translate("Manually update rules"))
--o.inputstyle="apply"
--function o.write(e,e)
--luci.sys.call("/usr/share/passwall/kcpupdate")
--luci.http.redirect(luci.dispatcher.build_url("admin","vpn","passwall","log"))
--end
s=m:section(TypedSection,"global",translate("SSR Server Subscribe"))
s.anonymous=true
o=s:option(DynamicList,"baseurl",translate("Subscribe URL"),translate("Servers unsubscribed will be deleted in next update; Please summit the Subscribe URL first before manually update."))
o=s:option(Button,"_update",translate("Manually update rules"))
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/usr/share/passwall/onlineconfig.sh")
luci.http.redirect(luci.dispatcher.build_url("admin","vpn","passwall","log"))
end
o=s:option(Button,"_stop",translate("Delete All Subscribe"))
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/usr/share/passwall/onlineconfig.sh stop")
luci.http.redirect(luci.dispatcher.build_url("admin","vpn","passwall","log"))
end
o=s:option(Flag,"subscribe_by_ss",translate("Subscribe via proxy"))
o.default=0
o.rmempty=false
o=s:option(Flag,"auto_update_subscribe",translate("Enable auto update subscribe"))
o.default=0
o.rmempty=false
o=s:option(ListValue,"week_update_subscribe",translate("Week update rules"))
o:value(7,translate("每天"))
for e=1,6 do
o:value(e,translate("周"..e))
end
o:value(0,translate("周日"))
o.default=0
o.rmempty=false
o=s:option(ListValue,"time_update_subscribe",translate("Day update rules"))
for e=0,23 do
o:value(e,translate(e.."点"))
end
o.default=0
o.rmempty=false
s=m:section(TypedSection,"global",translate("Add the server via the SS/SSR link"))
s.anonymous=true
local i="/usr/share/passwall/ssr_link.conf"
o=s:option(TextValue,"ssr_link",translate("SS/SSR Link"),translate("Please fill in the SS/SSR link and then click Add; each line of a link."))
o.rows=8
o.wrap="off"
o.cfgvalue=function(s,s)
return nixio.fs.readfile(i)or""
end
o.write=function(s,s,o)
nixio.fs.writefile("/tmp/ssr_link",o:gsub("\r\n","\n"))
if(luci.sys.call("cmp -s /tmp/ssr_link /usr/share/passwall/ssr_link.conf")==1)then
nixio.fs.writefile(i,o:gsub("\r\n","\n"))
end
nixio.fs.remove("/tmp/ssr_link")
end
o=s:option(Button,"_add",translate("Add Server"))
o.inputtitle=translate("Add")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/usr/share/passwall/onlineconfig.sh add")
end
return m
