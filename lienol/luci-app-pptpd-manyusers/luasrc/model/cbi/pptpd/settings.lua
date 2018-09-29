local s=require"luci.sys"
local net = require "luci.model.network".init()
local ifaces = s.net:devices()
local m,s,o
m=Map("pptpd", translate("PPTP VPN Server"))
m.description = translate("Simple, quick and convenient PPTP VPN, universal across the platform")
m.template="pptpd/index"
--local pid = luci.util.exec("/usr/bin/pgrep pptpd")
--if pid == "" then
--start = s:option(Button, "_start", translate("Start"),translate("<span style='color:red'>Saving and applying does not execute the script, so start the service yourself</span>"))
--start.inputstyle = "apply"
--function start.write(self, section)
--luci.util.exec("/etc/init.d/pptpd start")
--luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "pptpd"))
--end
--else
--stop = s:option(Button, "_stop", translate("Stop"),translate("<span style='color:red'>Saving and applying does not execute the script, so stop the service yourself</span>"))
--stop.inputstyle = "reset"
--function stop.write(self, section)
--luci.util.exec("/etc/init.d/pptpd stop")
--luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "pptpd"))
--end
--end
s=m:section(TypedSection,"service")
s.anonymous=true
o=s:option(DummyValue,"pptpd_status",translate("Current Condition"))
o.template="pptpd/pptpd"
o.value=translate("Collecting data...")
o=s:option(Flag,"enabled",translate("Enable VPN Server"))
o.rmempty=false
o=s:option(Value,"localip",translate("Server IP"),translate("VPN Server IP address, it not required."))
o.datatype="ipaddr"
o.placeholder=translate("192.168.1.2")
o.rmempty=true
o.default="192.168.1.2"
o=s:option(Value,"remoteip",translate("Client IP"),translate("VPN Client IP address, it not required."))
o.placeholder=translate("192.168.1.10-20")
o.rmempty=true
o.default="192.168.1.10-20"
o=s:option(Value,"dns",translate("DNS IP address"),translate("This will be sent to the client, it not required."))
o.placeholder=translate("192.168.1.1")
o.datatype="ipaddr"
o.rmempty=true
o.default="192.168.1.1"
o=s:option(Flag,"mppe",translate("Enable MPPE Encryption"),translate("Allows 128-bit encrypted connection."))
o.rmempty=false
o=s:option(ListValue,"export_interface",translate("Export Interface"),translate("Specify interface forwarding traffic.<br>Choosing none client will not get online."))
o:value("none","none")
for _, iface in ipairs(ifaces) do
--	if not (iface == "lo" or iface:match("^ifb.*") or iface:match("gre*")) then
--		local nets = net:get_interface(iface)
--		nets = nets and nets:get_networks() or {}
--		for k, v in pairs(nets) do
--			nets[k] = nets[k].sid
--		end
--		nets = table.concat(nets, ",")
--		o:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
--	end
	if (iface:match("^br-*") or iface:match("^eth*") or iface:match("^pppoe.*") or iface:match("wlan*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		o:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
return m
