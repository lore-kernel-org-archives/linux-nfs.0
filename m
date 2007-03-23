From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 4] knfsd: nfsd4: remove superfluous
	cancel_delayed_work() call
Date: Fri, 23 Mar 2007 11:47:04 +1100
Message-ID: <1070323004704.28989@suse.de>
References: <20070323114512.28822.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUXvw-000190-FZ
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:47:08 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUXvy-0005lA-HS
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:47:10 -0700
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

From: "J. Bruce Fields" <bfields@fieldses.org>

This cancel_delayed_work call is called from a function that is only
called from a piece of code that immediate follows a cancel and
destruction of the workqueue, so it's clearly a mistake.

Cc: Oleg Nesterov <oleg@tv-sign.ru>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    1 -
 1 file changed, 1 deletion(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2007-03-23 11:19:14.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2007-03-23 11:19:34.000000000 +1100
@@ -3260,7 +3260,6 @@ __nfs4_state_shutdown(void)
 		unhash_delegation(dp);
 	}
 
-	cancel_delayed_work(&laundromat_work);
 	nfsd4_shutdown_recdir();
 	nfs4_init = 0;
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
