Return-Path: linux-nfs-owner@vger.kernel.org
Received: from penguin.cdf.utoronto.ca ([128.100.31.106]:56801 "HELO
	smtp.cdf.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751869Ab3BMUwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 15:52:22 -0500
Message-ID: <511BFB74.3060803@cdf.toronto.edu>
Date: Wed, 13 Feb 2013 15:45:40 -0500
From: Iordan Iordanov <iordan@cdf.toronto.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS v3 hangs with kernel version v3.2.0, 32-bit
Content-Type: multipart/mixed;
 boundary="------------070702010108000601060003"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070702010108000601060003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello!

We've been suffering from NFS mounts and data transfers hanging on our 
Ubuntu Precise 12.04 32-bit shared servers since last summer. The 
problem has reoccurred over TCP and UDP.

Every month or so, some of our more heavily used shared servers would 
see its NFS mounts hang, and a bunch of flush-(major:minor) processes 
would sit at 100% in top. If the hang occurred while NFS over TCP was 
being used, mounting over UDP would still work, but mounting over TCP 
would hang (indefinitely). The reverse is also true. When we experienced 
the hang while using UDP, mounts over TCP would work on the affected system.

I've located a very similar discussion/bug-report for v3.1-rc4 which 
ended seemingly without a resolution here:
http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00728.html

We're also seeing the:

[3121466.072728] RPC: 43506 failed to lock transport e030a000

errors when RPC debugging is enabled. In addition, we're also seeing the 
socket in CLOSE_WAIT state symptom in netstat's output:

tcp 0 0 x.x.x.x:967 y.y.y.y:2049     CLOSE_WAIT

Running tcpdump on our file-server and specifying the hung host in 
question results in NO NFS-related traffic unless a mount request is 
executed on the nfs client. I've attached two tcpdumps representing a 
successful mount over UDP and an unsuccessful mount over TCP in case 
they are useful. The tcpdumps were captured on the fileserver.

The machine in question is currently in this hung state, and we would be 
happy to provide any additional information you may need!

Here is the result of uname -a on the hung machine:

Linux gambo 3.2.0-35-generic-pae #55-Ubuntu SMP Wed Dec 5 18:04:39 UTC 
2012 i686 athlon i386 GNU/Linux

Our NFS server is an up-to-date Debian Squeeze 6.0 box, and we would be 
happy to provide information on that machine if you think it is relevant.

Any help in resolving this would be greatly appreciated, as we are 
constantly suffering from this issue.

Many thanks in advance!
Iordan

--------------070702010108000601060003
Content-Type: text/plain; charset=us-ascii;
 name="traffic_nfs_mount_FAILED.tcp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="traffic_nfs_mount_FAILED.tcp"

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
15:37:54.081843 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [S], seq 2279262304, win 14600, options [mss 1460,sackOK,TS val 780728553 ecr 0,nop,wscale 8], length 0
15:37:54.081864 IP FILESERVER.nfsd > NFSCLIENT.698: Flags [S.], seq 2289421576, ack 2279262305, win 5792, options [mss 1460,sackOK,TS val 780836711 ecr 780728553,nop,wscale 7], length 0
15:37:54.081940 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728553 ecr 780836711], length 0
15:37:54.081988 IP NFSCLIENT.2390532476 > FILESERVER.nfs: 40 null
15:37:54.081997 IP FILESERVER.nfsd > NFSCLIENT.698: Flags [.], ack 45, win 46, options [nop,nop,TS val 780836711 ecr 780728553], length 0
15:37:54.082012 IP FILESERVER.nfs > NFSCLIENT.2390532476: reply ok 24 null
15:37:54.082086 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [.], ack 29, win 58, options [nop,nop,TS val 780728553 ecr 780836711], length 0
15:37:54.096451 IP NFSCLIENT.2407309692 > FILESERVER.nfs: 108 getattr fh 0,0/24
15:37:54.096511 IP FILESERVER.nfs > NFSCLIENT.2407309692: reply ok 44 getattr ERROR: No such file or directory
15:37:54.136394 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [.], ack 77, win 58, options [nop,nop,TS val 780728567 ecr 780836714], length 0
15:37:54.136630 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [F.], seq 157, ack 77, win 58, options [nop,nop,TS val 780728567 ecr 780836714], length 0
15:37:54.136662 IP FILESERVER.nfsd > NFSCLIENT.698: Flags [F.], seq 77, ack 158, win 46, options [nop,nop,TS val 780836724 ecr 780728567], length 0
15:37:54.136730 IP NFSCLIENT.698 > FILESERVER.nfsd: Flags [.], ack 78, win 58, options [nop,nop,TS val 780728567 ecr 780836724], length 0
15:37:54.148625 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [S], seq 1762521281, win 14600, options [mss 1460,sackOK,TS val 780728570 ecr 0,nop,wscale 8], length 0
15:37:54.148642 IP FILESERVER.sunrpc > NFSCLIENT.38796: Flags [S.], seq 2578243675, ack 1762521282, win 5792, options [mss 1460,sackOK,TS val 780836727 ecr 780728570,nop,wscale 7], length 0
15:37:54.148705 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836727], length 0
15:37:54.149104 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [P.], seq 1:61, ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836727], length 60
15:37:54.149119 IP FILESERVER.sunrpc > NFSCLIENT.38796: Flags [.], ack 61, win 46, options [nop,nop,TS val 780836727 ecr 780728570], length 0
15:37:54.149231 IP FILESERVER.sunrpc > NFSCLIENT.38796: Flags [P.], seq 1:33, ack 61, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 32
15:37:54.149289 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [.], ack 33, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149333 IP NFSCLIENT.42281 > FILESERVER.nfsd: Flags [S], seq 3980307887, win 14600, options [mss 1460,sackOK,TS val 780728570 ecr 0,nop,wscale 8], length 0
15:37:54.149346 IP FILESERVER.nfsd > NFSCLIENT.42281: Flags [S.], seq 1113481077, ack 3980307888, win 5792, options [mss 1460,sackOK,TS val 780836728 ecr 780728570,nop,wscale 7], length 0
15:37:54.149352 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [F.], seq 61, ack 33, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149373 IP FILESERVER.sunrpc > NFSCLIENT.38796: Flags [F.], seq 33, ack 62, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.149409 IP NFSCLIENT.42281 > FILESERVER.nfsd: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149431 IP NFSCLIENT.38796 > FILESERVER.sunrpc: Flags [.], ack 34, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149479 IP NFSCLIENT.3992934295 > FILESERVER.nfs: 40 null
15:37:54.149487 IP FILESERVER.nfsd > NFSCLIENT.42281: Flags [.], ack 45, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.149505 IP FILESERVER.nfs > NFSCLIENT.3992934295: reply ok 24 null
15:37:54.149576 IP NFSCLIENT.42281 > FILESERVER.nfsd: Flags [.], ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149624 IP NFSCLIENT.42281 > FILESERVER.nfsd: Flags [F.], seq 45, ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149651 IP FILESERVER.nfsd > NFSCLIENT.42281: Flags [F.], seq 29, ack 46, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.149716 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [S], seq 1151356501, win 14600, options [mss 1460,sackOK,TS val 780728570 ecr 0,nop,wscale 8], length 0
15:37:54.149731 IP FILESERVER.sunrpc > NFSCLIENT.44216: Flags [S.], seq 1246340334, ack 1151356502, win 5792, options [mss 1460,sackOK,TS val 780836728 ecr 780728570,nop,wscale 7], length 0
15:37:54.149738 IP NFSCLIENT.42281 > FILESERVER.nfsd: Flags [.], ack 30, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149791 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.149847 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [P.], seq 1:61, ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 60
15:37:54.149860 IP FILESERVER.sunrpc > NFSCLIENT.44216: Flags [.], ack 61, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.149948 IP FILESERVER.sunrpc > NFSCLIENT.44216: Flags [P.], seq 1:33, ack 61, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 32
15:37:54.150013 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [.], ack 33, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150022 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [F.], seq 61, ack 33, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150032 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [S], seq 3919737046, win 14600, options [mss 1460,sackOK,TS val 780728570 ecr 0,nop,wscale 8], length 0
15:37:54.150040 IP FILESERVER.33143 > NFSCLIENT.54679: Flags [S.], seq 1642399196, ack 3919737047, win 5792, options [mss 1460,sackOK,TS val 780836728 ecr 780728570,nop,wscale 7], length 0
15:37:54.150057 IP FILESERVER.sunrpc > NFSCLIENT.44216: Flags [F.], seq 33, ack 62, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.150117 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150137 IP NFSCLIENT.44216 > FILESERVER.sunrpc: Flags [.], ack 34, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150164 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [P.], seq 1:45, ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 44
15:37:54.150173 IP FILESERVER.33143 > NFSCLIENT.54679: Flags [.], ack 45, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.150205 IP FILESERVER.33143 > NFSCLIENT.54679: Flags [P.], seq 1:29, ack 45, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 28
15:37:54.150268 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [.], ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150320 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [F.], seq 45, ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150358 IP FILESERVER.33143 > NFSCLIENT.54679: Flags [F.], seq 29, ack 46, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.150424 IP NFSCLIENT.54679 > FILESERVER.33143: Flags [.], ack 30, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150478 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [S], seq 127791235, win 14600, options [mss 1460,sackOK,TS val 780728570 ecr 0,nop,wscale 8], length 0
15:37:54.150490 IP FILESERVER.33143 > NFSCLIENT.1022: Flags [S.], seq 4233774619, ack 127791236, win 5792, options [mss 1460,sackOK,TS val 780836728 ecr 780728570,nop,wscale 7], length 0
15:37:54.150550 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [.], ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150567 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [P.], seq 1:45, ack 1, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 44
15:37:54.150572 IP FILESERVER.33143 > NFSCLIENT.1022: Flags [.], ack 45, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.150611 IP FILESERVER.33143 > NFSCLIENT.1022: Flags [P.], seq 1:29, ack 45, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 28
15:37:54.150702 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [.], ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.150715 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [P.], seq 45:133, ack 29, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 88
15:37:54.151174 IP FILESERVER.33143 > NFSCLIENT.1022: Flags [P.], seq 29:81, ack 133, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 52
15:37:54.151289 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [F.], seq 133, ack 81, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0
15:37:54.151332 IP FILESERVER.33143 > NFSCLIENT.1022: Flags [F.], seq 81, ack 134, win 46, options [nop,nop,TS val 780836728 ecr 780728570], length 0
15:37:54.151397 IP NFSCLIENT.1022 > FILESERVER.33143: Flags [.], ack 82, win 58, options [nop,nop,TS val 780728570 ecr 780836728], length 0

