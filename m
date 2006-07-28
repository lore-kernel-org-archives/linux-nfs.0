From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] knfsd: Introduction
Date: Fri, 28 Jul 2006 15:09:40 +1000
Message-ID: <20060728150606.29533.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6KcK-0003sf-5c
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:32 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6KcJ-0002UK-3p
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 22:10:32 -0700
To: Andrew Morton <akpm@osdl.org>
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

Following are 4 patches for knfsd in 2.6-mm-latest.  They address some
issues found by Bruce Fields greatly appreciated patch review.  Thanks Bruce.
They (like the patches they build on) are *not* 2.6.18 material.

NeilBrown


 [PATCH 001 of 4] knfsd: Drop 'serv' option to svc_recv and svc_process
 [PATCH 002 of 4] knfsd: Check return value of lockd_up in write_ports
 [PATCH 003 of 4] knfsd: Move makesock failed warning into make_socks.
 [PATCH 004 of 4] knfsd: Correctly handle error condition from lockd_up

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
