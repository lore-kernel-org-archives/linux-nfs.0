Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54141 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756119Ab2GJQHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/7] nfsd4: remove unnecessary comment
Date: Tue, 10 Jul 2012 12:07:40 -0400
Message-Id: <1341936466-3821-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

For the most part readers of cl_cb_state only need a value that is
"eventually" right.  And the value is set only either 1) in response to
some change of state, in which case it's set to UNKNOWN and then a
callback rpc is sent to probe the real state, or b) in the handling of a
response to such a callback.  UNKNOWN is therefore always a "temporary"
state, and for the other states we're happy to accept last writer wins.

So I think we're OK here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a5fd6b9..cbaf4f8 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -756,7 +756,6 @@ static void do_probe_callback(struct nfs4_client *clp)
  */
 void nfsd4_probe_callback(struct nfs4_client *clp)
 {
-	/* XXX: atomicity?  Also, should we be using cl_flags? */
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	do_probe_callback(clp);
-- 
1.7.9.5