--------------070702010108000601060003
Content-Type: text/plain; charset=us-ascii;
 name="traffic_nfs_mount_SUCCEEDED.udp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="traffic_nfs_mount_SUCCEEDED.udp"

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
15:40:11.935705 IP NFSCLIENT.17500 > 128.100.31.255.17500: UDP, length 112
15:40:15.816795 IP NFSCLIENT.1110664853 > FILESERVER.nfs: 40 null
15:40:15.817006 IP FILESERVER.nfs > NFSCLIENT.1110664853: reply ok 24 null
15:40:15.832453 IP NFSCLIENT.1127442069 > FILESERVER.nfs: 108 getattr fh 0,0/24
15:40:15.832534 IP FILESERVER.nfs > NFSCLIENT.1127442069: reply ok 44 getattr ERROR: No such file or directory
15:40:15.881681 IP NFSCLIENT.46815 > FILESERVER.sunrpc: UDP, length 56
15:40:15.881930 IP FILESERVER.sunrpc > NFSCLIENT.46815: UDP, length 28
15:40:15.882037 IP NFSCLIENT.1360433635 > FILESERVER.nfs: 40 null
15:40:15.882086 IP FILESERVER.nfs > NFSCLIENT.1360433635: reply ok 24 null
15:40:15.882251 IP NFSCLIENT.55888 > FILESERVER.sunrpc: UDP, length 56
15:40:15.882382 IP FILESERVER.sunrpc > NFSCLIENT.55888: UDP, length 28
15:40:15.882492 IP NFSCLIENT.49141 > FILESERVER.35672: UDP, length 40
15:40:15.882572 IP FILESERVER.35672 > NFSCLIENT.49141: UDP, length 24
15:40:15.882845 IP NFSCLIENT.718 > FILESERVER.35672: UDP, length 40
15:40:15.882886 IP FILESERVER.35672 > NFSCLIENT.718: UDP, length 24
15:40:15.882996 IP NFSCLIENT.718 > FILESERVER.35672: UDP, length 84
15:40:15.883504 IP FILESERVER.35672 > NFSCLIENT.718: UDP, length 48
15:40:15.883695 IP NFSCLIENT.35682 > FILESERVER.sunrpc: UDP, length 84
15:40:15.883817 IP FILESERVER.sunrpc > NFSCLIENT.35682: UDP, length 28
15:40:15.883979 IP NFSCLIENT.3080980642 > FILESERVER.nfs: 40 null
15:40:15.884024 IP FILESERVER.nfs > NFSCLIENT.3080980642: reply ok 24 null
15:40:15.884145 IP NFSCLIENT.3097757858 > FILESERVER.nfs: 40 null
15:40:15.884178 IP FILESERVER.nfs > NFSCLIENT.3097757858: reply ok 24 null
15:40:15.884271 IP NFSCLIENT.3114535074 > FILESERVER.nfs: 84 fsinfo fh Unknown/0100010065000000000000000000000000000000000000000000000000000000
15:40:15.884325 IP FILESERVER.nfs > NFSCLIENT.3114535074: reply ok 80 fsinfo rtmax 32768 rtpref 32768 wtmax 32768 wtpref 32768 dtpref 4096
15:40:15.884453 IP NFSCLIENT.3131312290 > FILESERVER.nfs: 84 pathconf fh Unknown/0100010065000000000000000000000000000000000000000000000000000000
15:40:15.884506 IP FILESERVER.nfs > NFSCLIENT.3131312290: reply ok 56 pathconf linkmax 32000 namemax 255  chownres  keepcase
15:40:15.884618 IP NFSCLIENT.3148089506 > FILESERVER.nfs: 84 getattr fh Unknown/0100010065000000000000000000000000000000000000000000000000000000
15:40:15.884671 IP FILESERVER.nfs > NFSCLIENT.3148089506: reply ok 112 getattr DIR 40755 ids 0/0 sz 4096
15:40:15.884912 IP NFSCLIENT.3164866722 > FILESERVER.nfs: 84 fsinfo fh Unknown/0100010065000000000000000000000000000000000000000000000000000000
15:40:15.884963 IP FILESERVER.nfs > NFSCLIENT.3164866722: reply ok 80 fsinfo rtmax 32768 rtpref 32768 wtmax 32768 wtpref 32768 dtpref 4096
15:40:15.885064 IP NFSCLIENT.3181643938 > FILESERVER.nfs: 84 getattr fh Unknown/01000100650000002C20226E616D65737061636573223A205B31303638393731
15:40:15.885118 IP FILESERVER.nfs > NFSCLIENT.3181643938: reply ok 112 getattr DIR 40755 ids 0/0 sz 4096

33 packets captured
45 packets received by filter
0 packets dropped by kernel

--------------070702010108000601060003--
