From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/8] nfsd4: shutdown callbacks on expiry
Date: Thu,  8 Apr 2010 11:59:16 -0400
Message-ID: <1270742362-9375-3-git-send-email-bfields@citi.umich.edu>
References: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
 <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932661Ab0DHP4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:55 -0400
In-Reply-To: <1270742362-9375-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we've expired the client, there's no further purpose to the
callbacks; go ahead and shut down the callback client rather than
waiting for the last reference to go.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index efef7f2..9ce5831 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -697,9 +697,6 @@ shutdown_callback_client(struct nfs4_client *clp)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	shutdown_callback_client(clp);
-	if (clp->cl_cb_xprt)
-		svc_xprt_put(clp->cl_cb_xprt);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -752,6 +749,9 @@ expire_client(struct nfs4_client *clp)
 				 se_perclnt);
 		release_session(ses);
 	}
+	shutdown_callback_client(clp);
+	if (clp->cl_cb_xprt)
+		svc_xprt_put(clp->cl_cb_xprt);
 	put_nfs4_client(clp);
 }
 
-- 
1.6.3.3

