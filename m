From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 19/22] lockd: fix use of h_nextrebind
Date: Sat, 5 Aug 2006 15:06:49 +0200
Message-ID: <20060805130649.GA8112@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrh-000793-KH
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:53 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrh-0000U3-EY
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:54 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 2E96B101B3
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:49 +0200 (CEST)
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

From: Olaf Kirch <okir@suse.de>
Subject: lockd: fix use of h_nextrebind

  nlmclnt_recovery would try to force a portmap rebind by setting
  host->h_nextrebind to 0. The right thing to do here is to set it
  to the current time.

Signed-off-by: okir@suse.de

 fs/lockd/clntlock.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: build/fs/lockd/clntlock.c
===================================================================
--- build.orig/fs/lockd/clntlock.c
+++ build/fs/lockd/clntlock.c
@@ -187,7 +187,7 @@ restart:
 	/* Force a portmap getport - the peer's lockd will
 	 * most likely end up on a different port.
 	 */
-	host->h_nextrebind = 0;
+	host->h_nextrebind = jiffies;
 	nlm_rebind_host(host);
 
 	/* First, reclaim all locks that have been granted. */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
