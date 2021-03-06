#!/bin/sh
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
CONFIG=passwall
LOG_FILE=/var/log/passwall.log
url_main="https://raw.githubusercontent.com/hq450/fancyss/master/rules"
SS_PATH=/usr/share/passwall
DNSMASQ_PATH=$SS_PATH/dnsmasq.d
RULE_PATH=$SS_PATH/rule

uci_get_by_type() {
	local index=0
	if [ -n $4 ]; then
		index=$4
	fi
	local ret=$(uci get $CONFIG.@$1[$index].$2 2>/dev/null)
	echo ${ret:=$3}
}

# detect ss version
#ss_basic_version_web1=`curl -s https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/shadowsocks/version | sed -n 1p`

# rule update
echo $(date): 开始更新shadowsocks规则，请等待... > $LOG_FILE
#wget -q --no-check-certificate --timeout=15 https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/version1 -O /tmp/version1
#旧接口https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/version1
status1=`curl -w %{http_code} --connect-timeout 10 $url_main/version1 --silent -o /tmp/version1`
if [ -z "$status1" ] || [ "$status1" == "404" ];then
	echo $(date): 无法访问更新接口，请更新接口！ >> $LOG_FILE
	exit
fi
online_content=$(cat /tmp/version1 2>/dev/null)
if [ -z "$online_content" ];then
	rm -rf /tmp/version1
	echo $(date): 没有检测到在线版本，可能是访问github有问题，去大陆白名单模式试试吧！ >> $LOG_FILE
	exit
fi

# update gfwlist
gfwlist=$(cat /tmp/version1 | sed -n 1p)
version_gfwlist2=$(echo $gfwlist | sed 's/ /\n/g'| sed -n 1p)
md5sum_gfwlist2=$(echo $gfwlist | sed 's/ /\n/g'| tail -n 2 | head -n 1)
local_md5sum_gfwlist=`md5sum  $DNSMASQ_PATH/gfwlist.conf |awk '{print $1}'`
if [ ! -z "$version_gfwlist2" ];then
	version_gfwlist1=$(uci_get_by_type global gfwlist_version)
		if [ "$version_gfwlist1" != "$version_gfwlist2" -o "$md5sum_gfwlist2" != "$local_md5sum_gfwlist" ];then
			echo $(date): 检测到新版本gfwlist，开始更新... >> $LOG_FILE
			echo $(date): 下载gfwlist到临时文件... >> $LOG_FILE
			#wget --no-check-certificate --timeout=15 -q https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/gfwlist.conf -O /tmp/gfwlist.conf
			#旧接口https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/gfwlist.conf
			status2=`curl -w %{http_code} --connect-timeout 10 $url_main/gfwlist.conf --silent -o /tmp/gfwlist.conf`
			if [ -z "$status2" ] || [ "$status2" == "404" ];then
				echo $(date): 无法访问更新接口，请更新接口！ >> $LOG_FILE
			exit
			fi
			md5sum_gfwlist1=$(md5sum /tmp/gfwlist.conf | sed 's/ /\n/g'| sed -n 1p)
			if [ "$md5sum_gfwlist1"x = "$md5sum_gfwlist2"x ];then
				echo $(date): 下载完成，校验通过，将临时文件覆盖到原始gfwlist文件 >> $LOG_FILE
				mv /tmp/gfwlist.conf $DNSMASQ_PATH/gfwlist.conf
				uci set $CONFIG.@global[0].gfwlist_version=$version_gfwlist2
				rm -rf /tmp/dnsmasq.d/gfwlist.conf
				reboot="1"
				echo $(date): 你的gfwlist已经更新到最新了哦~ >> $LOG_FILE
			else
				echo $(date): 下载完成，但是校验没有通过！ >> $LOG_FILE
			fi
		else
			echo $(date): 检测到gfwlist本地版本号和在线版本号相同，不用更新! >> $LOG_FILE
		fi
	else
		echo $(date): gfwlist文件下载失败！ >> $LOG_FILE
fi

rm -rf /tmp/gfwlist.conf


# update chnroute
chnroute=$(cat /tmp/version1 | sed -n 2p)
version_chnroute2=$(echo $chnroute | sed 's/ /\n/g'| sed -n 1p)
md5sum_chnroute2=$(echo $chnroute | sed 's/ /\n/g'| tail -n 2 | head -n 1)
local_md5sum_chnroute=`md5sum $RULE_PATH/chnroute |awk '{print $1}'`
if [ ! -z "$version_chnroute2" ];then
	version_chnroute1=$(uci_get_by_type global chnroute_version)
		if [ "$version_chnroute1" != "$version_chnroute2" -o "$md5sum_chnroute2" != "$local_md5sum_chnroute" ];then
			echo $(date): 检测到新版本chnroute，开始更新... >> $LOG_FILE
			echo $(date): 下载chnroute到临时文件... >> $LOG_FILE
			#wget --no-check-certificate --timeout=15 -q https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/chnroute.txt -O /tmp/chnroute
			#旧接口https://raw.githubusercontent.com/monokoo/koolshare.github.io/acelan_softcenter_ui/maintain_files/chnroute.txt
			status3=`curl -w %{http_code} --connect-timeout 10 $url_main/chnroute.txt --silent -o /tmp/chnroute`
			if [ -z "$status3" ] || [ "$status3" == "404" ];then
				echo $(date): 无法访问更新接口，请更新接口！ >> $LOG_FILE
			exit
			fi
			md5sum_chnroute1=$(md5sum /tmp/chnroute | sed 's/ /\n/g'| sed -n 1p)
			if [ "$md5sum_chnroute1"x = "$md5sum_chnroute2"x ];then
				echo $(date): 下载完成，校验通过，将临时文件覆盖到原始chnroute文件 >> $LOG_FILE
				mv /tmp/chnroute $RULE_PATH/chnroute
				uci set $CONFIG.@global[0].chnroute_version=$version_chnroute2
				ipset flush chnroute
				ipset destroy chnroute
				reboot="1"
				echo $(date): 你的chnroute已经更新到最新了哦~ >> $LOG_FILE
			else
				echo $(date): 下载完成，但是校验没有通过！ >> $LOG_FILE
			fi
		else
			echo $(date): 检测到chnroute本地版本号和在线版本号相同，不用更新! >> $LOG_FILE
		fi
	else
		echo $(date): chnroute文件下载失败！ >> $LOG_FILE
