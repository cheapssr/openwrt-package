local e={}
local o=require"luci.dispatcher"
local a=luci.util.execi("/bin/busybox top -bn1 | grep 'pppd plugin rp-pppoe.so'")
for t in a do
local a,n,h,s,o,i=t:match(
"^ *(%d+) +(%d+) +.+options%.pptpd +(%d+) +(%S.-%S)%:(%S.-%S) +.+ +(.+)"
)
local t=tonumber(a)
if t then
e["%02i.%s"%{t,"online"}]={
['PID']=a,
['PPID']=n,
['SPEED']=h,
['GATEWAY']=s,
['VIP']=o,
['CIP']=i,
['BLACKLIST']=0
}
end
end
f=SimpleForm("processes",translate("PPPoE Server"))
f.reset=false
f.submit=false
f.description = translate("The PPPoE server is a broadband access authentication server that prevents ARP spoofing.")
t=f:section(Table,e,translate("Online Users"))
t:option(DummyValue,"GATEWAY",translate("Server IP"))
t:option(DummyValue,"VIP",translate("Client IP"))
t:option(DummyValue,"CIP",translate("IP address"))

kill=t:option(Button,"_kill",translate("Forced offline"))
kill.inputstyle="reset"
function kill.write(e,t)
null,e.tag_error[t]=luci.sys.process.signal(e.map:get(t,"PID"),9)
luci.http.redirect(o.build_url("admin/services/rp-pppoe-server/online"))
end
return f
