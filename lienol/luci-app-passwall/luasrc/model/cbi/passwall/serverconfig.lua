local i="passwall"
local d=require"luci.dispatcher"
local r=require("luci.model.ipkg")
local a,t,e
local o={
"none",
"auto",
"table",
"rc4",
"rc4-md5",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"aes-128-gcm",
"aes-192-gcm",
"aes-256-gcm",
"bf-cfb",
"camellia-128-cfb",
"camellia-192-cfb",
"camellia-256-cfb",
"cast5-cfb",
"des-cfb",
"idea-cfb",
"rc2-cfb",
"seed-cfb",
"salsa20",
"xsalsa20",
"chacha20",
"xchacha20",
"chacha20-ietf",
"chacha20-ietf-poly1305",
"chacha20-poly1305",
"xchacha20-ietf-poly1305",
}
local h={
"origin",
"verify_simple",
"verify_deflate",
"verify_sha1",
"auth_simple",
"auth_sha1",
"auth_sha1_v2",
"auth_sha1_v4",
"auth_aes128_md5",
"auth_aes128_sha1",
"auth_chain_a",
"auth_chain_b",
"auth_chain_c",
"auth_chain_d",
}
local s={
"plain",
"http_simple",
"http_post",
"random_head",
"tls_simple",
"tls1.0_session_auth",
"tls1.2_ticket_auth",
}
local n={
"false",
"true",
}
local v2rayProtocol={
"tcp",
"kcp",
"ws",
}
local v2rayTcpobfs={
"none",
"http",
}
local v2rayKcpobfs={
"none",
"srtp",
"utp",
"wechat-video",
}

local find_ss_redir=luci.sys.exec("find /usr/*bin -name ss-redir")
local find_ssr_redir=luci.sys.exec("find /usr/*bin -name ssr-redir")

if r.installed("passwall-polarssl")then
for e=1,5,1 do table.remove(o,11)end
end
arg[1]=arg[1]or""
a=Map(i,translate("ShadowSocks Server Config"),translate("Leave the default false if the server does not support TCP_fastopen and Onetime Authentication."))
a.redirect=d.build_url("admin","vpn","passwall")
t=a:section(NamedSection,arg[1],"servers","")
t.addremove=false
t.dynamic=false
e=t:option(Value,"remarks",translate("Node Remarks"))
e.default="Shadowsocks"
e.rmempty=false
serverType=t:option(ListValue,"server_type",translate("Server Type"))
if find_ss_redir~="" then
serverType:value("ss",translate("Shadowsocks Server"))
end
if find_ssr_redir~="" then
serverType:value("ssr",translate("ShadowsocksR Server"))
end
if r.installed("v2ray")then
serverType:value("v2ray",translate("V2ray Server"))
end

e.rmempty=false
e=t:option(Value,"server",translate("Server Address"))
--e.datatype="host"
e.rmempty=false

e=t:option(Flag,"use_ipv6",translate("Use IPv6"))
e.default=0

e=t:option(Flag,"parsing_ip",translate("Parsing IP"))
e.default=0

e=t:option(Value,"server_port",translate("Server Port"))
e.datatype="port"
e.rmempty=false
e=t:option(Value,"password",translate("Password"))
e.password=true
e.rmempty=false
e:depends("server_type","ss")
e:depends("server_type","ssr")

e=t:option(ListValue,"encrypt_method",translate("Encrypt Method"))
for a,t in ipairs(o)do e:value(t)end
e.rmempty=false

e=t:option(ListValue,"protocol",translate("Protocol"))
for a,t in ipairs(h)do e:value(t)end
e:depends("server_type","ssr")

e=t:option(Value,"protocol_param",translate("Protocol_param"))
e.rmempty=true
e:depends("server_type","ssr")

e=t:option(ListValue,"obfs",translate("Obfs"))
for a,t in ipairs(s)do e:value(t)end
e:depends("server_type","ssr")

e=t:option(Value,"obfs_param",translate("Obfs_param"))
e.rmempty=true
e:depends("server_type","ssr")

