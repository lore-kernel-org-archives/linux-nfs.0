From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/8] nfsd4: fold release_session into expire_client
Date: Wed,  5 May 2010 01:43:52 +0300
Message-ID: <1273013032-32387-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53486 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760225Ab0EDWnz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:43:55 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

and grab the client lock once for all the client's sessions.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2d77ae8..388d244 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -612,15 +612,6 @@ unhash_session(struct nfsd4_session *ses)
 	list_del(&ses->se_perclnt);
 }
 
-static void
-release_session(struct nfsd4_session *ses)
-{
-	spin_lock(&client_lock);
-	unhash_session(ses);
-	spin_unlock(&client_lock);
-	nfsd4_put_session(ses);
-}
-
 void
 free_session(struct kref *kref)
 {
@@ -721,12 +712,15 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
+	spin_lock(&client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session  *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
 				 se_perclnt);
-		release_session(ses);
+		unhash_session(ses);
+		nfsd4_put_session(ses);
 	}
+	spin_unlock(&client_lock);
 	nfsd4_set_callback_client(clp, NULL);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
-- 
1.6.5.1

