From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 03/11] nfsd4: don't store cb_xprt in client
Date: Tue,  9 Mar 2010 19:28:08 -0500
Message-ID: <1268180896-30921-4-git-send-email-bfields@citi.umich.edu>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-2-git-send-email-bfields@citi.umich.edu>
 <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab0CJA0v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 19:26:51 -0500
In-Reply-To: <1268180896-30921-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're storing this cb_xprt in the client just to pass it to the rpc
client creation code; we don't actually use it outside of the function
where we set cl_cb_xprt.  So just treat it as an argument to the
backchannel creation code.  Note we don't need to keep it around just to
hold a reference count, since the rpc code is doing that for us now.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    8 ++++----
 fs/nfsd/nfs4state.c    |    8 ++------
 fs/nfsd/state.h        |    3 +--
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ed12ad4..17cd439 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -461,7 +461,7 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cb_set an atomic? */
 
-int setup_callback_client(struct nfs4_client *clp)
+int setup_callback_client(struct nfs4_client *clp, struct svc_xprt *cb_xprt)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_timeout	timeparms = {
@@ -485,7 +485,7 @@ int setup_callback_client(struct nfs4_client *clp)
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
 	if (cb->cb_minorversion) {
-		args.bc_xprt = clp->cl_cb_xprt;
+		args.bc_xprt = cb_xprt;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
 	}
 	/* Create RPC client */
@@ -557,13 +557,13 @@ void do_probe_callback(struct nfs4_client *clp)
  * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
  */
 void
-nfsd4_probe_callback(struct nfs4_client *clp)
+nfsd4_probe_callback(struct nfs4_client *clp, struct svc_xprt *cb_xprt)
 {
 	int status;
 
 	BUG_ON(atomic_read(&clp->cl_cb_conn.cb_set));
 
-	status = setup_callback_client(clp);
+	status = setup_callback_client(clp, cb_xprt);
 	if (status) {
 		warn_no_callback_path(clp, status);
 		return;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index efef7f2..2d1ee98 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -698,8 +698,6 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-	if (clp->cl_cb_xprt)
-		svc_xprt_put(clp->cl_cb_xprt);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1333,8 +1331,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cr_ses->flags &= ~SESSION4_RDMA;
 
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
-			unconf->cl_cb_xprt = rqstp->rq_xprt;
-			svc_xprt_get(unconf->cl_cb_xprt);
 			rpc_copy_addr(
 				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
 				sa);
@@ -1343,7 +1339,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 				cstate->minorversion;
 			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
 			unconf->cl_cb_seq_nr = 1;
-			nfsd4_probe_callback(unconf);
+			nfsd4_probe_callback(unconf, rqstp->rq_xprt);
 		}
 		conf = unconf;
 	} else {
@@ -1666,7 +1662,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			}
 			move_to_confirmed(unconf);
 			conf = unconf;
-			nfsd4_probe_callback(conf);
+			nfsd4_probe_callback(conf, NULL);
 			status = nfs_ok;
 		}
 	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fefeae2..b09943a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -226,7 +226,6 @@ struct nfs4_client {
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
 	u32			cl_cb_seq_nr;
-	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
 };
@@ -380,7 +379,7 @@ extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern int set_callback_cred(void);
-extern void nfsd4_probe_callback(struct nfs4_client *clp);
+extern void nfsd4_probe_callback(struct nfs4_client *clp, struct svc_xprt *);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
-- 
1.6.3.3

