From: "Jake Hammer" <hammer@clarkisland.com>
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Wed, 4 Dec 2002 21:55:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBAEHNCJAA.hammer@clarkisland.com>
References: <3DEEDD90.915BAFF7@amis.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "NFS" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Joyx-0001oT-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 21:55:31 -0800
To: "Eric Whiting" <ewhiting@amis.com>
In-Reply-To: <3DEEDD90.915BAFF7@amis.com>
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

Hi All, Eric,

> 1. Make sure your network is clean and doing duplex right. (test using
> two ftp sessions moving those 10 gig files -- one reading while one
> writes) Ftp will let you know if the TCP part of your network is healthy
> under full duplex loads.

Network is pristine and duplex is 100% correct. Our Sun and NetApp gear
works great.

> 2. Try TCP mounts

They are even slower with read+write! 1-2MB/sec!

> 3. Try NFS V3

Not [well] supported for TCP. Since the Neil Brown patches enable it, I
tried both UDP and TCP. Both are the same on read+write. UDP is faster by
10-15% on read/write but the same on read+write.

> 4. Make sure your IDE RAID system on the server is healthy. Can it
> handle concurrent read/write processes on the local box -- with NFS out
> of the picture?

Local read/write and read+write is *great* - no issues at all. Local write
is ~100MB/sec, local read is ~120MB/sec, and local read+write is ~105MB/sec.
It's not the disk subsystem.

> What is the filesystem you have on the RAID5 setup?
> reiserfs/ext3/xfs/jfs?
> What sort of IDE HW raid supports 14 disks? Or are you using SW raid?

2 x 8 port 3ware IDE RAID cards, RAID 5 done in software by 2.4.19 IBM EVMS.
Filesystem is EXT3, mounted with defaults. 14 disks.

To summarize:

Local disk is fast read, write, and read+write. NFS is sort of fast for read
and for write, but it *utterly* dies on read + write UDP and TCP. Network is
clean.

> I would like to see a solution to this sort of problem as well.

Glad you're seeing it as well. I hope it can be sorted out.

Thanks,

Jake




-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
