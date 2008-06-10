From: Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP snd/rcv buffer
 values
Date: Tue, 10 Jun 2008 11:54:28 -0700
Message-ID: <484ECDE4.6030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:36597 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYFJSyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 14:54:43 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1717857ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2008 11:54:33 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The motivation for this patch is improved WAN write performance plus 
greater user control on the server of the TCP buffer values (window 
size).  The TCP window determines the amount of outstanding data that a 
client can have on the wire and should be large enough that a NFS client 
can fill up the pipe (the bandwidth * delay product).  Currently the TCP 
receive buffer size (used for client writes) is set very low, which 
prevents a client from filling up a network pipe with a large bandwidth 
* delay product.

Currently, the server TCP send window is set to accommodate the maximum 
number of outstanding NFSD read requests (# nfsds * maxiosize), while 
the server TCP receive window is set to a fixed value which can hold a 
few requests.  While these values set a TCP window size that is fine in 
LAN environments with a small BDP, WAN environments can require a much 
larger TCP window size, e.g., 10GigE transatlantic link with a rtt of 
120 ms has a BDP of approx 60MB.

I have a patch to net/svc/svcsock.c that allows a user to manually set 
the server TCP send and receive buffer through the sysctl interface. to 
suit the required TCP window of their network architecture.  It adds two 
/proc entries, one for the receive buffer size and one for the send 
buffer size:
/proc/sys/sunrpc/tcp_sndbuf
/proc/sys/sunrpc/tcp_rcvbuf

The uses the current buffer sizes in the code are as minimum values, 
which the user cannot decrease.  If the user sets a value of 0 in either 
/proc entry, it resets the buffer size to the default value.  The set 
/proc values are utilized when the TCP connection is initialized (mount 
time).  The values are bounded above by the *minimum* of the /proc 
values and the network TCP sysctls.

To demonstrate the usefulness of this patch, details of an experiment 
between 2 computers with a rtt of 30ms is provided below.  In this 
experiment, increasing the server /proc/sys/sunrpc/tcp_rcvbuf value 
doubles write performance.

EXPERIMENT
==========
This experiment simulates a WAN by using tc together with netem to add a 
30 ms delay to all packets on a nfs client.  The goal is to show that by 
only changing tcp_rcvbuf, the nfs client can increase write performance 
in the WAN. To verify the patch has the desired effect on the TCP 
window, I created two tcptrace plots that show the difference in tcp 
window behaviour before and after the server TCP rcvbuf size is 
increased.  When using the default server tcpbuf value of 6M, we can see 
the TCP window top out around 4.6 M, whereas increasing the server 
tcpbuf value to 32M, we can see that the TCP window tops out around 
13M.  Performance jumps from 43 MB/s to 90 MB/s.

Hardware:
2 dual-core opteron blades
GigE, Broadcom NetXtreme II BCM57065 cards
A single gigabit switch in the middle
1500 MTU
8 GB memory

Software:
Kernel: Bruce's 2.6.25-rc9-CITI_NFS4_ALL-1 tree
RHEL4

NFS Configuration:
64 rpc slots
32 nfsds
Export ext3 file system.  This disk is quite slow, I therefore exported 
using async to reduce the effect of the disk on the back end.  This way, 
the experiments record the time it takes for the data to get to the 
server (not to the disk).
# exportfs -v
/export     <world>(rw,async,wdelay,nohide,insecure,no_root_squash,fsid=0)

# cat /proc/mounts
bear109:/export /mnt nfs 
rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=9.1.74.144 
0 0

fs.nfs.nfs_congestion_kb = 91840
net.ipv4.tcp_congestion_control = cubic

Network tc Command executed on client:
tc qdisc add dev eth0 root netem delay 30ms
rtt from client (bear108) to server (bear109)
#ping bear109
PING bear109.almaden.ibm.com (9.1.74.144) 56(84) bytes of data.
64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=0 ttl=64 
time=31.4 ms
64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=1 ttl=64 
time=32.0 ms

TCP Configuration on client and server:
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
# Controls source route verification
net.ipv4.conf.default.rp_filter = 1
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0
# Controls whether core dumps will append the PID to the core filename
# Useful for debugging multi-threaded applications
kernel.core_uses_pid = 1
# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1
# Controls the maximum size of a message, in bytes
kernel.msgmnb = 65536
# Controls the default maxmimum size of a mesage queue
kernel.msgmax = 65536
# Controls the maximum shared segment size, in bytes
kernel.shmmax = 68719476736
# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 4294967296
### IPV4 specific settings
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 1
# on systems with a VERY fast bus -> memory interface this is the big 
gainer
net.ipv4.tcp_rmem = 4096 16777216 16777216
net.ipv4.tcp_wmem = 4096 16777216 16777216
net.ipv4.tcp_mem = 4096 16777216 16777216
### CORE settings (mostly for socket and UDP effect)
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
net.core.optmem_max =  16777216
net.core.netdev_max_backlog = 300000
# Don't cache ssthresh from previous connection
net.ipv4.tcp_no_metrics_save = 1
# make sure we don't run out of memory
vm.min_free_kbytes = 32768

Experiments:

On Server: (note that the real tcp buffer size is double tcp_rcvbuf)
[root@bear109 ~]# echo 0 > /proc/sys/sunrpc/tcp_rcvbuf
[root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
3158016

On Client:
mount -t nfs bear109:/export /mnt
[root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
...
             KB  reclen   write
         512000    1024   43252      umount /mnt

On server:
[root@bear109 ~]# echo 16777216 > /proc/sys/sunrpc/tcp_rcvbuf
[root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
16777216

On Client:
mount -t nfs bear109:/export /mnt
[root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
...
             KB  reclen   write
         512000    1024   90396

Dean
IBM Almaden Research Center
