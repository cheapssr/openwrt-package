local e=require"nixio.fs"
local e=require"luci.sys"
local logfile="/var/log/passwall.log"
m=Map("passwall")
s=m:section(TypedSection,"global",translate("These is logs."))
s.anonymous=true
clearlog=s:option(Button,"clearlog",translate("清空日志"))
function clearlog.write(self, section)
luci.util.exec("echo '' > "..logfile)
--luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall", "log"))
end
tvlog=s:option(TextValue,"sylogtext")
tvlog.rows=40
tvlog.readonly="readonly"
tvlog.wrap="off"
function tvlog.cfgvalue(t,t)
sylogtext=""
if logfile and nixio.fs.access(logfile)then
sylogtext=luci.sys.exec("tail -n 40 %s"%logfile)
end
return sylogtext
end
tvlog.write=function(e,e,e)
end
return m
