local e=require"nixio.fs"
local t=require"luci.sys"
m=Map("passwall")
s=m:section(TypedSection,"global",translate("Set Blacklist And Whitelist"))
s.anonymous=true
local t="/usr/share/passwall/dnsmasq.d/cdn.conf"
o=s:option(TextValue,"whitelist",translate("Whitelist Hosts"))
o.description=translate("Join the white list of domain names will not go agent.")
o.rows=8
o.wrap="off"
o.cfgvalue=function(a,a)
return e.readfile(t)or""
end
o.write=function(o,o,a)
e.writefile("/tmp/cdn",a:gsub("\r\n","\n"))
if(luci.sys.call("cmp -s /tmp/cdn /usr/share/passwall/dnsmasq.d/cdn.conf")==1)then
e.writefile(t,a:gsub("\r\n","\n"))
luci.sys.call("rm -f /tmp/dnsmasq.d/sscdn.conf")
end
e.remove("/tmp/cdn")
end
local t="/usr/share/passwall/rule/whiteip"
o=s:option(TextValue,"wiplist",translate("Whitelist IP/CIDR"))
o.description=translate("These had been joined ip addresses will not use proxy.Please input the ip address or ip address segment,every line can input only one ip address.For example,112.123.134.145/24 or 112.123.134.145.")
o.rows=8
o.wrap="off"
o.cfgvalue=function(a,a)
return e.readfile(t)or""
end
o.write=function(o,o,a)
e.writefile(t,a:gsub("\r\n","\n"))
end

local t="/usr/share/passwall/rule/gfwlist"
o=s:option(TextValue,"weblist",translate("Blacklist Hosts"))
o.description=translate("These had been joined websites will use proxy,but only GFW model.Please input the domain names of websites,every line can input only one website domain.For example,google.com.")
o.rows=8
o.wrap="off"
o.cfgvalue=function(a,a)
return e.readfile(t)or""
end
o.write=function(o,o,a)
e.writefile("/tmp/gfwlist",a:gsub("\r\n","\n"))
if(luci.sys.call("cmp -s /tmp/gfwlist /usr/share/passwall/rule/gfwlist")==1)then
e.writefile(t,a:gsub("\r\n","\n"))
luci.sys.call("rm -f /tmp/dnsmasq.d/custom.conf >/dev/null")
end
e.remove("/tmp/gfwlist")
end
local t="/usr/share/passwall/rule/custom"
o=s:option(TextValue,"iplist",translate("Blacklist IP/CIDR"))
o.description=translate("These had been joined ip addresses will use proxy,but only GFW model.Please input the ip address or ip address segment,every line can input only one ip address.For example,112.123.134.145/24 or 112.123.134.145.")
o.rows=8
o.wrap="off"
o.cfgvalue=function(a,a)
return e.readfile(t)or""
end
o.write=function(o,o,a)
e.writefile(t,a:gsub("\r\n","\n"))
end
return m
