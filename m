From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Correctly close old nfsd/lockd sockets.
Date: Fri, 14 Sep 2007 10:28:08 -0400
Message-ID: <20070914142808.GD20606@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, trond.myklebust@fys.uio.no
To: Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWC9c-0007ah-TD
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:28:21 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IWC9g-0006YG-F0
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:28:25 -0700
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

From: Neil Brown <neilb@suse.de>

Commit aaf68cfbf2241d24d46583423f6bff5c47e088b3 added a bias
to sk_inuse, so this test for an unused socket now fails.  So no
sockets get closed because they are old (they might get closed
if the client closed them).

This bug has existed since 2.6.21-rc1.

Thanks to Wolfgang Walter for finding and reporting the bug.

Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

This looks appropriate for both 2.6.23 and 2.6.22.x.

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e053f5a..0417283 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1593,7 +1593,8 @@ svc_age_temp_sockets(unsigned long closure)
 
 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
 			continue;
-		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
+		if (atomic_read(&svsk->sk_inuse) > 1
+		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
 		atomic_inc(&svsk->sk_inuse);
 		list_move(le, &to_be_aged);
-- 
1.5.3.1.42.gfe5df


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