e=t:option(Value,"timeout",translate("Connection Timeout"))
e.datatype="uinteger"
e.default=300
e.rmempty=false
e:depends("server_type","ss")
e:depends("server_type","ssr")

e=t:option(Value,"local_port",translate("Local Port"))
e.datatype="port"
e.default=1080
e.rmempty=false

e=t:option(ListValue,"fast_open",translate("Fast_open"))
for a,t in ipairs(n)do e:value(t)end
e.rmempty=false
e:depends("server_type","ss")
e:depends("server_type","ssr")

e=t:option(Value,"plugin",translate("Plugin Name"))
e.placeholder="obfs-local"
e:depends("server_type","ss")

e=t:option(Value,"plugin_opts",translate("Plugin Arguments"))
e.placeholder="obfs=http;obfs-host=www.bing.com"
e:depends("server_type","ss")

e=t:option(Value,"v2ray_id",translate("ID"))
e.password=true
e.rmempty=false
e:depends("server_type","v2ray")

e=t:option(Value,"v2ray_alterId",translate("Alter Id"))
e.rmempty=false
e:depends("server_type","v2ray")

e=t:option(ListValue,"v2ray_network_type",translate("Network Type"))
for a,t in ipairs(v2rayProtocol)do e:value(t)end
e:depends("server_type","v2ray")

e=t:option(ListValue,"v2ray_tcp_obfs",translate("TCP Obfs"))
for a,t in ipairs(v2rayTcpobfs)do e:value(t)end
e:depends("v2ray_network_type","tcp")

e=t:option(ListValue,"v2ray_kcp_obfs",translate("KCP Obfs"))
for a,t in ipairs(v2rayKcpobfs)do e:value(t)end
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_mtu",translate("KCP MTU"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_tti",translate("KCP TTI"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_uplinkCapacity",translate("KCP uplinkCapacity"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_downlinkCapacity",translate("KCP downlinkCapacity"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_readBufferSize",translate("KCP readBufferSize"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_kcp_writeBufferSize",translate("KCP writeBufferSize"))
e:depends("v2ray_network_type","kcp")

e=t:option(Flag,"v2ray_kcp_congestion",translate("KCP Congestion"))
e:depends("v2ray_network_type","kcp")

e=t:option(Value,"v2ray_ws_path",translate("WebSocket Path"))
e:depends("v2ray_network_type","ws")

e=t:option(Value,"v2ray_ws_header",translate("WebSocket Header"))
e:depends("v2ray_network_type","ws")

e=t:option(Flag,"v2ray_mux",translate("Mux"))
e:depends("server_type","v2ray")

e=t:option(Flag,"v2ray_tls",translate("TLS"),translate("Using TLS must use the domain name as the server address"))
e:depends("server_type","v2ray")

e=t:option(Flag,"forwarding_ipv6",translate("Forwarding IPv6"),translate("The IPv6 traffic can be forwarded when selected"))
e.default=0

e=t:option(Flag,"use_kcp",translate("Use KCPTUN"),translate("<span style='color:red'>Please confirm whether the KCP is installed. If not, please go to Rule Update download installation</span>"))
e.default=0
e:depends("server_type","ss")
e:depends("server_type","ssr")
e=t:option(Value,"kcp_server",translate("KCP Server"))
e.placeholder=translate("Default:Current Server")
e:depends("use_kcp","1")
e=t:option(Flag,"kcp_use_ipv6",translate("Use IPv6"))
e.default=0
e:depends("use_kcp","1")
e=t:option(Flag,"kcp_parsing_ip",translate("Parsing IP"))
e.default=0
e:depends("use_kcp","1")
e=t:option(Value,"kcp_port",translate("KCP Port"))
e.datatype="port"
e:depends("use_kcp","1")
e=t:option(TextValue,"kcp_opts",translate("KCP Config"),translate("--crypt aes192 --key koolshare --mtu 1350 --sndwnd 128 --rcvwnd 1024 --mode fast<br><font style='color:red'>Note: UDP cannot be forwarded after KCP is turned on.</font>"))
e.placeholder="--crypt aes192 --key koolshare --mtu 1350 --sndwnd 128 --rcvwnd 1024 --mode fast"
e:depends("use_kcp","1")
return a
