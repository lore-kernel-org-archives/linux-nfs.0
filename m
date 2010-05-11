From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 9/9] nfsd4: nfsd4_destroy_session must set callback client under the state lock
Date: Wed, 12 May 2010 00:14:06 +0300
Message-ID: <1273612446-13763-1-git-send-email-bhalevy@panasas.com>
References: <4BE9C7A2.8030801@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43293 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0EKVOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:14:09 -0400
In-Reply-To: <4BE9C7A2.8030801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_set_callback_client must be called under the state lock to atomically
set or unset the callback client and shutting down the previous one.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    1 +
 fs/nfsd/nfs4state.c    |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 1d5051d..77bc9d3 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -718,6 +718,7 @@ void nfsd4_destroy_callback_queue(void)
 	destroy_workqueue(callback_wq);
 }
 
+/* must be called under the state lock */
 void nfsd4_set_callback_client(struct nfs4_client *clp, struct rpc_clnt *new)
 {
 	struct rpc_clnt *old = clp->cl_cb_client;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1a8fb39..e563597 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1428,8 +1428,10 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	unhash_session(ses);
 	spin_unlock(&client_lock);
 
+	nfs4_lock_state();
 	/* wait for callbacks */
 	nfsd4_set_callback_client(ses->se_client, NULL);
+	nfs4_unlock_state();
 	nfsd4_put_session(ses);
 	status = nfs_ok;
 out:
-- 
1.6.5.1

