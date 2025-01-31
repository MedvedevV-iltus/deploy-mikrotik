/system script
add dont-require-permissions=no name=preparation source=":global wifipass StrongPassword;:global waniface ether1;:global ssid Wireless; :local inkey 1;\
    \n:global tunaddr \"0.0.0.0\";:global tunuser user;:global tunpasswd password;:global tunipsec ipsec;:global trustednet \"10.33.0.0/24\";\
    \n:global inkeytun 1;\
    \n:put message=\"-----------------------------------------------------------------------------\$[/terminal/style comment]\";\
    \n:put message=\"\\t\\tMikrotik configuration script\\n\\r\\t\\tCreated by Medvedev Vladimir\$[/terminal/style escaped]\"; \
    \n:put message=\"\\t\\tEmail: medvedev.v@iltus.ru\\n\\r\\t\\tTelegram: @while_do\$[/terminal/style escaped ]\";\
    \n:put message=\"Documentation avalible in https://github.com/MedvedevV-iltus/deploy-mikrotik/blob/main/README.md\";\
    \n:put message=\"-----------------------------------------------------------------------------\\n\\n\\r\$[/terminal/style comment]\";\
    \n:put message=\"Press N to cancel running script, or any other key to start right now...\\n\\n\\r \$[/terminal/style style=syntax-noterm]\";\
    \n:set inkey value=[/terminal/inkey timeout=15s]\
    \n:if (\$inkey!=110 && \$inkey!=78) do={\
    \n  :set ssid value=[/terminal/ask prompt=\"Edit name(SSID) of WiFi (default=\$ssid)\" preinput=\$ssid value-name=\"Wi-Fi(SSID): \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :put message=\"\\n\\n\\rEnter password for WiFi (dafault=\$wifipass)\$[/terminal/style style=syntax-noterm]\";\
    \n  :set wifipass value=[/terminal/ask prompt=\"NB! This password will be set to admin user of Mirotik!\" preinput=\$wifipass value-name=\"Password: \$[/terminal/style style=varname]\"];\
    \n  :set waniface value=[/terminal/ask prompt=\"\\n\\n\\rEdit name of WAN-interface (default=\$waniface)\" preinput=\$waniface value-name=\"WAN: \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :put message=\"Press Y in 10 seconds to add tunnel parametrs\$[/terminal/style style=syntax-noterm]\";\
    \n  :set inkeytun value=[/terminal/inkey timeout=10s];\
    \n  :if (\$inkeytun=121 || \$inkeytun=89) do={\
    \n    :put message=\"-----------------------------------------------------------------------------\\n\\n\\r\$[/terminal/style comment]\";\
    \n    :put message=\"For continue you need enter L2TP/IPSec parametrs.\\n\\rIf you don't have them, please contact with Vladimir Medvedev\$[/terminal/style style=varname]\"\
    \n    :put message=\"\\tEmail: medvedev.v@iltus.ru\\n\\r\\tTelegram: @while_do\$[/terminal/style escaped ]\"\
    \n    :set tunaddr value=[/terminal/ask prompt=\"\\n\\n\\rEnter endpoint address of Tunnel\" value-name=\"IP: \$[/terminal/style style=syntax-noterm ]\"];\
    \n    :set tunuser value=[/terminal/ask prompt=\"\\n\\n\\rEnter L2TP-username\" value-name=\"L2TP user: \$[/terminal/style style=syntax-noterm ]\"];\
    \n    :set tunpasswd value=[/terminal/ask prompt=\"\\n\\n\\rEnter L2TP-password\" value-name=\"L2TP password: \$[/terminal/style style=syntax-noterm ]\"];\
    \n    :set tunipsec value=[/terminal/ask prompt=\"\\n\\n\\rEnter IPSec-key\" value-name=\"IPSec-key: \$[/terminal/style style=syntax-noterm ]\"];\
    \n    }\
    \n    /file add name=flash/startconf.rsc contents=\":global ssid \$ssid;\\\
    \n      \\n:global wifipass \$wifipass;\\\
    \n      \\n:global waniface \$waniface;\\\
    \n      \\n:global tunaddr \$tunaddr;\\\
    \n      \\n:global tunuser \$tunuser;\\\
    \n      \\n:global tunpasswd \$tunpasswd;\\\
    \n      \\n:global tunipsec \$tunipsec;\\\
    \n      \\n:global inkeytun \$inkeytun;\\\
    \n      \\n:global trustednet \$trustednet;\\\
    \n      \\n:local nowifi 0;\\\
    \n      \\n\\\
    \n      \\n:log info \\\"Starting defconf script\\\";\\\
    \n      \\n\\\
    \n      \\n:local count 0;\\\
    \n      \\n:while ([/interface ethernet find] = \\\"\\\") do={\\\
    \n      \\n :if (\\\$count = 30) do={\\\
    \n      \\n   :log warning \\\"Unable to find ethernet interfaces\\\";\\\
    \n      \\n   /quit;\\\
    \n      \\n }\\\
    \n      \\n :delay 1s; :set count (\\\$count +1); \\\
    \n      \\n};\\\
    \n      \\n:local count 0;\\\
    \n      \\n:while ([/interface wireless print count-only] < 1) do={ \\\
    \n      \\n :set count (\\\$count +1);\\\
    \n      \\n :if (\\\$count = 40) do={\\\
    \n      \\n   :log warning \\\"Unable to find wireless interface(s)\\\";\\\
    \n      \\n   :set nowifi 1; \\\
    \n      \\n }\\\
    \n      \\n :delay 1s;\\\
    \n      \\n};\\\
    \n      \\n\\\
    \n      \\n#==============INTERFACES========================================================================================================\\\
    \n      \\n\\\
    \n      \\n/interface list add name=WAN\\\
    \n      \\n/interface list add name=LAN\\\
    \n      \\n\\\
    \n      \\n/interface bridge add name=bridge disabled=no auto-mac=yes protocol-mode=rstp;\\\
    \n      \\n:local bMACIsSet 0;\\\
    \n      \\n:foreach k in=[/interface find where !(slave=yes   || name=\\\$waniface || passthrough=yes || type=loopback || name~\\\"bridge\\\")] do={\\\
    \n      \\n :local tmpPortName [/interface get \\\$k name];\\\
    \n      \\n :if (\\\$bMACIsSet = 0) do={\\\
    \n      \\n   :if ([/interface get \\\$k type] = \\\"ether\\\") do={\\\
    \n      \\n    /interface bridge set \\\"bridge\\\" auto-mac=no admin-mac=[/interface get \\\$tmpPortName mac-address];\\\
    \n      \\n     :set bMACIsSet 1;\\\
    \n      \\n   }\\\
    \n      \\n }\\\
    \n      \\n :if (([/interface get \\\$k type] != \\\"ppp-out\\\") && ([/interface get \\\$k type] != \\\"lte\\\")) do={\\\
    \n      \\n   /interface bridge port add bridge=bridge interface=\\\$tmpPortName;\\\
    \n      \\n }\\\
    \n      \\n}\\\
    \n      \\n\\\
    \n      \\n\\\
    \n      \\n#===============WIFI==============================================================================================================\\\
    \n      \\n:if (\\\$nowifi=0) do={\\\
    \n      \\n /interface wireless {\\\
    \n      \\n   security-profiles add name=custom mode=dynamic-keys wpa2-pre-shared-key=\\\$wifipass authentication-types=wpa2-psk\\\
    \n      \\n   :local ifcId [/interface wireless find where default-name=wlan1]\\\
    \n      \\n   :local currentName [/interface wireless get \\\$ifcId name]\\\
    \n      \\n   set \\\$ifcId mode=ap-bridge band=2ghz-b/g/n disabled=no wireless-protocol=802.11 distance=indoors installation=any\\\
    \n      \\n   set \\\$ifcId channel-width=20/40mhz-XX security-profile=custom country=russia4\\\
    \n      \\n   set \\\$ifcId frequency=auto\\\
    \n      \\n   set \\\$ifcId ssid=\\\$ssid\\\
    \n      \\n }\\\
    \n      \\n}\\\
    \n      \\n\\\
    \n      \\n/ip pool add name=\\\"dhcp\\\" ranges=192.168.88.10-192.168.88.254;\\\
    \n      \\n/ip dhcp-server add name=defconf address-pool=\\\"dhcp\\\" interface=bridge disabled=no;\\\
    \n      \\n/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=192.168.88.1;\\\
    \n      \\n/ip address add address=192.168.88.1/24 interface=bridge;\\\
    \n      \\n/ip dns set allow-remote-requests=yes\\\
    \n      \\n\\\
    \n      \\n\\\
    \n      \\n#=============WAN INTERFACE====================================================================================================\\\
    \n      \\n\\\
    \n      \\n/ip dhcp-client add interface=\\\$waniface disabled=no;\\\
    \n      \\n/interface list member add list=LAN interface=bridge;\\\
    \n      \\n/interface list member add list=WAN interface=\\\$waniface;\\\
    \n      \\n\\\
    \n      \\n/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade comment=\\\"masquerade\\\"\\\
    \n      \\n/ip firewall {\\\
    \n      \\n filter add chain=input action=accept connection-state=established,related,untracked comment=\\\"accept established,related,untracked\\\"\\\
    \n      \\n filter add chain=input action=drop connection-state=invalid comment=\\\"drop invalid\\\"\\\
    \n      \\n filter add chain=input action=accept src-address-list=trusted;\\\
    \n      \\n filter add chain=input action=accept protocol=icmp comment=\\\"accept ICMP\\\"\\\
    \n      \\n filter add chain=input action=drop in-interface-list=!LAN comment=\\\"drop all not coming from LAN\\\" \\\
    \n      \\n filter add chain=forward action=accept connection-state=established,related,untracked comment=\\\"accept established,related, untracked\\\"\\\
    \n      \\n filter add chain=forward action=drop connection-state=invalid comment=\\\"drop invalid\\\"\\\
    \n      \\n filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment=\\\"defconf: drop all from WAN not DSTNATed\\\"\\\
    \n      \\n}\\\
    \n      \\n\\\
    \n      \\n/ip neighbor discovery-settings set discover-interface-list=LAN\\\
    \n      \\n/tool mac-server set allowed-interface-list=LAN\\\
    \n      \\n/tool mac-server mac-winbox set allowed-interface-list=LAN\\\
    \n      \\n/ip neighbor discovery-settings set discover-interface-list=LAN\\\
    \n      \\n/tool mac-server set allowed-interface-list=LAN\\\
    \n      \\n/tool mac-server mac-winbox set allowed-interface-list=LAN\\\
    \n      \\n\\\
    \n      \\n#===============CUSTOMISATION====================================================================================================\\\
    \n      \\n\\\
    \n      \\n/user set password=\\\$wifipass [find name=admin];\\\
    \n      \\n:if (\\\$inkeytun=121 || \\\$inkeytun=89) do={\\\
    \n      \\n /user add name=\\\$tunuser password=\\\$tunpasswd group=full;\\\
    \n      \\n /interface l2tp-client\\\
    \n      \\n   add name=l2tp-k12 connect-to=\\\$tunaddr user=\\\$tunuser password=\\\$tunpasswd disabled=no use-ipsec=yes ipsec-secret=\\\$tunipsec use-peer-dns=no add-default-route=no;\\\
    \n      \\n /ip route add disabled=no dst-address=\\\$trustednet gateway=l2tp-k12;\\\
    \n      \\n /ip firewall address-list add address=\\\$trustednet list=trusted;\\\
    \n      \\n}\\\
    \n      \\n\\\
    \n      \\n/ip/cloud set update-time=no\\\
    \n      \\n/system/ntp/client set enabled=yes mode=unicast servers=ru.pool.ntp.org\\\
    \n      \\n\\\
    \n      \\n/system/identity/set name=GW-sputnik\\\
    \n      \\n/ipv6/settings/set disable-ipv6=yes\\\
    \n      \\n/ip/service/set disabled=yes [find name!=winbox]\\\
    \n      \\n/ip/service/set disabled=no [find name=ssh]\\\
    \n      \\n/tool/bandwidth-server/set enabled=no\\\
    \n      \\n\\\
    \n      \\n/system logging action add name=extra target=memory memory-lines=2000;\\\
    \n      \\n/system logging add action=extra topics=script;\\\
    \n      \\n\\\
    \n      \\n#===================ADDING SCRIPTS FOR LIMIT TRAFFIC============================================================================\\\
    \n      \\n\\\
    \n      \\n#===INIT-FIRST===\\\
    \n      \\n\\\
    \n      \\n/system script add dont-require-permissions=no owner=admin name=initFirst policy=read,write source=\\\"\\\
    \n      \\n#initglobal VARS. Then run script to init global FUNCS\\\
    \n      \\n/log debug \\\\\\\"starting init first step: init global Vars\\\\\\\"\\\
    \n      \\n:delay delay-time=60s; \\\
    \n      \\n:global resultRx 0;\\\
    \n      \\n/log debug \\\\\\\"var resultRx = \\\\\\\$resultRx\\\\\\\"\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global resultTx 0;\\\
    \n      \\n/log debug \\\\\\\"var resultTx = \\\\\\\$resultTx\\\\\\\"\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global lastRx 0;\\\
    \n      \\n/log debug \\\\\\\"var lastRx = \\\\\\\$lastRx\\\\\\\"\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global lastTx 0;\\\
    \n      \\n/log debug \\\\\\\"var lastTx = \\\\\\\$lastTx\\\\\\\"\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global cudate 2869w00:00:00;\\\
    \n      \\n/log debug \\\\\\\"var cudate = \\\\\\\$cudate\\\\\\\"\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global limit 2000000000;\\\
    \n      \\n:global period 24h;\\\
    \n      \\n:global queued 0;\\\
    \n      \\n/log debug \\\\\\\"execute init second step\\\\\\\"\\\
    \n      \\n:onerror errorName in={ /system/script/run initSecond } do={/log error \\\\\\\"init Second step stoped with error \\\\\\\$errorName\\\\\\\"}\\\
    \n      \\n:delay 1s;\\\
    \n      \\n/log debug \\\\\\\"first step is over\\\\n---------------------------\\\\\\\"\\\"\\\
    \n      \\n\\\
    \n      \\n#===INIT-SECOND===\\\
    \n      \\n\\\
    \n      \\n\\\
    \n      \\n/system script add dont-require-permissions=no owner=admin name=initSecond policy=read,write source=\\\"\\\
    \n      \\n/log debug \\\\\\\"init: second step started\\\\\\\";\\\
    \n      \\n:delay delay-time=30s;\\\
    \n      \\n:global GetRx do={:return [([/interface ethernet get value-name=rx-bytes [find default-name=\\\$waniface]]->0)]}\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n:global GetTx do={:return [([/interface ethernet get value-name=tx-bytes [find default-name=\\\$waniface]]->0)]}\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n\\\
    \n      \\n:global Analyze do={\\\
    \n      \\n :global cudate; :global period; :global limit;\\\
    \n      \\n :if (([:timestamp] - \\\\\\\$cudate) > \\\\\\\$period) do={\\\
    \n      \\n   #new day!!!\\\
    \n      \\n   :return 2; } else={\\\
    \n      \\n   :global resultTx;\\\
    \n      \\n   :global resultRx;\\\
    \n      \\n   :if ((\\\\\\\$resultTx + \\\\\\\$resultRx) >= \\\\\\\$limit) do={\\\
    \n      \\n   #limit!!!\\\
    \n      \\n   :return 1; } else={:return 0}\\\
    \n      \\n }\\\
    \n      \\n}\\\
    \n      \\n:delay delay-time=1s;\\\
    \n      \\n\\\
    \n      \\n:global GetValues do={\\\
    \n      \\n :global lastRx; :global lastTx; :global resultRx; :global resultTx;\\\
    \n      \\n :global GetTx; :global GetRx;\\\
    \n      \\n #get new values of Rx/Tx\\\
    \n      \\n :local newTx [\\\\\\\$GetTx]\\\
    \n      \\n :local newRx [\\\\\\\$GetRx]\\\
    \n      \\n  \\\
    \n      \\n :if (\\\\\\\$lastRx <= \\\\\\\$newRx) do={\\\
    \n      \\n   :set resultRx [(\\\\\\\$resultRx + \\\\\\\$newRx - \\\\\\\$lastRx )]; \\\
    \n      \\n   :set resultTx [(\\\\\\\$resultTx + \\\\\\\$newTx - \\\\\\\$lastTx )]; }\\\
    \n      \\n :set lastRx [\\\\\\\$newRx]; :set lastTx [\\\\\\\$newTx];\\\
    \n      \\n :return 0;\\\
    \n      \\n}\\\
    \n      \\n\\\
    \n      \\n:global SaveVars do={\\\\\\\
    \n      \\n    \\\\n  :global resultRx; :global resultTx; :global lastRx; :global lastTx;\\\\\\\
    \n      \\n    \\\\n  :global cudate; :global queued; :global limit; :global period;\\\\\\\
    \n      \\n    \\\\n  /system/script/set [find name=initFirst] source=\\\\\\\"#initglobal VARS. Then run script to init global FUNCS\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"starting init first step: init global Vars\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=60s; \\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global resultRx \\\\\\\$resultRx;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var resultRx = \\\\\\\\\\\\\\\$resultRx\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global resultTx \\\\\\\$resultTx;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var resultTx = \\\\\\\\\\\\\\\$resultTx\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global lastRx \\\\\\\$lastRx;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var lastRx = \\\\\\\\\\\\\\\$lastRx\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global lastTx \\\\\\\$lastTx;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var lastTx = \\\\\\\\\\\\\\\$lastTx\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global cudate \\\\\\\$cudate;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var cudate = \\\\\\\\\\\\\\\$cudate\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global limit \\\\\\\$limit;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global period \\\\\\\$period;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:global queued \\\\\\\$queued;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"execute init second step\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:onerror errorName in={ /system/script/run initSecond } do={/log error \\\\\\\\\\\\\\\"init Second step stoped with error \\\\\\\\\\\\\\\$errorName\\\\\\\\\\\\\\\"}\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n:delay 1s;\\\\\\\\\\\\\\\
    \n      \\n    \\\\n    \\\\\\\\n/log debug \\\\\\\\\\\\\\\"first step is over\\\\\\\\\\\\\\\\n---------------------------\\\\\\\\\\\\\\\"\\\\\\\"\\\\\\\
    \n      \\n    \\\\n}\\\
    \n      \\n\\\
    \n      \\n:delay delay-time=5s;\\\
    \n      \\n:execute script={/system/script/run main }\\\"\\\
    \n      \\n\\\
    \n      \\n#===MAIN===\\\
    \n      \\n\\\
    \n      \\n/system script add dont-require-permissions=no name=main owner=admin source=\\\"\\\
    \n      \\n#get functions\\\
    \n      \\n:global Analyze;:global GetValues;:global SaveVars;\\\
    \n      \\n:local control 0;:local analyzed 0;:local cycles 0;\\\
    \n      \\n\\\
    \n      \\n:while (\\\\\\\$control=0) do={\\\
    \n      \\n :set cycles (\\\\\\\$cycles + 1)\\\
    \n      \\n /log debug \\\\\\\"start cycle #\\\\\\\$cycles\\\\\\\"\\\
    \n      \\n :set control [\\\\\\\$GetValues]; \\\
    \n      \\n :delay delay-time=5s\\\
    \n      \\n /log debug \\\\\\\"Geted new values...\\\\\\\"\\\
    \n      \\n :set analyzed [\\\\\\\$Analyze]; \\\
    \n      \\n /log debug \\\\\\\"Analyzed\\\\\\\";\\\
    \n      \\n :if (\\\\\\\$analyzed=2) do={\\\
    \n      \\n   #new day! need set resultTx and resultRx to 0, and disable queue\\\
    \n      \\n   :global resultRx 0; :global resultTx 0; :global queued 0;\\\
    \n      \\n   :global period;\\\
    \n      \\n   :global cudate ([:timestamp]/\\\\\\\$period*\\\\\\\$period);\\\
    \n      \\n   /queue/simple/remove [find name=limiter]; \\\
    \n      \\n   :log debug \\\\\\\"results = 0; queue disabled;\\\\\\\"\\\
    \n      \\n }\\\
    \n      \\n :if (\\\\\\\$analyzed=1) do={\\\
    \n      \\n   # reached LIMIT!!! START QUEUE\\\
    \n      \\n   :global queued;\\\
    \n      \\n   :if (\\\\\\\$queued = 0) do={\\\
    \n      \\n   /queue/simple/add name=limiter target=192.168.88.0/24 max-limit=64k/64k disabled=no\\\
    \n      \\n   :set queued 1;\\\
    \n      \\n   :log debug \\\\\\\"reached limit; queue started\\\\\\\" } else={/log debug \\\\\\\"queue is runnig\\\\\\\"}\\\
    \n      \\n }\\\
    \n      \\n :if (\\\\\\\$analyzed=0) do={\\\
    \n      \\n   :global queued;\\\
    \n      \\n   :if (\\\\\\\$queued != 0) do={\\\
    \n      \\n     /queue/simple/remove [find name=limiter];\\\
    \n      \\n     :set queued 0;}\\\
    \n      \\n   :log debug \\\\\\\"check passed; limit is not reached\\\\\\\"\\\
    \n      \\n }\\\
    \n      \\n [\\\\\\\$SaveVars];\\\
    \n      \\n #cycle is over\\\
    \n      \\n /log debug \\\\\\\"cycle #\\\\\\\$cycles is over. wait for 2 seconds\\\\\\\"\\\
    \n      \\n :delay delay-time=2s;\\\
    \n      \\n}\\\"\\\
    \n      \\n\\\
    \n      \\n#===SCHEDULER===\\\
    \n      \\n\\\
    \n      \\n/system/scheduler/add name=initStartup on-event=\\\":delay delay-time=60s; /system/script/run initFirst;\\\" start-time=startup\\\
    \n      \\n\\\
    \n      \\n/system/reboot\"\
    \n\
    \n      \
    \n  :put message=\"\\n\\nConfig file ready. Please, confirm reset.\$[/terminal style style=varname]\"\
    \n  /system/reset-configuration no-defaults=yes skip-backup=yes keep-users=no run-after-reset=flash/startconf.rsc\
    \n} else={:put message=\"Scritpt stopped\$[/terminal/style style=syntax-noterm]\"};:"
