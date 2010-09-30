Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab0I3QTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 01/16] nfsd4: minor variable renaming (cb -> conn)
Date: Thu, 30 Sep 2010 12:18:58 -0400
Message-Id: <1285863553-8945-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Now that we have both nfsd4_callback and nfsd4_cb_conn structures, I get
confused if variables of both types are always named cb....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   16 ++++++++--------
 fs/nfsd/nfs4state.c    |   28 ++++++++++++++--------------
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 014482c..30adfad 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -472,7 +472,7 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cl_cb_set an atomic? */
 
-int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
+int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 {
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
@@ -480,11 +480,11 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 	};
 	struct rpc_create_args args = {
 		.protocol	= XPRT_TRANSPORT_TCP,
-		.address	= (struct sockaddr *) &cb->cb_addr,
-		.addrsize	= cb->cb_addrlen,
+		.address	= (struct sockaddr *) &conn->cb_addr,
+		.addrsize	= conn->cb_addrlen,
 		.timeout	= &timeparms,
 		.program	= &cb_program,
-		.prognumber	= cb->cb_prog,
+		.prognumber	= conn->cb_prog,
 		.version	= 0,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
@@ -494,8 +494,8 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 
 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		return -EINVAL;
-	if (cb->cb_minorversion) {
-		args.bc_xprt = cb->cb_xprt;
+	if (conn->cb_minorversion) {
+		args.bc_xprt = conn->cb_xprt;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
 	}
 	/* Create RPC client */
@@ -562,13 +562,13 @@ void do_probe_callback(struct nfs4_client *clp)
 /*
  * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
  */
-void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
+void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 {
 	int status;
 
 	BUG_ON(atomic_read(&clp->cl_cb_set));
 
-	status = setup_callback_client(clp, cb);
+	status = setup_callback_client(clp, conn);
 	if (status) {
 		warn_no_callback_path(clp, status);
 		return;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cf0d2ff..d347180 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -207,7 +207,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
-	struct nfs4_cb_conn *cb = &stp->st_stateowner->so_client->cl_cb_conn;
+	struct nfs4_cb_conn *conn = &stp->st_stateowner->so_client->cl_cb_conn;
 
 	dprintk("NFSD alloc_init_deleg\n");
 	/*
@@ -234,7 +234,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	nfs4_file_get_access(fp, O_RDONLY);
 	dp->dl_flock = NULL;
 	dp->dl_type = type;
-	dp->dl_ident = cb->cb_ident;
+	dp->dl_ident = conn->cb_ident;
 	dp->dl_stateid.si_boot = boot_time;
 	dp->dl_stateid.si_stateownerid = current_delegid++;
 	dp->dl_stateid.si_fileid = 0;
@@ -1098,7 +1098,7 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 {
-	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
+	struct nfs4_cb_conn *conn = &clp->cl_cb_conn;
 	unsigned short expected_family;
 
 	/* Currently, we only support tcp and tcp6 for the callback channel */
@@ -1111,24 +1111,24 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
 	else
 		goto out_err;
 
-	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
+	conn->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
 					    se->se_callback_addr_len,
-					    (struct sockaddr *) &cb->cb_addr,
-					    sizeof(cb->cb_addr));
+					    (struct sockaddr *)&conn->cb_addr,
+					    sizeof(conn->cb_addr));
 
-	if (!cb->cb_addrlen || cb->cb_addr.ss_family != expected_family)
+	if (!conn->cb_addrlen || conn->cb_addr.ss_family != expected_family)
 		goto out_err;
 
-	if (cb->cb_addr.ss_family == AF_INET6)
-		((struct sockaddr_in6 *) &cb->cb_addr)->sin6_scope_id = scopeid;
+	if (conn->cb_addr.ss_family == AF_INET6)
+		((struct sockaddr_in6 *)&conn->cb_addr)->sin6_scope_id = scopeid;
 
-	cb->cb_minorversion = 0;
-	cb->cb_prog = se->se_callback_prog;
-	cb->cb_ident = se->se_callback_ident;
+	conn->cb_minorversion = 0;
+	conn->cb_prog = se->se_callback_prog;
+	conn->cb_ident = se->se_callback_ident;
 	return;
 out_err:
-	cb->cb_addr.ss_family = AF_UNSPEC;
-	cb->cb_addrlen = 0;
+	conn->cb_addr.ss_family = AF_UNSPEC;
+	conn->cb_addrlen = 0;
 	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
-- 
1.7.0.4

