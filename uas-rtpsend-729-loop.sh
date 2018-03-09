localip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

sipp -sf uas/uas_with_audio_rtpsend.xml -inf uas/injection_printf.csv -i $localip -p 5090
