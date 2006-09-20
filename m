From: "Chuck Lever" <chucklever@gmail.com>
Subject: cel's patches for 2.6.18 kernels
Date: Wed, 20 Sep 2006 14:28:10 -0400
Message-ID: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQ6nt-0008V3-II
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 11:28:13 -0700
Received: from wr-out-0506.google.com ([64.233.184.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQ6ns-000152-5G
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 11:28:14 -0700
Received: by wr-out-0506.google.com with SMTP id i20so198666wra
	for <nfs@lists.sourceforge.net>; Wed, 20 Sep 2006 11:28:11 -0700 (PDT)
To: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
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

This e-mail announces the release of cel's patch set for Linux 2.6.18
kernels.  The patchset contains several important features, including:

1.  The finishing patches for the RPC client transport switch

2.  Support for rpcbind protocol versions 2 and 3

3.  Some support for IPv6 in the RPC and NFS clients

4.  Elimination of the BKL in the RPC and NFS clients

5.  Elimination of the RPC slot table

The patches are available from:

  http://oss.oracle.com/~cel/linux-2.6/2.6.18/

Older versions of this patchset continue to be available at:

  http://oss.oracle.com/~cel/linux-2.6/

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
