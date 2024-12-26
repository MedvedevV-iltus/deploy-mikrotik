/system script
add dont-require-permissions=no name=preparation policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global wifipass StrongPassword;:global waniface ether1;:global ssid Wireless; :local inkey 1; \
    \n:global tunaddr \"0.0.0.0\";:global tunuser user;:global tunpasswd password;:global tunipsec ipsec;\
    \n\
    \n:put message=\"-----------------------------------------------------------------------------\$[/terminal/style comment]\";\
    \n:put \"\\t\\tMikrotik configuration script\\n\\r\\t\\tCreated by Medvedev Vladimir\$[/terminal/style escaped]\"; \
    \n:put \"\\t\\tEmail: medvedev.v@iltus.ru\\n\\r\\t\\tTelegram: @while_do\$[/terminal/style escaped ]\";\
    \n:put message=\"Documentation avalible in https://github.com/MedvedevV-iltus/deploy-mikrotik/blob/main/README.md\";\
    \n:put message=\"-----------------------------------------------------------------------------\\n\\n\\r\$[/terminal/style comment]\";\
    \n:put message=\"Press N to cancel running script, or any other key to start right now...\\n\\n\\r \$[/terminal/style style=syntax-noterm]\";\
    \n:set inkey value=[/terminal/inkey timeout=15s] \
    \n:if (\$inkey!=110 && \$inkey!=78) do={\
    \n  :set ssid value=[/terminal/ask prompt=\"Edit name(SSID) of WiFi (default=\$ssid)\" preinput=\$ssid value-name=\"Wi-Fi(SSID): \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :put message=\"\\n\\n\\rEnter password for WiFi (dafault=\$wifipass)\$[/terminal/style style=syntax-noterm]\";\
    \n  :set wifipass value=[/terminal/ask prompt=\"NB! This password will be set to admin user of Mirotik!\" preinput=\$wifipass value-name=\"Password: \$[/terminal/style style=varname]\"];\
    \n  :set waniface value=[/terminal/ask prompt=\"\\n\\n\\rEdit name of WAN-interface (default=\$waniface)\" preinput=\$waniface value-name=\"WAN: \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :put message=\"-----------------------------------------------------------------------------\\n\\n\\r\$[/terminal/style comment]\";\
    \n  :put message=\"For continue you need enter L2TP/IPSec parametrs.\\n\\rIf you don't have them, please contact with Vladimir Medvedev\$[/terminal/style style=varname]\"\
    \n  :put message=\"\\tEmail: medvedev.v@iltus.ru\\n\\r\\tTelegram: @while_do\$[/terminal/style escaped ]\"\
    \n  :set tunaddr value=[/terminal/ask prompt=\"\\n\\n\\rEnter endpoint address of Tunnel\" value-name=\"IP: \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :set tunuser value=[/terminal/ask prompt=\"\\n\\n\\rEnter L2TP-username\" value-name=\"L2TP user: \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :set tunpasswd value=[/terminal/ask prompt=\"\\n\\n\\rEnter L2TP-password\" value-name=\"L2TP password: \$[/terminal/style style=syntax-noterm ]\"];\
    \n  :set tunipsec value=[/terminal/ask prompt=\"\\n\\n\\rEnter IPSec-key\" value-name=\"IPSec-key: \$[/terminal/style style=syntax-noterm ]\"];\
    \n/file/add name=flash/startconf.rsc contents=\"#\\\
    \n    | ------------------------------------------------------------------\
    ------\\\
    \n    -----\\\
    \n    \\n#| RouterMode:\\\
    \n    \\n#|  * WAN port is protected by firewall and enabled DHCP client\\\
    \n    \\n#|  * Wireless and Ethernet interfaces (except WAN port/s) are part of LAN bridge\\\
    \n    \\n\\\
    \n    \\n:global ssid \$ssid;\\\
    \n    \\n:global wifipass \$wifipass;\\\
    \n    \\n:global waniface \$waniface;\\\
    \n    \\n:global tunaddr \$tunaddr;\\\
    \n    \\n:global tunuser \$tunuser;\\\
    \n    \\n:global tunpasswd \$tunpasswd;\\\
    \n    \\n:global tunipsec \$tunipsec;\\\
    \n    \\n\\\
    \n    \\n:log debug \\\"Starting config-script\\\";\\\
    \n    \\n#======== WAIT for interfaces =====================\\\
    \n    \\n:local count 0;\\\
    \n    \\n:local nowifi 0;\\\
    \n    \\n:while ([/interface ethernet find] = \\\"\\\") do={\\\
    \n    \\n    :if (\\\$count = 30) do={\\\
    \n    \\n        :log warning \\\"Unable to find ethernet interfaces\\\";\\\
    \n    \\n            /quit;\\\
    \n    \\n            }\\\
    \n    \\n            :delay 1s; :set count (\\\$count +1); \\\
    \n    \\n}\\\
    \n    \\n:set count 0;\\\
    \n    \\n:while ([/interface wireless print count-only] < 1) do={\\\
    \n    \\n    :set count (\\\$count +1);\\\
    \n    \\n    :if (\\\$count = 40) do={\\\
    \n    \\n        :set nowifi 1;\\\
    \n    \\n            :log warning \\\"Unable to find wireless interface(s)\\\"; \\\
    \n    \\n            }\\\
    \n    \\n            :delay 1s;\\\
    \n    \\n}\\\
    \n    \\n\\\
    \n    \\n#======= USER FULL FOR SCRIPT and other GLOBALS =================\
    \\\
    \n    \\n/user/add name=iltus password=\\\"P@55w0rd!\\\" group=full\\\
    \n    \\n/user/set password=\$wifipass [find name=admin]\
    \n    \\n/system/identity/set name=GW-sputnik\\\
    \n    \\n/ipv6/settings/set disable-ipv6=yes\\\
    \n    \\n/ip/service/set disabled=yes [find name!=winbox]\\\
    \n    \\n/ip/service/set disabled=no [find name=ssh]\\\
    \n    \\n/tool/bandwidth-server/set enabled=no\\\
    \n    \\n\\\
    \n    \\n#-- enable debug logs for script --\\\
    \n    \\n/system logging action add name=extra target=memory memory-lines=2000;\\\
    \n    \\n/system logging add action=extra topics=script;\\\
    \n    \\n\\\
    \n    \\n\\\
    \n    \\n#======= CONFIG INTERFACES =====================\\\
    \n    \\n\\\
    \n    \\n#--Lists---\\\
    \n    \\n/interface list add name=WAN;\\\
    \n    \\n/interface list add name=LAN;\\\
    \n    \\n\\\
    \n    \\n#--Local Bridge--- \\\
    \n    \\n/interface bridge add name=bridge disabled=no auto-mac=yes protocol-mode=rstp;\\\
    \n    \\n:local bMACIsSet 0;\\\
    \n    \\n\\\
    \n    \\n:foreach k in=[/interface find where !(slave=yes   || name=\\\$waniface || passthrough=yes || type=loopback || name~\\\"bridge\\\")] do={\\\
    \n    \\n    :local tmpPortName [/interface get \\\$k name];\\\
    \n    \\n    :if (\\\$bMACIsSet = 0) do={\\\
    \n    \\n        :if ([/interface get \\\$k type] = \\\"ether\\\") do={\\\
    \n    \\n                /interface bridge set \\\"bridge\\\" auto-mac=no admin-mac=[/interface get \\\$tmpPortName mac-address];\\\
    \n    \\n                        :set bMACIsSet 1;\\\
    \n    \\n                            }\\\
    \n    \\n                            }\\\
    \n    \\n                            :if (([/interface get \\\$k type] != \\\"ppp-out\\\") && ([/interface get \\\$k type] != \\\"lte\\\")) do={\\\
    \n    \\n                                /interface bridge port add bridge=bridge interface=\\\$tmpPortName;\\\
    \n    \\n                                }\\\
    \n    \\n}\\\
    \n    \\n/ip address add address=192.168.88.1/24 interface=bridge;\\\
    \n    \\n\\\
    \n    \\n#--DHCP-server--\\\
    \n    \\n/ip pool add name=\\\"default-dhcp\\\" ranges=192.168.88.10-192.168.88.254;\\\
    \n    \\n/ip dhcp-server add name=dhcp-server address-pool=\\\"default-dhcp\\\" interface=bridge disabled=no;\\\
    \n    \\n/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=192.168.88.1;\\\
    \n    \\n/ip dns set allow-remote-requests=yes\\\
    \n    \\n\\\
    \n    \\n#--WiFi--\\\
    \n    \\n:if (\\\$nowifi=0) do={\\\
    \n    \\n    /interface/wireless/security-profiles add name=custom mode=dynamic-keys authentication-types=wpa2-psk wpa2-pre-shared-key=\\\$wifipass;\\\
    \n    \\n    /interface wireless {\\\
    \n    \\n        :local ifcId [/interface wireless find where default-name=wlan1]\\\
    \n    \\n        :local currentName [/interface wireless get \\\$ifcId name]\\\
    \n    \\n        set \\\$ifcId mode=ap-bridge band=2ghz-b/g/n disabled=no wireless-protocol=802.11 \\\
    \n    \\n        set \\\$ifcId distance=indoors installation=any country=russia4\\\
    \n    \\n        set \\\$ifcId channel-width=20/40mhz-XX security-profile=custom\\\
    \n    \\n        set \\\$ifcId frequency=auto\\\
    \n    \\n        set \\\$ifcId ssid=\\\$ssid\\\
    \n    \\n    }\\\
    \n    \\n}\\\
    \n    \\n#============ WAN interface ============================\\\
    \n    \\n/ip dhcp-client add interface=\\\$waniface disabled=no;\\\
    \n    \\n\\\
    \n    \\n#============ FIREWALL =================================\\\
    \n    \\n/interface list member add list=LAN interface=bridge;\\\
    \n    \\n/interface list member add list=WAN interface=\\\$waniface;\\\
    \n    \\n\\\
    \n    \\n/ip firewall address-list add address=10.33.0.0/24 list=trusted comment=\\\"ILTUS netops\\\"\\\
    \n    \\n/ip firewall address-list add address=172.21.28.1/32 list=trusted\\\
    \n    \\n/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade;\\\
    \n    \\n/ip firewall {\\\
    \n    \\n    filter add chain=input action=accept connection-state=established,related,untracked comment=\\\"accept established,related,untracked\\\"\\\
    \n    \\n    filter add chain=input action=drop connection-state=invalid comment=\\\"drop invalid\\\"\\\
    \n    \\n    filter add chain=input action=accept protocol=icmp comment=\\\"accept ICMP\\\"\\\
    \n    \\n    filter add chain=input src-address-list=trusted action=accept comment=\\\"accept remote ILTUS\\\"\\\
    \n    \\n    filter add chain=input action=drop in-interface-list=!LAN comment=\\\"drop all not coming from LAN\\\"\\\
    \n    \\n    filter add chain=forward action=accept connection-state=established,related,untracked comment=\\\"accept established,related,untracked\\\"\\\
    \n    \\n    filter add chain=forward action=drop connection-state=invalid comment=\\\"drop invalid\\\"\\\
    \n    \\n    filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment=\\\"drop all from WAN not DSTNATed\\\"\\\
    \n    \\n}\\\
    \n    \\n/ip neighbor discovery-settings set discover-interface-list=LAN\\\
    \n    \\n/tool mac-server set allowed-interface-list=LAN\\\
    \n    \\n/tool mac-server mac-winbox set allowed-interface-list=LAN\\\
    \n    \\n\\\
    \n    \\n#================ TUNNEL ==============================\\\
    \n    \\n/interface l2tp-client add name=l2tp-k12 connect-to=\\\$tunaddr user=\\\$tunuser password=\\\$tunpasswd disabled=no use-ipsec=yes ipsec-secret=\\\$tunipsec use-peer-dns=no add-default-route=no
    \n    \\n/ip route add disabled=no dst-address=10.33.0.0/24 gateway=l2tp-k12\
    \n    \\n\\\
    \n    \\n#================ NTP-client ==========================\\\
    \n    \\n/ip/cloud set update-time=no\\\
    \n    \\n/system/ntp/client set enabled=yes mode=unicast servers=ru.pool.ntp.org\\\
    \n    \\n\\\
    \n    \\n#| -----------------------------------------------------------------------------\\\
    \n    \\n#| CONFIG IS READY\\\
    \n    \\n#| Preparing script for limit traffic\\\
    \n    \\n#| -----------------------------------------------------------------------------\\\
    \n    \\n\\\
    \n    \\n#-- initFirst --\\\
    \n    \\n/system/script/add dont-require-permissions=no owner=iltus name=i\
    nitFirs\\\
    \n    t policy=\\\\\\\
    \n    \\n    read,write source=\\\"#initglobal VARS. Then run script to in\
    it global\\\
    \n    \\_FUN\\\\\\\
    \n    \\n    CS\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"starting init first step: init global\
    \_Vars\\\\\\\"\\\\\\\
    \n    \\n    \\\\n:delay delay-time=60s; \\\\\\\
    \n    \\n    \\\\n:global resultRx 0;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"var resultRx = \\\\\\\$resultRx\\\\\\\
    \"\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global resultTx 0;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"var resultTx = \\\\\\\$resultTx\\\\\\\
    \"\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global lastRx 0;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"var lastRx = \\\\\\\$lastRx\\\\\\\"\\\
    \\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global lastTx 0;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"var lastTx = \\\\\\\$lastTx\\\\\\\"\\\
    \\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global cudate 2868w4d00:00:00;\\\\\\\
    \n    \\n    \\\\n        \\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"var cudate = \\\\\\\$cudate\\\\\\\"\\\
    \\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global queued 0;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"execute init second step\\\\\\\"\\\\\
    \\\
    \n    \\n    \\\\n:onerror errorName in={ /system/script/run initSecond } \
    do={/log \\\
    \n    error \\\\\\\"init Second step stoped with error \\\\\\\$errorName\\\
    \\\\\"}\\\\\\\
    \n    \\n    \\\\n:delay 10s;\\\\\\\
    \n    \\n    \\\\n/log debug \\\\\\\"first step init is over\\\\\\\\n-----\
    -----------------\\\
    \n    -----\\\\\\\"\\\"\\\
    \n    \\n\\\
    \n    \\n#-- initSecond --\\\
    \n    \\n/system/script/add dont-require-permissions=no owner=iltus name=i\
    nitSeco\\\
    \n    nd policy=\\\\\\\
    \n    \\n    reboot,read,write source=\\\"/log debug \\\\\\\"init: second \
    step started\\\
    \n    \\\\\\\";\\\\\\\
    \n    \\n    \\\\n:delay delay-time=30s;\\\\\\\
    \n    \\n    \\\\n:global GetRx do={:return [([/interface ethernet get val\
    ue-name=r\\\
    \n    x-bytes [find default-name=\\\$waniface]]->0)]}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global GetTx do={:return [([/interface ethernet get val\
    ue-name=t\\\
    \n    x-bytes [find default-name=\\\$waniface]]->0)]}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n:global SaveVars do={\\\\\\\
    \n    \\n    \\\\n    :global resultRx;\\\\\\\
    \n    \\n    \\\\n    :global resultTx;\\\\\\\
    \n    \\n    \\\\n    :global lastRx;\\\\\\\
    \n    \\n    \\\\n    :global lastTx;\\\\\\\
    \n    \\n    \\\\n    :global cudate;\\\\\\\
    \n    \\n    \\\\n    :global queued;\\\\\\\
    \n    \\n    \\\\n    /system/script/set [find name=initFirst] source=\\\\\
    \\\"#\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        initglobal VARS. Then run script to init global \
    FUNCS\\\\\\\\\\\
    \n    \\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"starting ini\
    t first step: init gl\\\
    \n    obal Vars\\\\\\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=60s; \\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global resultRx \\\\\\\$resultRx;\\\\\
    \\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var resultRx\
    \_= \\\\\\\\\\\\\\\$resultRx\\\\\\\
    \n    \\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global resultTx \\\\\\\$resultTx;\\\\\
    \\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var resultTx\
    \_= \\\\\\\\\\\\\\\$resultTx\\\\\\\
    \n    \\\\\\\\\\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global lastRx \\\\\\\$lastRx;\\\\\\\\\
    \\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var lastRx =\
    \_\\\\\\\\\\\\\\\$lastRx\\\\\\\\\\\\\\\
    \n    \\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global lastTx \\\\\\\$lastTx;\\\\\\\\\
    \\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var lastTx =\
    \_\\\\\\\\\\\\\\\$lastTx\\\\\\\\\\\\\\\
    \n    \\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global cudate \\\\\\\$cudate;\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"var cudate =\
    \_\\\\\\\\\\\\\\\$cudate\\\\\\\\\\\\\\\
    \n    \\\"\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay delay-time=1s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:global queued \\\\\\\$queued;\\\\\\\\\
    \\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"execute init\
    \_second step\\\\\\\\\\\\\\\"\\\
    \n    \\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:onerror errorName in={ /system/script/\
    run initSecon\\\
    \n    d } do={/log error \\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\\\\\\\\"init Second step stoped with err\
    or \\\\\\\\\\\\\\\$errorN\\\
    \n    ame\\\\\\\\\\\\\\\"}\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n:delay 10s;\\\\\\\\\\\\\\\
    \n    \\n    \\\\n        \\\\\\\\n/log debug \\\\\\\\\\\\\\\"first step i\
    s over\\\\\\\\\\\\\\\\n------\\\
    \n    ---------------------\\\\\\\\\\\\\\\"\\\\\\\" \\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:global Analyze do={\\\\\\\
    \n    \\n    \\\\n#    Analyze do={\\\\\\\
    \n    \\n    \\\\n    :global cudate;\\\\\\\
    \n    \\n    \\\\n    :if (([:timestamp] - \\\\\\\$cudate) > 24h) do={\\\\\
    \\\
    \n    \\n    \\\\n        #new day!!!\\\\\\\
    \n    \\n    \\\\n        :return 2; } else={\\\\\\\
    \n    \\n    \\\\n        :global resultTx;\\\\\\\
    \n    \\n    \\\\n        :global resultRx;\\\\\\\
    \n    \\n    \\\\n        :if ((\\\\\\\$resultTx + \\\\\\\$resultRx) >= 21\
    47483648) do={\\\\\\\
    \n    \\n    \\\\n        #limit!!!\\\\\\\
    \n    \\n    \\\\n        :return 1; } else={:return 0}\\\\\\\
    \n    \\n    \\\\n    }\\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:global NTPcheck do={\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n    :return 0;\\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:global NewDay do={\\\\\\\
    \n    \\n    \\\\n    :log debug \\\\\\\"new day. Limits is over.\\\\\\\"\
    \\\\\\\
    \n    \\n    \\\\n    :global resultRx; :global resultTx; :global queued; \
    :global c\\\
    \n    udate;\\\\\\\
    \n    \\n    \\\\n    :global SaveVars;\\\\\\\
    \n    \\n    \\\\n    :set resultRx 0;\\\\\\\
    \n    \\n    \\\\n    :set resultTx 0;\\\\\\\
    \n    \\n    \\\\n    :set queued 0;\\\\\\\
    \n    \\n    \\\\n    :set cudate (([:timestamp]/1d)*1d);\\\\\\\
    \n    \\n    \\\\n    [\\\\\\\$SaveVars];\\\\\\\
    \n    \\n    \\\\n    :return 0;\\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n#:global LimitTraf do={ /queue/simple/add name=limiter t\
    arget=192\\\
    \n    .168.88.0/24 max-limit=64k/64k disabled=no }\\\\\\\
    \n    \\n    \\\\n:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n#:global UnLimitTraf do={/queue/simple/remove [find name\
    =limiter]\\\
    \n    \\_}\\\\\\\
    \n    \\n    \\\\n#:delay delay-time=1s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:global GetValues do={\\\\\\\
    \n    \\n    \\\\n    #get Vars with last Rx and Tx bytes\\\\\\\
    \n    \\n    \\\\n    :global lastRx; :global lastTx; :global resultRx; :g\
    lobal res\\\
    \n    ultTx;\\\\\\\
    \n    \\n    \\\\n    #get Functions\\\\\\\
    \n    \\n    \\\\n    :global GetTx; :global GetRx; :global SaveVars;\\\\\
    \\\
    \n    \\n    \\\\n    #get new values of Rx/Tx\\\\\\\
    \n    \\n    \\\\n    :local newTx [\\\\\\\$GetTx]                        \
    \_  \\\\\\\
    \n    \\n    \\\\n    :local newRx [\\\\\\\$GetRx]\\\\\\\
    \n    \\n    \\\\n    \\\\\\\
    \n    \\n    \\\\n    #if last > new => traffic-conter was reseted in mikr\
    otik. Jus\\\
    \n    t skip one value\\\\\\\
    \n    \\n    \\\\n    :if (\\\\\\\$lastRx <= \\\\\\\$newRx) do={\\\\\\\
    \n    \\n    \\\\n        :set resultRx [(\\\\\\\$resultRx + \\\\\\\$newRx\
    \_- \\\\\\\$lastRx )];\\\
    \n    \\_\\\\\\\
    \n    \\n    \\\\n    :set resultTx [(\\\\\\\$resultTx + \\\\\\\$newTx - \
    \\\\\\\$lastTx )]; }\\\\\\\
    \n    \\n    \\\\n    \\\\\\\
    \n    \\n    \\\\n    :set lastRx [\\\\\\\$newRx]; :set lastTx [\\\\\\\$ne\
    wTx];      \\\\\\\
    \n    \\n    \\\\n    \\\\\\\
    \n    \\n    \\\\n    #save values to init script\\\\\\\
    \n    \\n    \\\\n    [\\\\\\\$SaveVars];\\\\\\\
    \n    \\n    \\\\n    :delay delay-time=3s;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n    :return 0;\\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n#start main proccess\\\\\\\
    \n    \\n    \\\\n:delay delay-time=5s;\\\\\\\
    \n    \\n    \\\\n:execute script={/system/script/run main }\\\"\\\
    \n    \\n\\\
    \n    \\n#-- main --\\\
    \n    \\n/system/script/add dont-require-permissions=no owner=iltus name=m\
    ain pol\\\
    \n    icy=read,write \\\\\\\
    \n    \\n    source=\\\"#get current values Rx and Tx bytes\\\\\\\
    \n    \\n    \\\\n:global resultRx; :global resultTx; :global queued;\\\\\
    \\\
    \n    \\n    \\\\n#\\\\\\\
    \n    \\n    \\\\n#get functions\\\\\\\
    \n    \\n    \\\\n:global Analyze;\\\\\\\
    \n    \\n    \\\\n:global GetValues; \\\\\\\
    \n    \\n    \\\\n:global NewDay;\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:local control 0\\\\\\\
    \n    \\n    \\\\n:local analyzed 0\\\\\\\
    \n    \\n    \\\\n:local cycles 0\\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n:while (\\\\\\\$control=0) do={\\\\\\\
    \n    \\n    \\\\n    :set cycles (\\\\\\\$cycles + 1)\\\\\\\
    \n    \\n    \\\\n    /log debug \\\\\\\"start cycle #\\\\\\\$cycles\\\\\\\
    \"\\\\\\\
    \n    \\n    \\\\n    :set control [\\\\\\\$GetValues]; \\\\\\\
    \n    \\n    \\\\n    :delay delay-time=5s\\\\\\\
    \n    \\n    \\\\n    /log debug \\\\\\\"Geted new values...\\\\\\\"\\\\\\\
    \n    \\n    \\\\n    :set analyzed [\\\\\\\$Analyze]; \\\\\\\
    \n    \\n    \\\\n    /log debug \\\\\\\"Analyzed\\\\\\\";\\\\\\\
    \n    \\n    \\\\n    :if (\\\\\\\$analyzed=2) do={\\\\\\\
    \n    \\n    \\\\n            #new day! need set resultTx and resultRx to \
    0, and di\\\
    \n    sable queue\\\\\\\
    \n    \\n    \\\\n            /queue/simple/remove [find name=limiter]\\\\\
    \\\
    \n    \\n    \\\\n            :set queued 0;\\\\\\\
    \n    \\n    \\\\n            [\\\\\\\$NewDay]\\\\\\\
    \n    \\n    \\\\n            :log debug \\\\\\\"results = 0; queue disabl\
    ed;\\\\\\\"\\\\\\\
    \n    \\n    \\\\n#not geted here \\\\\\\
    \n    \\n    \\\\n\\\\\\\
    \n    \\n    \\\\n        }\\\\\\\
    \n    \\n    \\\\n        \\\\\\\
    \n    \\n    \\\\n        :if (\\\\\\\$analyzed=1) do={\\\\\\\
    \n    \\n    \\\\n            # reached 2GB!!! START QUEUE\\\\\\\
    \n    \\n    \\\\n            #\\\\\\\
    \n    \\n    \\\\n            # DONT FORGET TO START/CHECK QUEUE\\\\\\\
    \n    \\n    \\\\n            :if (\\\\\\\$queued = 0) do={\\\\\\\
    \n    \\n    \\\\n                /queue/simple/add name=limiter target=19\
    2.168.88.\\\
    \n    0/24 max-limit=64k/64k disabled=no \\\\\\\
    \n    \\n    \\\\n                :set queued 1;\\\\\\\
    \n    \\n    \\\\n                :log debug \\\\\\\"reached limit of 2GB;\
    \_queue starte\\\
    \n    d\\\\\\\" } else={/log debug \\\\\\\"queue is runnig\\\\\\\" }\\\\\\\
    \n    \\n    \\\\n        }\\\\\\\
    \n    \\n    \\\\n        \\\\\\\
    \n    \\n    \\\\n        :if (\\\\\\\$analyzed=0) do={\\\\\\\
    \n    \\n    \\\\n            # all ok; just do nothing;\\\\\\\
    \n    \\n    \\\\n            :log debug \\\\\\\"check passed; limit is no\
    t reached\\\\\\\"\\\
    \n    \\\\\\\
    \n    \\n    \\\\n        }\\\\\\\
    \n    \\n    \\\\n   \\\\\\\
    \n    \\n    \\\\n    #cycle is over\\\\\\\
    \n    \\n    \\\\n    /log debug \\\\\\\"cycle #\\\\\\\$cycles is over. wa\
    it for 20 seconds\\\
    \n    \\\\\\\"\\\\\\\
    \n    \\n    \\\\n    :delay delay-time=20s;\\\\\\\
    \n    \\n    \\\\n}\\\\\\\
    \n    \\n    \\\\n \\\\\\\
    \n    \\n    \\\\n        \\\\\\\
    \n    \\n    \\\\n    \\\"\\\
    \n    \\n    \\\
    \n    \\n#-- SCHEDULER --\\\
    \n    \\n/system/scheduler/add name=initStartup on-event=\\\":delay delay-\
    time=60s;\\\
    \n    \\\\r\\\\\\\
    \n    \\n    \\\\n/system/script/run initFirst;\\\\r\\\\n\\\" policy=ftp,r\
    eboot,read,writ\\\
    \n    e,policy,test,password,sniff,sensitive,romon start-time=startup\\\
    \n    \\n    \\\
    \n    \\n#| --------------------------------------------------------------\
    -------\\\
    \n    --------\\\
    \n    \\n#| END\\\
    \n    \\n#| Reboot\\\
    \n    \\n#| --------------------------------------------------------------\
    -------\\\
    \n    --------\\\
    \n    \\n\\\
    \n    \\n/system/reboot\"\
    \n:put message=\"\\n\\n\\rRouter will be rebooted in 5s\\n\\rPlease confir\
    m reset config\$[/terminal style style=varname]\"\
    \n:delay 5s;\
    \n/system/reset-configuration no-defaults=yes skip-backup=yes keep-users=n\
    o run-after-reset=flash/startconf.rsc\
    \n\
    \n} else={:put message=\"Scritpt stopped\$[/terminal/style style=syntax-no\
    term]\"}"
