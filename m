Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:45881 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbeERPjf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 11:39:35 -0400
Received: by mail-io0-f178.google.com with SMTP id c9-v6so6672958iob.12
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 08:39:34 -0700 (PDT)
Subject: [PATCH RFC 4/4] nfsd: Remove callback_cred
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com
Date: Fri, 18 May 2018 11:39:33 -0400
Message-ID: <20180518153933.7706.67273.stgit@klimt.1015granger.net>
In-Reply-To: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The global callback_cred is no longer used, so it can be
removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4callback.c |   20 --------------------
 fs/nfsd/nfs4state.c    |   10 ++--------
 fs/nfsd/state.h        |    2 --
 3 files changed, 2 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0e9ff86..c088f97 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -746,26 +746,6 @@ static int max_cb_time(struct net *net)
 	return max(nn->nfsd4_lease/10, (time_t)1) * HZ;
 }
 
-static struct rpc_cred *callback_cred;
-
-int set_callback_cred(void)
-{
-	if (callback_cred)
-		return 0;
-	callback_cred = rpc_lookup_machine_cred("nfs");
-	if (!callback_cred)
-		return -ENOMEM;
-	return 0;
-}
-
-void cleanup_callback_cred(void)
-{
-	if (callback_cred) {
-		put_rpccred(callback_cred);
-		callback_cred = NULL;
-	}
-}
-
 static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
 {
 	if (clp->cl_minorversion == 0) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e56abb7..88dc890 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7195,14 +7195,10 @@ static int nfs4_state_create_net(struct net *net)
 {
 	int ret;
 
-	ret = set_callback_cred();
-	if (ret)
-		return ret;
-
 	laundry_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4");
 	if (laundry_wq == NULL) {
 		ret = -ENOMEM;
-		goto out_cleanup_cred;
+		goto out;
 	}
 	ret = nfsd4_create_callback_queue();
 	if (ret)
@@ -7213,8 +7209,7 @@ static int nfs4_state_create_net(struct net *net)
 
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
-out_cleanup_cred:
-	cleanup_callback_cred();
+out:
 	return ret;
 }
 
@@ -7251,7 +7246,6 @@ static int nfs4_state_create_net(struct net *net)
 {
 	destroy_workqueue(laundry_wq);
 	nfsd4_destroy_callback_queue();
-	cleanup_callback_cred();
 }
 
 static void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f3772ea..0b15dac 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -617,8 +617,6 @@ extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 							struct nfsd_net *nn);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
 		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
-extern int set_callback_cred(void);
-extern void cleanup_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);

