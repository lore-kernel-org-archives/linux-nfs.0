From: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
Subject: NFSv4 problem?(chown(1) process hang)
Date: Thu, 16 Mar 2006 12:07:50 +0900
Message-ID: <20060316120750.76054181.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FJiqe-0007nY-3T
	for nfs@lists.sourceforge.net; Wed, 15 Mar 2006 19:08:24 -0800
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FJiqd-000385-JU
	for nfs@lists.sourceforge.net; Wed, 15 Mar 2006 19:08:24 -0800
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k2G38D1W017712 for <nfs@lists.sourceforge.net>; Thu, 16 Mar 2006 12:08:13 +0900
        (envelope-from s-sagawa@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k2G38CkG021873 for <nfs@lists.sourceforge.net>; Thu, 16 Mar 2006 12:08:12 +0900
	(envelope-from s-sagawa@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E81AFD40B6
	for <nfs@lists.sourceforge.net>; Thu, 16 Mar 2006 12:08:11 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 458C4D40B9
	for <nfs@lists.sourceforge.net>; Thu, 16 Mar 2006 12:08:11 +0900 (JST)
Received: from fjmscan503.ms.jp.fujitsu.com (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm504.ms.jp.fujitsu.com with ESMTP id k2G37pRE019888
	for <nfs@lists.sourceforge.net>; Thu, 16 Mar 2006 12:07:51 +0900
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hello, 

In the NFS access operation,
"chown guest.guest file" causes the process hang.


[NG pattern]---------------------------------------------------------
   <server kernel-2.6.9>
   1. System startup

   # chkconfig --list | egrep "nfs|rpcidmap"
   nfs             0:off   1:off   2:on    3:on    4:on    5:on    6:off
   rpcidmapd       0:off   1:off   2:off   3:on    4:on    5:on    6:off
   nfslock         0:off   1:off   2:off   3:on    4:on    5:on    6:off
   # 
   # cat /etc/exports 
   /work *(rw,sync,no_root_squash,fsid=0)
   #  
   # ls -ld /work
   drwxr-xr-x  3 root root 4096 Mar 16 13:22 /work
   # 
   # grep guest /etc/passwd
   guest:x:501:501::/home/guest:/bin/bash
   # 
   # cat /etc/idmapd.conf 
   [General]
   
   Verbosity = 0
   Pipefs-Directory = /var/lib/nfs/rpc_pipefs
   Domain = localdomain
   
   [Mapping]
   
   Nobody-User = nobody
   Nobody-Group = nobody
   
   [Translation]
   Method = nsswitch
   # 

   <client kernel-2.6.9>
   1. System startup

   # showmount -e nfsserver
   Export list for nfsserver:
   /work *
   #
   # grep guest /etc/passwd
   guest:x:501:501::/home/guest:/bin/bash
   # 
   # mount -t nfs4 nfsserver:/ /mnt/nfs
   # df
   Filesystem           1K-blocks      Used Available Use% Mounted on
   /dev/hda2             10080520   8027400   1541052  84% /
   /dev/hda1               101086     24234     71633  26% /boot
   none                    517932         0    517932   0% /dev/shm
   /dev/hda5              4814936   1847656   2722692  41% /work
   nfsserver:/            1027776      1280    974272   1% /mnt/nfs
   # cd /mnt/nfs
   # ls -l hogehoge 
   -rw-r--r--  1 root root 9 Mar 16  2006 hogehoge
   # chown guest.guest hogehoge
   hang.

[OK pattern]-----------------------------------------------------------
   <server>
   1. System startup
   2. /etc/init.d/rpcidmapd restart
   :
   : 
   It is the same as the operation of mentioning above. 


This problem doesn't occur if rpcidmapd is restart. 
Is it a problem of my setting?
Or, NFSv4 problem?

Best Regards,
Sagawa.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
