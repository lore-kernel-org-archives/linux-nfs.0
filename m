Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56195 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932363Ab1AKQVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:47 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/14] nfsd4: make sure sequence flags are set after destroy_session
Date: Tue, 11 Jan 2011 11:21:30 -0500
Message-Id: <1294762894-21371-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If this loses any backchannel, make sure we have a chance to notice that
and set the sequence flags.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    6 ++++++
 fs/nfsd/nfs4state.c    |    3 +--
 fs/nfsd/state.h        |    1 +
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d32f49d..cb002dc 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -589,6 +589,12 @@ void nfsd4_probe_callback(struct nfs4_client *clp)
 	do_probe_callback(clp);
 }
 
+void nfsd4_probe_callback_sync(struct nfs4_client *clp)
+{
+	nfsd4_probe_callback(clp);
+	flush_workqueue(callback_wq);
+}
+
 void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 {
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b24f19d..00a50b8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1686,8 +1686,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	spin_unlock(&client_lock);
 
 	nfs4_lock_state();
-	/* wait for callbacks */
-	nfsd4_shutdown_callback(ses->se_client);
+	nfsd4_probe_callback_sync(ses->se_client);
 	nfs4_unlock_state();
 
 	nfsd4_del_conns(ses);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 32ff615..4e5bdfd 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -464,6 +464,7 @@ extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
+extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
 extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_do_callback_rpc(struct work_struct *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
-- 
1.7.1

