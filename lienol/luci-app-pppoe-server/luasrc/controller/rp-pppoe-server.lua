module("luci.controller.rp-pppoe-server",package.seeall)
function index()
if not nixio.fs.access("/etc/config/rp-pppoe-server")then
return
end
entry({"admin","services","rp-pppoe-server"},alias("admin","services","rp-pppoe-server","settings"),_("PPPoE Server"),2)
entry({"admin","services","rp-pppoe-server","settings"},cbi("rp-pppoe-server/settings"),_("General Settings"),10).leaf=true
entry({"admin","services","rp-pppoe-server","users"},cbi("rp-pppoe-server/users"),_("Users Manager"),20).leaf=true
entry({"admin","services","rp-pppoe-server","online"},cbi("rp-pppoe-server/online"),_("Online Users"),30).leaf=true
entry({"admin","services","rp-pppoe-server","status"},call("status")).leaf=true
end
function status()
local e={}
e.rp_pppoe_server_status=luci.sys.call("pidof %s >/dev/null"%"pppoe-server")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
