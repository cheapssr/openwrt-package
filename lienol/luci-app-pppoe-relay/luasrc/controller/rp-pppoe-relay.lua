module("luci.controller.rp-pppoe-relay",package.seeall)
function index()
if not nixio.fs.access("/etc/config/rp-pppoe-relay")then
return
end
entry({"admin","services","rp-pppoe-relay"},cbi("rp-pppoe-relay"),_("PPPoE Relay"),1).dependent=true
entry({"admin","services","rp-pppoe-relay","status"},call("status")).leaf=true
end
function status()
local e={}
e.pppoe_relay_status=luci.sys.call("pidof %s >/dev/null"%"pppoe-relay")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
