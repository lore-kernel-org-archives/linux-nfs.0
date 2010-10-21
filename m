Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57698 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab0JUQUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/11] nfsd4: separate callback change and callback probe
Date: Thu, 21 Oct 2010 12:20:15 -0400
Message-Id: <1287678018-9266-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Only one of the nfsd4_callback_probe callers actually cares about
changing the callback information.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |   15 ++++++++++-----
 fs/nfsd/nfs4state.c    |    7 ++++---
 fs/nfsd/state.h        |    3 ++-
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 140bb36..d38ee3c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -550,7 +550,7 @@ int set_callback_cred(void)
 
 static struct workqueue_struct *callback_wq;
 
-void do_probe_callback(struct nfs4_client *clp)
+static void do_probe_callback(struct nfs4_client *clp)
 {
 	struct nfsd4_callback *cb = &clp->cl_cb_null;
 
@@ -568,17 +568,22 @@ void do_probe_callback(struct nfs4_client *clp)
 }
 
 /*
- * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
+ * Poke the callback thread to process any updates to the callback
+ * parameters, and send a null probe.
  */
-void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
+void nfsd4_probe_callback(struct nfs4_client *clp)
+{
+	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
+	do_probe_callback(clp);
+}
+
+void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 {
 	BUG_ON(atomic_read(&clp->cl_cb_set));
 
 	spin_lock(&clp->cl_lock);
 	memcpy(&clp->cl_cb_conn, conn, sizeof(struct nfs4_cb_conn));
-	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
 	spin_unlock(&clp->cl_lock);
-	do_probe_callback(clp);
 }
 
 /*
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 59bc001..2327a8c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -783,7 +783,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 		clp->cl_cb_conn.cb_minorversion = 1;
-		nfsd4_probe_callback(clp, &clp->cl_cb_conn);
+		nfsd4_probe_callback(clp);
 	}
 	return new;
 }
@@ -1912,7 +1912,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = nfserr_clid_inuse;
 		else {
 			atomic_set(&conf->cl_cb_set, 0);
-			nfsd4_probe_callback(conf, &unconf->cl_cb_conn);
+			nfsd4_change_callback(conf, &unconf->cl_cb_conn);
+			nfsd4_probe_callback(conf);
 			expire_client(unconf);
 			status = nfs_ok;
 
@@ -1946,7 +1947,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			}
 			move_to_confirmed(unconf);
 			conf = unconf;
-			nfsd4_probe_callback(conf, &conf->cl_cb_conn);
+			nfsd4_probe_callback(conf);
 			status = nfs_ok;
 		}
 	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b3bed36..bbc4d58 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -453,7 +453,8 @@ extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
-extern void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
+extern void nfsd4_probe_callback(struct nfs4_client *clp);
+extern void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *);
 extern void nfsd4_do_callback_rpc(struct work_struct *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern int nfsd4_create_callback_queue(void);
-- 
1.7.1

