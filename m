From: "howard chen" <howachen@gmail.com>
Subject: High loading with NFS (Performance issue?)
Date: Tue, 15 May 2007 00:55:03 +0800
Message-ID: <b66ddc900705140955w16de822cjc04d05e12f63fd7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hndp8-0003eC-QX
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:55:02 -0700
Received: from nz-out-0506.google.com ([64.233.162.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HndpA-00018E-Eo
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:55:05 -0700
Received: by nz-out-0506.google.com with SMTP id i11so625493nzi
	for <nfs@lists.sourceforge.net>; Mon, 14 May 2007 09:55:03 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello!


My NFS server has the following stats:


top -d 5
============================================

 00:38:21  up 449 days, 31 min,  2 users,  load average: 3.89, 3.94, 4.04
143 processes: 142 sleeping, 1 running, 0 zombie, 0 stopped
CPU0 states:  19.2% user   4.3% system    0.0% nice   0.0% iowait  75.4% idle
CPU1 states:  15.0% user   2.3% system    0.0% nice   0.0% iowait  82.0% idle
CPU2 states:  23.2% user   4.3% system    0.0% nice   0.0% iowait  71.4% idle
CPU3 states:  12.0% user   2.2% system    0.0% nice   0.0% iowait  85.2% idle
Mem:  3355136k av, 3210212k used,  144924k free,       0k shrd,  141920k buff
      1011360k active,             926060k inactive
Swap: 8184188k av,  230756k used, 7953432k free                 1652008k cached


iostat
============================================

Linux 2.4.31

avg-cpu:  %user   %nice    %sys   %idle
          66.75    0.03   20.18   13.05

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev8-0          607.43        95.16       114.58  626487552  754282354
dev8-1           28.92       230.62       182.00 1518207266 1198153062


cat /proc/net/rpc/nfsd
============================================

rc 2126161 488150588 1889246958
fh 288957 2463330121 0 135034 364483
io 2185592286 1281658699
th 8 152389353 957530.010 223376.040 843529.850 0.000 671914.750
520625.610 399462.450 304515.480 0.000 830962.390
ra 16 132542108 407104 72151 88010 34713 54685 46379 22455 47001 24140 89627147
net -1915443474 852923647 1526600175 27092
rpc -1915443589 115 115 0 0
proc2 18 139 866802296 74334343 0 799082289 1 222966486 0 243460468
58134635 56119993 53173221 0 0 119968 3 4934118 395747
[


cat /etc/fstab (SERVER)
============================================
/dev/sda2               /home                   ext3    defaults        1 2


cat /etc/fstab (CLIENT)
============================================
xxxx    nfs     rsize=32768,wsize=32768,bg,intr        0 0

The box is a dual Intel Xeon (HT enabled) 3.0Ghz, 4GB RAM server,
traffic is considered quite heavy at busy
hours (in general, around 7-10GB traffic per day), but...is the above
stats look normal?


Finally thought: Is it important to mount the partition using noatime?
If yes, how many % gain?

Thanks....

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
