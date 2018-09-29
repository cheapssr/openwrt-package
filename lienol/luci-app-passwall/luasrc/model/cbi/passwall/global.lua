local o=require"luci.dispatcher"
local n=require("luci.model.ipkg")
local s=luci.model.uci.cursor()
local e=require"nixio.fs"
local e=require"luci.sys"
local i="passwall"
--local v2ray_status=luci.sys.exec("ps | grep v2ray | grep -v grep | awk '{print $1}'")
local a,t,e
function is_finded(e)
local result=luci.sys.exec("find /usr/bin -iname "..e.." -type f")
if result=="" then
result=luci.sys.exec("find /usr/sbin -iname "..e.." -type f")
end
if result~="" then
return true
end
return false
end
function is_installed(e)
return n.installed(e)
end
local n={}
if not is_installed("v2ray") then
s:foreach(i,"servers",function(e)
if e.server and e.remarks and e.server_type~="v2ray" then
n[e[".name"]]="%s:%s"%{e.remarks,e.server}
end
end)
else
s:foreach(i,"servers",function(e)
if e.server and e.remarks then
n[e[".name"]]="%s:%s"%{e.remarks,e.server}
end
end)
end
a=Map(i,translate("Pass Wall"),translate("A lightweight secured SOCKS5 proxy"))
a.template="passwall/index"
a:append(Template("passwall/status"))
--[[e=t:option(DummyValue,"ss_redir_status",translate("Transparent Proxy"))
e.template="passwall/dvalue"
e.value=translate("Collecting data...")
e=t:option(DummyValue,"haproxy_status",translate("Load Balancing"))
e.template="passwall/haproxy"
e.value=translate("Collecting data...")
e=t:option(DummyValue,"kcp_status",translate("Kcp Client"))
e.template="passwall/kcp"
e.value=translate("Collecting data...")
e=t:option(DummyValue,"china_china",translate("China Connection"))
e.template="passwall/china"
e.value=translate("Collecting data...")
e=t:option(DummyValue,"foreign_foreign",translate("Foreign Connection"))
e.template="passwall/foreign"
e.value=translate("Collecting data...")
--]]
t=a:section(TypedSection,"global",translate("Global Setting"))
t.anonymous=true
t.addremove=false
e=t:option(ListValue,"global_server",translate("Current Server"))
e.default="nil"
e.rmempty=false
e:value("nil",translate("Disable"))
for a,t in pairs(n)do e:value(a,t)end
e=t:option(ListValue,"proxy_mode",translate("Default")..translate("Proxy Mode"))
e.default="gfwlist"
e.rmempty=false
e:value("disable",translate("No Proxy"))
e:value("global",translate("Global Proxy"))
e:value("gfwlist",translate("GFW List"))
e:value("chnroute",translate("China WhiteList"))
e:value("gamemode",translate("Game Mode"))
e:value("returnhome",translate("Return Home"))
e=t:option(ListValue,"dns_mode",translate("DNS Forward Mode"),translate("You cannot use ss-tunnel or ssr-tunnel mode if the server does not support UDP forwarding"))
e.default="cdns"
e.rmempty=false
e:reset_values()--清空
if is_installed("cdns")then
e:value("cdns","cdns")
end
if is_installed("ChinaDNS")then
e:value("chinadns","ChinaDNS")
end
if is_installed("dns2socks")then
e:value("dns2socks","dns2socks")
end
if is_installed("dnsc")then
e:value("dnsc","dnsc")
end
if is_installed("dnsproxy")then
e:value("dnsproxy","dnsproxy")
end
if is_installed("pcap-dnsproxy")then
e:value("Pcap_DNSProxy","Pcap_DNSProxy")
end
if is_installed("pdnsd") or is_installed("pdnsd-alt")then
e:value("pdnsd","pdnsd")
end
if is_finded("ss-tunnel")then
e:value("ss-tunnel","ss-tunnel")
end
if is_finded("ssr-tunnel") then
e:value("ssr-tunnel","ssr-tunnel")
end
e=t:option(ListValue,"up_dns_mode",translate("upstreamm DNS Server for ChinaDNS"))
e.default="OpenDNS"
e:depends("dns_mode","chinadns")
if is_installed("dnsproxy")then
e:value("dnsproxy","dnsproxy")
end
if is_installed("dns-forwarder")then
e:value("dns-forwarder","dns-forwarder")
end
e:value("OpenDNS","OpenDNS")
if is_finded("ss-tunnel")then
e:value("ss-tunnel","ss-tunnel")
end
if is_finded("ssr-tunnel") then
e:value("ssr-tunnel","ssr-tunnel")
end
t=a:section(TypedSection,"servers",translate("Servers List"),translate("Make sure that the KCP parameters are configured under the corresponding SS server to use the KCP fast switch.<br><font style='color:red'>Note: UDP cannot be forwarded after KCP is turned on.</font>"))
t.anonymous=true
t.addremove=true
t.template="cbi/tblsection"
t.extedit=o.build_url("admin","vpn","passwall","serverconfig","%s")
function t.create(e,t)
local e=TypedSection.create(e,t)
luci.http.redirect(o.build_url("admin","vpn","passwall","serverconfig",e))
end
function t.remove(t,a)
t.map.proceed=true
t.map:del(a)
luci.http.redirect(o.build_url("admin","vpn","passwall"))
end
e=t:option(DummyValue,"remarks",translate("Node Remarks"))
e.width="10%"
e=t:option(DummyValue,"server_type",translate("Server Type"))
e.width="10%"
e.cfgvalue=function(t,n)
local t=a.uci:get(i,n,"server_type")or""
local b
if t==""or b==""then return""end
if t=="ssr" then b="SSR"
elseif t=="ss" then b="SS"
else b="V2ray"
end
return b
end
e=t:option(DummyValue,"server",translate("Server Address"))
e.width="15%"
e=t:option(DummyValue,"server_port",translate("Server Port"))
e.width="5"
e=t:option(DummyValue,"encrypt_method",translate("Encrypt Method"))
e.width="10%"
e.cfgvalue=function(t,n)
local t=a.uci:get(i,n,"server_type")or""
local b
if t==""or b==""then return""end
if t=="v2ray" then b=a.uci:get(i,n,"v2ray_encrypt_method")
else b=a.uci:get(i,n,"encrypt_method")
end
return b
end
e=t:option(Flag,"use_kcp",translate("KCPTUN Switch"))
e.width="10%"
e=t:option(Flag,"forwarding_ipv6",translate("Forwarding IPv6 Switch"))
e.width="10%"
e=t:option(DummyValue,"server",translate("Ping Latency"))
e.template="passwall/ping"
e.width="10%"

local apply = luci.http.formvalue("cbi.apply")
if apply then
--os.execute("/etc/init.d/passwall restart")
--io.popen("/etc/init.d/passwall restart")
end

return a
