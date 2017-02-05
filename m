Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:40316 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751827AbdBEBz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 4 Feb 2017 20:55:57 -0500
From: Kinglong Mee <kinglongmee@163.com>
Subject: [PATCH 1/3] nfsd/callback: Cleanup callback cred when state shutdown
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <041689d2-003f-8269-a7a4-cc1ad15c8b11@163.com>
Date: Sun, 5 Feb 2017 09:55:48 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpccred get from rpc_lookup_machine_cred() should be put
when state shutdown.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c |  8 ++++++++
 fs/nfsd/nfs4state.c    | 10 ++++++----
 fs/nfsd/state.h        |  1 +
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index eb78109..fb6ca0a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -753,6 +753,14 @@ int set_callback_cred(void)
 	return 0;
 }
 
+void cleanup_callback_cred(void)
+{
+	if (callback_cred) {
+		put_rpccred(callback_cred);
+		callback_cred = NULL;
+	}
+}
+
 static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
 {
 	if (clp->cl_minorversion == 0) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a0dee8a..d35eb07 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7012,23 +7012,24 @@ nfs4_state_start(void)
 
 	ret = set_callback_cred();
 	if (ret)
-		return -ENOMEM;
+		return ret;
+
 	laundry_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4");
 	if (laundry_wq == NULL) {
 		ret = -ENOMEM;
-		goto out_recovery;
+		goto out_cleanup_cred;
 	}
 	ret = nfsd4_create_callback_queue();
 	if (ret)
 		goto out_free_laundry;
 
 	set_max_delegations();
-
 	return 0;
 
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
-out_recovery:
+out_cleanup_cred:
+	cleanup_callback_cred();
 	return ret;
 }
 
@@ -7086,6 +7087,7 @@ nfs4_state_shutdown(void)
 {
 	destroy_workqueue(laundry_wq);
 	nfsd4_destroy_callback_queue();
+	cleanup_callback_cred();
 }
 
 static void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4516e8b..005c911 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -615,6 +615,7 @@ extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
 		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
 extern int set_callback_cred(void);
+extern void cleanup_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
-- 
2.9.3


