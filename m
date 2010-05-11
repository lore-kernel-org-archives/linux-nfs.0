From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 5/9] nfsd4: refactor expire_client
Date: Wed, 12 May 2010 00:13:16 +0300
Message-ID: <1273612396-13610-1-git-send-email-bhalevy@panasas.com>
References: <4BE9C7A2.8030801@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53686 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0EKVNT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:13:19 -0400
In-Reply-To: <4BE9C7A2.8030801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate out unhashing of the client and session.
To be used later by the laundromat.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3f572cb..dede43c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -693,6 +693,20 @@ free_client(struct nfs4_client *clp)
 	kfree(clp);
 }
 
+/* must be called under the client_lock */
+static inline void
+unhash_client_locked(struct nfs4_client *clp)
+{
+	list_del(&clp->cl_lru);
+	while (!list_empty(&clp->cl_sessions)) {
+		struct nfsd4_session  *ses;
+		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
+				 se_perclnt);
+		unhash_session(ses);
+		nfsd4_put_session(ses);
+	}
+}
+
 static void
 expire_client(struct nfs4_client *clp)
 {
@@ -719,21 +733,14 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
+	nfsd4_set_callback_client(clp, NULL);
+	if (clp->cl_cb_conn.cb_xprt)
+		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
 	spin_lock(&client_lock);
-	list_del(&clp->cl_lru);
-	while (!list_empty(&clp->cl_sessions)) {
-		struct nfsd4_session  *ses;
-		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
-				 se_perclnt);
-		unhash_session(ses);
-		nfsd4_put_session(ses);
-	}
+	unhash_client_locked(clp);
 	spin_unlock(&client_lock);
-	nfsd4_set_callback_client(clp, NULL);
-	if (clp->cl_cb_conn.cb_xprt)
-		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	free_client(clp);
 }
 
-- 
1.6.5.1

