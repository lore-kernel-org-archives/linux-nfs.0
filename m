From: Venkatesh K S <vsharma@sonoasystems.com>
Subject: FILE_SYNC slower than UNSTABLE + COMMIT
Date: 13 Jan 2007 09:56:14 +0530
Message-ID: <jeirfb4knt.fsf@sonoasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5aZj-00075w-SW
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 20:33:04 -0800
Received: from [67.153.191.236] (helo=sonoasystems.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H5aZk-0006GV-H3
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 20:33:05 -0800
Received: from vsharma-dt (venkatesh.svind.sonoasystems.com [10.10.2.71] (may
	be forged))
	by sonoasystems.com (8.13.1/8.13.1) with ESMTP id l0D4WtPb029830
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 20:32:57 -0800
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I have 2 different kernel versions and I notice that the way
the nfs client honors O_SYNC is different.
In 2.6.12 variant the client issues UNSTABLE followed by
a COMMIT call.
In 2.6.16 variant the nfs client issues a FILE_SYNC call.

The FILE_SYNC call turns out to be about 3 times slower
against our server. Infact a simple write followed by a
fsync also turns out to be FILE_SYNC calls. The mount
is not a "sync" mount.


Is there a way a to make these calls in 2.6.16 or later release
UNSTABLE + COMMIT ?

Are FILE_SYNC calls always slower (I wud assume for NVRAM based server
it may be as fast as UNSTABLE). In which case this fix into a newer
kernel seems to be biased towards working well with such servers

regards,
-venkatesh


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
