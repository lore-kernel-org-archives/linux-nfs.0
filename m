From: Jean-Christophe Ducom <jducom@nd.edu>
Subject: processes stuck in....?
Date: Tue, 06 May 2003 14:22:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB80B77.4000702@nd.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from osgood.cc.nd.edu ([129.74.250.227])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D83e-0003AS-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 12:24:59 -0700
Received: from nd.edu (frenchy.chem.nd.edu [129.74.74.11])
	by osgood.cc.nd.edu (Switch-3.0.4/Switch-3.0.0) with ESMTP id h46JOmlU008098
	for <nfs@lists.sourceforge.net>; Tue, 6 May 2003 14:24:48 -0500 (EST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

	I'd like to get some feedback on a problem that freezes SMP clients so hard 
that a) even when a monitor is plugged, there is no display (no control from 
keyboard either)
b) no terminal console access via serial port c) even nmi_watchdog can't get out 
of it apparently (no report)
This happens usually in a pretty consistently when the nfs client creates a lot 
of files (like 800+) or write big file.
I don't have any tcpdump or something else for now.
Any idea/suggestion (change mount options?)
Thanks for any help or feedback

		JC





Client: Precision 530 Dual 1.7GhZ Xeon with Syskonnect SK9D21 GigE, Redhat 7.2, 
kernel 2.4.21-rc1, nfs-utils-1.0.3-1 with ext2 file
# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100021    1   udp  32768  nlockmgr
     100021    3   udp  32768  nlockmgr
     100021    4   udp  32768  nlockmgr
     100024    1   udp    904  status
     100024    1   tcp    907  status
The directory are mounted with option:
10.0.0.10:/export/data  /opt/data       nfs 
rw,nosuid,nodev,hard,intr,bg,rsize=8192,wsize=8192 0 0

Excerpt from /var/log/messages:
May  6 13:59:27 bob1 kernel: sk9dlin: Network Device Driver v1.03
May  6 13:59:27 bob1 kernel: (C)Copyright 2001 SysKonnect GmbH.
May  6 13:59:27 bob1 kernel: eth0: SysKonnect SK-9D21 Gigabit Ethernet
May  6 13:59:27 bob1 kernel: eth0: network connection down
May  6 13:59:27 bob1 kernel: eth0: NIC Link is downeth0: network connection down
May  6 13:59:27 bob1 kernel: eth0: Network connection up using
May  6 13:59:27 bob1 kernel:       speed        = 1000 Mbps
May  6 13:59:27 bob1 kernel:       duplex mode  = full
May  6 13:59:27 bob1 kernel:       card         = copper
May  6 13:59:27 bob1 kernel:       flowctrl     = none
May  6 13:59:27 bob1 kernel:       autoneg      = no
.....
May  6 13:59:24 bob1 sysctl: net.ipv4.ip_forward = 0
May  6 13:59:24 bob1 sysctl: net.ipv4.conf.default.rp_filter = 1
May  6 13:59:24 bob1 sysctl: kernel.sysrq = 0
May  6 13:59:24 bob1 sysctl: kernel.shmall = 33554432
May  6 13:59:24 bob1 sysctl: kernel.shmmax = 536870912
May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_fin_timeout = 30
May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_keepalive_time = 1800
May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_window_scaling = 0
May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_sack = 0
May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_timestamps = 0
May  6 13:59:24 bob1 sysctl: net.ipv4.ip_no_pmtu_disc = 1
May  6 13:59:24 bob1 sysctl: net.core.rmem_max = 262143
May  6 13:59:24 bob1 sysctl: net.core.rmem_default = 262143
May  6 13:59:24 bob1 sysctl: net.core.wmem_max = 262143
.....
May  6 13:59:34 bob1 rpc.lockd: lockdsvc: Function not implemented
May  6 13:59:34 bob1 nfslock: rpc.lockd startup failed
May  6 13:59:34 bob1 rpc.statd[724]: Version 1.0.3 Starting
May  6 13:59:34 bob1 nfslock: rpc.statd startup succeeded


-----------------------------
Server: 530 Dual 1.7GhZ Xeon with Syskonnect SK9D21 GigE, Redhat 7.2, kernel 
2.4.21-rc1, nfs-utils-1.0.3-1 with ext3 on a raid5
# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    696  rquotad
     100011    2   udp    696  rquotad
     100011    1   tcp    699  rquotad
     100011    2   tcp    699  rquotad
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   udp  32768  nlockmgr
     100021    3   udp  32768  nlockmgr
     100021    4   udp  32768  nlockmgr
     100005    1   udp    732  mountd
     100005    1   tcp    735  mountd
     100005    2   udp    732  mountd
     100005    2   tcp    735  mountd
     100005    3   udp    732  mountd
     100005    3   tcp    735  mountd
     100024    1   udp    757  status
     100024    1   tcp    760  status
# cat /etc/exports
/export/data 10.0.3.0/8(rw) 10.0.0.1(rw)


Excerpt From /var/log/messages:
May  5 21:24:44 file1 exportfs[938]: /etc/exports [4]: No 'sync' or 'async' 
option specified for export "10.0.0.1:/export/data".   Assuming default 
behaviour ('sync').   NOTE: this default has changed from previous versions
May  5 21:24:44 file1 nfs: Starting NFS services:  succeeded
May  5 21:24:45 file1 nfs: rpc.rquotad startup succeeded
May  5 21:24:45 file1 nfs: rpc.nfsd startup succeeded
May  5 21:24:45 file1 nfs: rpc.mountd startup succeeded
May  5 21:24:45 file1 nfslock: rpc.lockd startup succeeded
May  5 21:24:45 file1 rpc.statd[1001]: Version 1.0.3 Starting
May  5 21:24:45 file1 nfslock: rpc.statd startup succeeded

The exported directory is on a Promise Ultratrak100 TX8 connected to a Tekram 
390U3W.



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
