From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Should NFS over loopback be over 10x slower compared to local fs
Date: Mon, 29 Mar 2004 12:25:04 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040329042504.GE14714@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7oKj-0001Rh-AN
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 20:25:09 -0800
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7oKi-00052k-KO
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 20:25:08 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id 1FBC437BCA
	for <nfs@lists.sourceforge.net>; Mon, 29 Mar 2004 04:25:07 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id 6E4AA16DD83
	for <nfs@lists.sourceforge.net>; Mon, 29 Mar 2004 04:25:06 +0000 (GMT)
To: nfs@lists.sourceforge.net
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

Hi, I did a postmark run on a local ext3 filesystem (data=writeback) and
then compared it with the same filesystem mounted over loopback and then
over a 100Mbit switch, I see a dramatic slowdown with postmark numbers
of loopback NFS compared to local fs. 

I am not sure if the numbers are appropiate. The ext3fs is exported 

/ext3 192.168.2.0/24(sync,rw,no_root_squash) 127.0.0.1/8(sync,rw,no_root_squash)

I am preparing a FreeBSD box to compare with it. Just wanted to share my
methodology and numbers with others to see if they could reproduce and
confirm/deny these numbers. All tests were run by 'root'


NFS server
kernel version 2.6.5-rc2-mm4, P3-500/384 MB 2x9GB SCSI, aic7xxx driver
global_tag_depth = 4
using anticipatory io scheduler

Postmark: 
        http://www.netapp.com/tech_library/3022.print
postmark config

set size 1024 20480
set subdirectories 100
set number 1000
set transactions 10000
set location /loopmount/nfsexport
set read 8192
set write 8192
set bias read 10
set bias create 5

local FS ext3 (data=writeback), htree disabled

Time:
        5 seconds total
        5 seconds of transactions (2000 per second)

Files:
        5982 created (1196 per second)
                Creation alone: 1000 files (1000 per second)
                Mixed with transactions: 4982 files (996 per second)
        10000 read (2000 per second)
        0 appended (0 per second)
        5982 deleted (1196 per second)
                Deletion alone: 964 files (964 per second)
                Mixed with transactions: 5018 files (1003 per second)

Data:
        102.62 megabytes read (20.52 megabytes per second)
        61.01 megabytes written (12.20 megabytes per second)

NFSv3 over loopback

mount -t nfs -o nfsvers=3,noatime,rsize=16384,wsize=16384 127.0.0.1:/ext3 /loopmount

Time:
        85 seconds total
        71 seconds of transactions (140 per second)

Files:
        5982 created (70 per second)
                Creation alone: 1000 files (71 per second)
                Mixed with transactions: 4982 files (70 per second)
        10000 read (140 per second)
        0 appended (0 per second)
        5982 deleted (70 per second)
                Deletion alone: 964 files (964 per second)
                Mixed with transactions: 5018 files (70 per second)

Data:
        102.62 megabytes read (1.21 megabytes per second)
        61.01 megabytes written (735.01 kilobytes per second)

NFS client (2.6.5-rc2-mm3)

NFSv3 over 100Mbps (TCP)
mount -t nfs -o tcp,nfsvers=3,noatime,bg,soft,rsize=32768,wsize=32768
192.168.2.214:/ext3 /nfsmount

Time:
        120 seconds total
        101 seconds of transactions (99 per second)

Files:
        5982 created (49 per second)
                Creation alone: 1000 files (66 per second)
                Mixed with transactions: 4982 files (49 per second)
        10000 read (99 per second)
        0 appended (0 per second)
        5982 deleted (49 per second)
                Deletion alone: 964 files (241 per second)
                Mixed with transactions: 5018 files (49 per second)

Data:
        102.62 megabytes read (875.68 kilobytes per second)
        61.01 megabytes written (520.64 kilobytes per second)

NFSv3 over 100Mbps (UDP)

mount -t nfs -o nfsvers=3,noatime,bg,soft,rsize=8192,wsize=8192 192.168.2.214:/ext3 /nfsmount

Time:
        208 seconds total
        174 seconds of transactions (57 per second)

Files:
        5982 created (28 per second)
                Creation alone: 1000 files (66 per second)
                Mixed with transactions: 4982 files (28 per second)
        10000 read (57 per second)
        0 appended (0 per second)
        5982 deleted (28 per second)
                Deletion alone: 964 files (50 per second)
                Mixed with transactions: 5018 files (28 per second)

Data:
        102.62 megabytes read (505.20 kilobytes per second)
        61.01 megabytes written (300.37 kilobytes per second)


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
