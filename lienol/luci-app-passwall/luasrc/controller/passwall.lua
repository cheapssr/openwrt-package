module("luci.controller.passwall",package.seeall)
local http = require "luci.http"
local kcp  = require "luci.model.cbi.passwall.kcptun"
function index()
if not nixio.fs.access("/etc/config/passwall")then
return
end
entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
entry({"admin","vpn","passwall"},alias("admin","vpn","passwall","settings"),_("Pass Wall"),2).dependent=true
entry({"admin","vpn","passwall","settings"},cbi("passwall/global"),_("Basic Settings"),1).dependent=true
entry({"admin","vpn","passwall","other"},cbi("passwall/other"),_("Other Settings"),2).leaf=true
entry({"admin","vpn","passwall","balancing"},cbi("passwall/balancing"),_("Load Balancing"),3).leaf=true
entry({"admin","vpn","passwall","rule"},cbi("passwall/rule"),_("Rule Update"),4).leaf=true
entry({"admin","vpn","passwall","acl"},cbi("passwall/acl"),_("Access control"),5).leaf=true
entry({"admin","vpn","passwall","rulelist"},cbi("passwall/rulelist"),_("Set Blacklist And Whitelist"),6).leaf=true
entry({"admin","vpn","passwall","log"},cbi("passwall/log"),_("Watch Logs"),7).leaf=true
entry({"admin","vpn","passwall","serverconfig"},cbi("passwall/serverconfig")).leaf=true
entry({"admin","vpn","passwall","ss_status"},call("ss_status")).leaf=true
entry({"admin","vpn","passwall","status"},call("act_status")).leaf=true
entry({"admin","vpn","passwall","kcpstatus"},call("kcp_status")).leaf=true
entry({"admin","vpn","passwall","hrstatus"},call("hr_status")).leaf=true
entry({"admin","vpn","passwall","ping"},call("act_ping")).leaf=true
entry({"admin","vpn","passwall","china"},call("china_status")).leaf=true
entry({"admin","vpn","passwall","foreign"},call("foreign_status")).leaf=true
entry({"admin", "vpn", "passwall", "kcp_check"}, call("kcp_check")).leaf = true
entry({"admin", "vpn", "passwall", "kcp_update"}, call("kcp_update")).leaf = true
end
local function http_write_json(content)
	http.prepare_content("application/json")
	http.write_json(content or { code = 1 })
end
function ss_status()
local e={}
e.ss_redir_status=luci.sys.call("pgrep ss-redir >/dev/null || pgrep ssr-redir >/dev/null || pgrep v2ray >/dev/null")==0
e.haproxy_status=luci.sys.call("pgrep haproxy >/dev/null")==0
e.kcp_status=luci.sys.call("pgrep kcp >/dev/null")==0
e.china_status=luci.sys.call("echo `curl -I -o /dev/null -s --connect-timeout 5 -w %{http_code} 'http://www.baidu.com'`|grep 200 >/dev/null")==0
e.foreign_status=luci.sys.call("echo `curl -I -o /dev/null -s --connect-timeout 5 -w %{http_code} 'https://www.google.com.tw'`|grep 200 >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function act_status()
local e={}
e.ss_redir=luci.sys.call("pgrep ss-redir >/dev/null || pgrep ssr-redir >/dev/null || pgrep v2ray >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function hr_status()
local e={}
e.hrstatus=luci.sys.call("pgrep haproxy >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function kcp_status()
local e={}
e.kcpstatus=luci.sys.call("pgrep kcp >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function china_status()
local e={}
e.china=luci.sys.call("echo `curl -I -o /dev/null -s -m 10 --connect-timeout 2 -w %{http_code} 'http://www.baidu.com'`|grep 200 >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function foreign_status()
local e={}
e.foreign=luci.sys.call("echo `curl -I -o /dev/null -s -m 10 --connect-timeout 5 -w %{http_code} 'https://www.google.com.tw'`|grep 200 >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function act_ping()
local e={}
e.index=luci.http.formvalue("index")
e.ping=luci.sys.exec("ping -c 1 -W 1 %q 2>&1|grep -o 'time=[0-9]*.[0-9]'|awk -F '=' '{print$2}'"%luci.http.formvalue("domain"))
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end

function kcp_check(type)
	local json = nil
	if type == "kcptun" then
		json = kcp.check_kcptun("")
	else
		http.status(500, "Bad address")
		return
	end

	http_write_json(json)
end

function kcp_update(type)
	local json = nil
	local task = http.formvalue("task")
	if task == "extract" then
		json = kcp.extract_kcptun(http.formvalue("file"), http.formvalue("subfix"))
	elseif task == "move" then
		json = kcp.move_kcptun(http.formvalue("file"))
	else
		json = kcp.download_kcptun(http.formvalue("url"))
	end

	http_write_json(json)
end