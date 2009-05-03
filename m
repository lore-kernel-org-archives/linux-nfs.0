From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: rename callback struct to cb_conn
Date: Sun,  3 May 2009 14:16:35 -0400
Message-ID: <1241374599-20348-10-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
 <1241374599-20348-9-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58611 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-9-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

I want to use the name for a struct that actually does represent a
single callback.

(Actually, I've never been sure it helps to a separate struct for the
callback information.  Some day maybe those fields could just be dumped
into struct nfs4_client.  I don't know.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |   16 ++++++++--------
 fs/nfsd/nfs4state.c        |   22 +++++++++++-----------
 include/linux/nfsd/state.h |    4 ++--
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0aaf68b..ed860d7 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -369,7 +369,7 @@ static int max_cb_time(void)
 int setup_callback_client(struct nfs4_client *clp)
 {
 	struct sockaddr_in	addr;
-	struct nfs4_callback    *cb = &clp->cl_callback;
+	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
 		.to_retries	= 0,
@@ -422,7 +422,7 @@ static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 	if (task->tk_status)
 		warn_no_callback_path(clp, task->tk_status);
 	else
-		atomic_set(&clp->cl_callback.cb_set, 1);
+		atomic_set(&clp->cl_cb_conn.cb_set, 1);
 	put_nfs4_client(clp);
 }
 
@@ -430,7 +430,7 @@ static const struct rpc_call_ops nfsd4_cb_probe_ops = {
 	.rpc_call_done = nfsd4_cb_probe_done,
 };
 
-static struct rpc_cred *lookup_cb_cred(struct nfs4_callback *cb)
+static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
 {
 	struct auth_cred acred = {
 		.machine_cred = 1
@@ -448,7 +448,7 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_callback *cb)
 
 void do_probe_callback(struct nfs4_client *clp)
 {
-	struct nfs4_callback    *cb = &clp->cl_callback;
+	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
 		.rpc_argp       = clp,
@@ -480,7 +480,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 {
 	int status;
 
-	BUG_ON(atomic_read(&clp->cl_callback.cb_set));
+	BUG_ON(atomic_read(&clp->cl_cb_conn.cb_set));
 
 	status = setup_callback_client(clp);
 	if (status) {
@@ -501,12 +501,12 @@ void
 nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
-	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
 	struct nfs4_cb_recall *cbr = &dp->dl_recall;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_argp = cbr,
-		.rpc_cred = clp->cl_callback.cb_cred
+		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
 	int retries = 1;
 	int status = 0;
@@ -519,7 +519,7 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		switch (status) {
 			case -EIO:
 				/* Network partition? */
-				atomic_set(&clp->cl_callback.cb_set, 0);
+				atomic_set(&clp->cl_cb_conn.cb_set, 0);
 			case -EBADHANDLE:
 			case -NFS4ERR_BAD_STATEID:
 				/* Race: client probably got cb_recall
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b205c7d..d7b5e6b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -182,7 +182,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
-	struct nfs4_callback *cb = &stp->st_stateowner->so_client->cl_callback;
+	struct nfs4_cb_conn *cb = &stp->st_stateowner->so_client->cl_cb_conn;
 
 	dprintk("NFSD alloc_init_deleg\n");
 	if (fp->fi_had_conflict)
@@ -633,19 +633,19 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static void
 shutdown_callback_client(struct nfs4_client *clp)
 {
-	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
 
 	if (clnt) {
 		/*
 		 * Callback threads take a reference on the client, so there
 		 * should be no outstanding callbacks at this point.
 		 */
-		clp->cl_callback.cb_client = NULL;
+		clp->cl_cb_conn.cb_client = NULL;
 		rpc_shutdown_client(clnt);
 	}
-	if (clp->cl_callback.cb_cred) {
-		put_rpccred(clp->cl_callback.cb_cred);
-		clp->cl_callback.cb_cred = NULL;
+	if (clp->cl_cb_conn.cb_cred) {
+		put_rpccred(clp->cl_cb_conn.cb_cred);
+		clp->cl_cb_conn.cb_cred = NULL;
 	}
 }
 
@@ -719,7 +719,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 		return NULL;
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_count, 1);
-	atomic_set(&clp->cl_callback.cb_set, 0);
+	atomic_set(&clp->cl_cb_conn.cb_set, 0);
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
@@ -971,7 +971,7 @@ parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int *cbaddrp, unsigne
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
-	struct nfs4_callback *cb = &clp->cl_callback;
+	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
 
 	/* Currently, we only support tcp for the callback channel */
 	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
@@ -1691,7 +1691,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		else {
 			/* XXX: We just turn off callbacks until we can handle
 			  * change request correctly. */
-			atomic_set(&conf->cl_callback.cb_set, 0);
+			atomic_set(&conf->cl_cb_conn.cb_set, 0);
 			expire_client(unconf);
 			status = nfs_ok;
 
@@ -2425,7 +2425,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
-	struct nfs4_callback *cb = &sop->so_client->cl_callback;
+	struct nfs4_cb_conn *cb = &sop->so_client->cl_cb_conn;
 	struct file_lock fl, *flp = &fl;
 	int status, flag = 0;
 
@@ -2617,7 +2617,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	renew_client(clp);
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
-			&& !atomic_read(&clp->cl_callback.cb_set))
+			&& !atomic_read(&clp->cl_cb_conn.cb_set))
 		goto out;
 	status = nfs_ok;
 out:
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 8d882a3..563c367 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -88,7 +88,7 @@ struct nfs4_delegation {
 #define dl_fh           dl_recall.cbr_fh
 
 /* client delegation callback info */
-struct nfs4_callback {
+struct nfs4_cb_conn {
 	/* SETCLIENTID info */
 	u32                     cb_addr;
 	unsigned short          cb_port;
@@ -186,7 +186,7 @@ struct nfs4_client {
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
-	struct nfs4_callback	cl_callback;    /* callback info */
+	struct nfs4_cb_conn	cl_cb_conn;     /* callback info */
 	atomic_t		cl_count;	/* ref count */
 	u32			cl_firststate;	/* recovery dir creation */
 
-- 
1.6.0.4

