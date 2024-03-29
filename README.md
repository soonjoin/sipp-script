Command samples:

1. uac
1.1 rtpecho
1.1.1 729
    sipp -sf uac/uac_with_audio_rtpecho.xml -inf uac/injection_printf.csv -rtp_echo 192.168.106.76:5080 -r 1 -d 30000 -m 1
1.1.2 711u
    sipp -sf uac/uac_with_audio_rtpecho.xml -inf uac/injection_printf.csv -rtp_echo 192.168.106.76:5080 -set media_payload 0 -r 1 -d 30000 -m 1
1.2 rtpsend
    sipp -sf uac/uac_with_audio_rtpsend.xml -inf uac/injection_printf_0_rtp.csv 192.168.106.76:5090 -r 1 -d 70000 -set media_duration 71
2. uas
    Note: uas need to set the local IP address by -i or it'll use 127.0.0.1
2.1 rtpecho
2.1.1 729
    sipp -sf uas/uas_with_audio_rtpecho.xml -rtp_echo -i 192.168.106.25 -p 5090 
2.1.1 711u
    sipp -sf uas/uas_with_audio_rtpecho.xml -rtp_echo -i 192.168.106.25 -p 5090 -set media_payload 0
2.2 rtpsend
    sipp -sf uas/uas_with_audio_rtpsend.xml -inf uas/injection_printf.csv -i 192.168.106.25 -p 5090 -set media_payload 0 

注意事项:
    rtpsend相关的脚本是通过exec command创建进程来执行媒体发送的，目前未在脚本中实现sip会话结束或sipp进程退出时结束相关的rtpsend进程，而是通过设定一定的结束条件让该进程自行退出。
    本项目使用的rtpsend-sipp是定制的版本，增加了-i和-d两个参数。
    -d设定发送媒体流的时长，单位为秒；可以通过-set media_duration在sipp命令行进行设置
    -i则决定rtpsend进程退出的条件。在未加-i的情况下，进程发送数据后，会尝试接收数据，如果收不到数据则退出，如果加上-i，则不尝试接收数据，直到满足其他退出条件（包括：对端关闭时发送失败；完成-l指定的循环次数或达到-d指定的时长）时才退出；

    因此，如果对端是sipp的echo，则需不能同时设置-l 0 -d 0，因为sipp的echo的端口(默认6000)一直工作且会回包；
    而当对端可能不发rtp包时(如一些软终端)，则需设置-i，避免rtpsend进程因收不到包退出；

    另，使用rtpsend发送srtp时，要么指定-l 1，要么media_duration小于等于文件时长，否则循环第二遍时会出错，应该是包序号重复导致（rtp时好像不存在类似问题）；

音频文件制作:
    rtpsend所需的.rtp和.srtp文件：使用wireshark的Telephony->RTP->Rtp Streams的Export功能导出rtpdump所需文件，再用rtpdump（注意带-F hex参数）转换即可。 

    pcap所需的.pcap文件：使用tcpdump/wireshark抓取的，仅包含单路rtp的包，存为pcap格式即可。

    rtpstream所需的.payload文件：使用前述的.pcap文件或wireshark能提取的rpt包，使用wireshark的Telephony->RTP->Rtp Streams->Analyze->save->Unsynchronized Forward Stream Audio制作

关于性能:
    目前来看，发送媒体用exec command通过rtpsend处理是最好的，在E5-2650CPU上可以超过2000路。rtpstream只能到1000路左右。
    
    rtpecho性能：在E5-2650至少超2000（未测试上限），在E5620上单进程约1000，同时使用3-4个进程可以达3000以上，但超过4个进程后，性能并无更多提升。注意，性能测试除观察cpu负载和信令，还应观察rtp流量。前述所说E5620在3-4进程能达到3000路，其实在4000路时，cpu和信令层面并无异样，但能观察到rtp的收发开始不均衡，说明echo的rtp发送有问题。