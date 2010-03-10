From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 05/11] nfsd4: shutdown callbacks on expiry
Date: Tue,  9 Mar 2010 19:28:10 -0500
Message-ID: <1268180896-30921-6-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42165 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we've expired the client, there's no further purpose to the
callbacks; go ahead and shut down the callback client rather than
waiting for the last reference to go.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2d1ee98..9762fc0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -697,7 +697,6 @@ shutdown_callback_client(struct nfs4_client *clp)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	shutdown_callback_client(clp);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -750,6 +749,7 @@ expire_client(struct nfs4_client *clp)
 				 se_perclnt);
 		release_session(ses);
 	}
+	shutdown_callback_client(clp);
 	put_nfs4_client(clp);
 }
 
-- 
1.6.3.3