fi

rm -rf /tmp/chnroute

# update Routing
Routing=$(cat /tmp/version1 | sed -n 5p)
version_Routing2=$(echo $Routing | sed 's/ /\n/g'| sed -n 1p)
md5sum_Routing2=$(echo $Routing | sed 's/ /\n/g'| tail -n 2 | head -n 1)
local_md5sum_Routing=`md5sum /etc/pcap-dnsproxy/Routing.txt |awk '{print $1}'`
if [ ! -z "$version_Routing2" ];then
	version_Routing1=$(uci_get_by_type global pcap_Routing_version)
		if [ "$version_Routing1" != "$version_Routing2" -o "$md5sum_Routing2" != "$local_md5sum_Routing" ];then
			echo $(date): 检测到新版本Routing，开始更新... >> $LOG_FILE
			echo $(date): 下载Routing到临时文件... >> $LOG_FILE
			status4=`curl -w %{http_code} --connect-timeout 10 $url_main/Routing.txt --silent -o /tmp/Routing.txt`
			if [ -z "$status4" ] || [ "$status4" == "404" ];then
				echo $(date): 无法访问更新接口，请更新接口！ >> $LOG_FILE
			exit
			fi
			md5sum_Routing1=$(md5sum /tmp/Routing.txt | sed 's/ /\n/g'| sed -n 1p)
			if [ "$md5sum_Routing1"x = "$md5sum_Routing2"x ];then
				echo $(date): 下载完成，校验通过，将临时文件覆盖到原始Routing文件 >> $LOG_FILE
				mkdir -p /etc/pcap-dnsproxy
				mv /tmp/Routing.txt /etc/pcap-dnsproxy/Routing.txt
				uci set $CONFIG.@global[0].pcap_Routing_version=$version_Routing2
				reboot="1"
				echo $(date): 你的Routing已经更新到最新了哦~ >> $LOG_FILE
			else
				echo $(date): 下载完成，但是校验没有通过！ >> $LOG_FILE
			fi
		else
			echo $(date): 检测到Routing本地版本号和在线版本号相同，不用更新! >> $LOG_FILE
		fi
	else
		echo $(date): Routing文件下载失败！ >> $LOG_FILE
fi

rm -rf /tmp/Routing.txt

# update WhiteList
WhiteList=$(cat /tmp/version1 | sed -n 7p)
version_WhiteList2=$(echo $WhiteList | sed 's/ /\n/g'| sed -n 1p)
md5sum_WhiteList2=$(echo $WhiteList | sed 's/ /\n/g'| tail -n 2 | head -n 1)
local_md5sum_WhiteList=`md5sum /etc/pcap-dnsproxy/WhiteList.txt |awk '{print $1}'`
if [ ! -z "$version_WhiteList2" ];then
	version_WhiteList1=$(uci_get_by_type global pcap_WhiteList_version)
		if [ "$version_WhiteList1" != "$version_WhiteList2" -o "$md5sum_WhiteList2" != "$local_md5sum_WhiteList" ];then
			echo $(date): 检测到新版本WhiteList，开始更新... >> $LOG_FILE
			echo $(date): 下载WhiteList到临时文件... >> $LOG_FILE
			status4=`curl -w %{http_code} --connect-timeout 10 $url_main/WhiteList_new.txt --silent -o /tmp/WhiteList.txt`
			if [ -z "$status4" ] || [ "$status4" == "404" ];then
				echo $(date): 无法访问更新接口，请更新接口！ >> $LOG_FILE
			exit
			fi
			#wget --no-check-certificate --timeout=10 -qO - $url_main/WhiteList_new.txt > /tmp/WhiteList.txt
			md5sum_WhiteList1=$(md5sum /tmp/WhiteList.txt | sed 's/ /\n/g'| sed -n 1p)
			if [ "$md5sum_WhiteList1"x = "$md5sum_WhiteList2"x ];then
				echo $(date): 下载完成，校验通过，将临时文件覆盖到原始WhiteList文件 >> $LOG_FILE
				mkdir -p /etc/pcap-dnsproxy
				mv /tmp/WhiteList.txt /etc/pcap-dnsproxy/WhiteList.txt
				uci set $CONFIG.@global[0].pcap_WhiteList_version=$version_WhiteList2
				reboot="1"
				echo $(date): 你的WhiteList已经更新到最新了哦~ >> $LOG_FILE
			else
				echo $(date): 下载完成，但是校验没有通过！ >> $LOG_FILE
			fi
		else
			echo $(date): 检测到WhiteList本地版本号和在线版本号相同，不用更新! >> $LOG_FILE
		fi
	else
		echo $(date): WhiteList文件下载失败！ >> $LOG_FILE
fi

#rm -rf /tmp/WhiteList.txt

echo $(date): Shadowsocks更新进程运行完毕！ >> $LOG_FILE
rm -rf /tmp/version1
# write number
uci commit
# reboot ss
if [ "$reboot" == "1" ];then
echo $(date): 自动重启shadowsocks，以应用新的规则文件！请稍后！ >> $LOG_FILE
/etc/init.d/shadowsocks restart
fi
exit
