From: G de With <G.de-With@herts.ac.uk>
Subject: nfs server problems
Date: Mon, 5 Apr 2004 11:09:20 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404051109.20115.G.de-With@herts.ac.uk>
References: <200404021420.33297.G.de-With@herts.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAQx2-00007g-CK
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 03:03:32 -0700
Received: from huli4.herts.ac.uk ([147.197.163.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BAQx1-000554-NP
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 03:03:31 -0700
Received: from localhost (localhost [127.0.0.1])
	by huli4.herts.ac.uk (Postfix) with ESMTP id C53DB1FAC0
	for <nfs@lists.sourceforge.net>; Mon,  5 Apr 2004 11:09:20 +0100 (BST)
To: nfs@lists.sourceforge.net
In-Reply-To: <200404021420.33297.G.de-With@herts.ac.uk>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

 Hi

 I have a question regarding the NFS server. I setup my Beowulf cluster
 including a master node and 1 slave. After extending the cluster to 7 slave
 nodes, I had problem writting from the slave nodes to the master node hard
 disks. THIS PROBLEM DID NOT OCCUR INITIALLY WITH 1 SLAVE NODE.

 After rebooting the cluster several times, remote harddisk access became
 slower. Then I rebooted only the master node (slaves where down), I
 restarted the nfs server several times (during booting, as well manually)
 and starting NFS services started to take 5-10 minutes. Furthermore, remote
 access was extremely slow. Furthermore, I discovered that exportfs -ra is
 equally time consuming.

 I have tried various export options, including async, however, without
 success.

 Furthermore, something strange has happend with my network and it has
 created a section plip0, shaper0 and tunl0. ( I do not know if this is of
 any relevance)


 [root@galaxy root]# ifconfig -a
 eth0      Link encap:Ethernet  HWaddr 00:30:48:22:D3:2B
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:17

 eth1      Link encap:Ethernet  HWaddr 00:30:48:22:D3:2C
           inet addr:147.197.163.150  Bcast:147.197.167.255 
 Mask:255.255.248.0 UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:228286 errors:0 dropped:0 overruns:0 frame:0
           TX packets:20940 errors:0 dropped:0 overruns:0 carrier:0
           collisions:695 txqueuelen:100
           RX bytes:22710516 (21.6 Mb)  TX bytes:5709982 (5.4 Mb)
           Interrupt:18 Base address:0x2000

 eth2      Link encap:Ethernet  HWaddr 00:04:76:EF:90:9E
           inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2873 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2506 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:227965 (222.6 Kb)  TX bytes:189376 (184.9 Kb)
           Interrupt:24

 lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:41571 errors:0 dropped:0 overruns:0 frame:0
           TX packets:41571 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:7696983 (7.3 Mb)  TX bytes:7696983 (7.3 Mb)

 plip0     Link encap:Ethernet  HWaddr FC:FC:FC:FC:FC:FC
           POINTOPOINT NOARP  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:10
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:255 Base address:0x378

 shaper0   Link encap:Ethernet  HWaddr 00:00:00:00:00:00
           [NO FLAGS]  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:10
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

 tunl0     Link encap:IPIP Tunnel  HWaddr
           NOARP  MTU:1480  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

 [root@galaxy root]#


 I have listed the cluster specifications as required.

 [root@galaxy root]# service nfs start
 Starting NFS services:                                     [  OK  ] 
 (average time 5-10 minutes)
 Starting NFS quotas:                                       [  OK  ]
 Starting NFS mountd:                                       [  OK  ]
 Starting NFS daemon:                                       [  OK  ]
 [root@galaxy root]#

 [root@galaxy root]#  exportfs -ra
 exportfs: No 'sync' or 'async' option specified for export
 "192.168.1.100/255.255.255.0:/home".
   Assuming default behaviour ('sync').
   NOTE: this default has changed from previous versions
 exportfs: No 'sync' or 'async' option specified for export
 "192.168.1.100/255.255.255.0:/home/govert".
   Assuming default behaviour ('sync').
   NOTE: this default has changed from previous versions
 exportfs: No 'sync' or 'async' option specified for export
 "192.168.1.100/255.255.255.0:/home/jason".
   Assuming default behaviour ('sync').
   NOTE: this default has changed from previous versions
 exportfs: No 'sync' or 'async' option specified for export
 "192.168.1.100/255.255.255.0:/home/engin".
   Assuming default behaviour ('sync').
   NOTE: this default has changed from previous versions
 exportfs: No 'sync' or 'async' option specified for export
 "192.168.1.100/255.255.255.0:/usr/beowulf".
   Assuming default behaviour ('sync').
   NOTE: this default has changed from previous versions
 [root@galaxy root]#


 0) Cluster details

 Master node: pentium Xeon dual processor 2GhZ 8Gb Ram
 Slave node 7x: pentium Xeon dual processor 2GhZ 8Gb Ram

 1) nfs version
 nfs-utils-1.0.1-2.9
 redhat-config-nfs-1.0.4-5

 2) kernel vesrions I used
 title Red Hat Linux (2.4.20-8bigmem)
 title Red Hat Linux (2.4.19)

 3) linux distribution
 RedHat 9

 4) Beowulf installation
 oscar-2.3.1

 5) contents of /etc/exports
 /home 192.168.1.100/255.255.255.0(rw,no_root_squash)
 /home/govert  192.168.1.100/255.255.255.0(rw,no_root_squash)
 /home/jason   192.168.1.100/255.255.255.0(rw,no_root_squash)
 #/home/william 192.168.1.100/255.255.255.0(rw,no_root_squash)
/home/engin   192.168.1.100/255.255.255.0(rw,no_root_squash)
 /usr/beowulf  192.168.1.100/255.255.255.0(rw,no_root_squash)

 6) rpcinfo -p server

 [root@galaxy root]# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32768  status
     100024    1   tcp  32768  status
     391002    2   tcp  32769  sgi_fam
     100011    1   udp    719  rquotad
     100011    2   udp    719  rquotad
     100011    1   tcp    722  rquotad
     100011    2   tcp    722  rquotad
    100005    1   udp  32811  mountd
     100005    1   tcp  32801  mountd
     100005    2   udp  32811  mountd
     100005    2   tcp  32801  mountd
     100005    3   udp  32811  mountd
     100005    3   tcp  32801  mountd
     100003    2   udp   2049  nfs
     100021    1   udp  32812  nlockmgr
     100021    3   udp  32812  nlockmgr
     100021    4   udp  32812  nlockmgr
 [root@galaxy root]#

 7)  rpcinfo -p client
 [root@star1 root]# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32768  status
     100024    1   tcp  32768  status
 [root@star1 root]#



 Hope you can help

 regards Govert

-- 







 -------------------------------------------------------------------------------------
| Dr. Govert de With     Research Fellow   
| Fluid Mechanics Research Group
| University of Hertfordshire 
| http://www.fmrg.herts.ac.uk          
| Tel: 01707 284124 Fax: 01707 285086 
 -------------------------------------------------------------------------------------



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
