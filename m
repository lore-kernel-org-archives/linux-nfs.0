From: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
Subject: nfs performance: read only/gigE/nolock/1Tb per day
Date: Sun, 21 Apr 2002 15:08:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1331088561078.20020421150847@netzone.ch>
Reply-To: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail1.hostpark.net ([212.243.197.31])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zH5d-0004df-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Apr 2002 06:09:13 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail1.hostpark.net (Postfix) with ESMTP id F191078AD2
	for <nfs@lists.sourceforge.net>; Sun, 21 Apr 2002 15:15:37 +0200 (CEST)
Received: from jamie (unknown [195.144.47.58])
	by mail1.hostpark.net (Postfix) with ESMTP id AAF9578BFC
	for <nfs@lists.sourceforge.net>; Sun, 21 Apr 2002 15:15:36 +0200 (CEST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi Jason,

I have seen (as posted before) our linux-nfs boxes receiving 9 - 10
MByte/s over a 100  Mbit Network. This was as i was doing some
testing.

Is has to be noted that this is a  sequential read from a 500 MB file.
When reading the "real" data, i hit about 1 - 2 MByte/s

In my Setup, i have not seen a great speed increase in using TCP.
I also don't know how good the linux-nfs Server is at that. I am just
using the client and am using a dedicated NAS Server.

The Block sizes on NFSv2 are from 1024 - 8192. With NFSv3 the Max. is
32768. The Blocksize is dependent on the NFS Version, not on TCP or
UDP Transport. I am using a Stock 2.4.17 Kernel with Trond's NFS-All
Patch.


Kind Regards

Gavin Woodhatch

NetZone Ltd.


> is it possible to change NFS mount size from 1024 to 8192 (especially with GigE).
>   i have tried this and was seeing slowdowns in nfs access, so reverted back to
>   1024 block size.

>   the NFS clients mount the filesystems with:
>   ro,rsize=1024,nolock,hard,bg,intr,retrans=8,nfsvers=3,timeo=10


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
