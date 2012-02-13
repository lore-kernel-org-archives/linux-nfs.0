Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:44787 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013Ab2BMPPz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 10:15:55 -0500
Received: by qafk1 with SMTP id k1so3283230qaf.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 07:15:54 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v6 3/5] nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
Date: Mon, 13 Feb 2012 10:15:43 -0500
Message-Id: <1329146145-7602-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1329146145-7602-1-git-send-email-jlayton@redhat.com>
References: <1329146145-7602-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need a way to flag the nfs4_client as already being recorded on
stable storage so that we don't continually upcall. Currently, that's
recorded in the cl_firststate field of the client struct. Using an
entire u32 to store a flag is rather wasteful though.

The cl_cb_flags field is only using 2 bits right now, so repurpose that
to a generic flags field. Rename NFSD4_CLIENT_KILL to
NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
flags. Add a mask that we can use for existing checks that look to see
whether any flags are set, so that the new flags don't interfere.

Convert all references to cl_firstate to the NFSD4_CLIENT_STABLE flag,
and add a new NFSD4_CLIENT_RECLAIM_COMPLETE flag. I believe there's an
existing bug here too that this should fix:

nfs4_set_claim_prev sets cl_firststate on the first CLAIM_PREV open.
nfsd4_reclaim_complete looks for that flag though, and returns
NFS4ERR_COMPLETE_ALREADY if it's set. The upshot here is that once a
client does a CLAIM_PREV open, the RECLAIM_COMPLETE call will fail.
Let's fix this by adding a new RECLAIM_COMPLETE flag on the client to
indicate that that's already been done.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c |   14 +++++++-------
 fs/nfsd/nfs4proc.c     |    3 ++-
 fs/nfsd/nfs4recover.c  |   20 +++++++++++++-------
 fs/nfsd/nfs4state.c    |    4 ++--
 fs/nfsd/state.h        |   10 ++++++----
 5 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6f3ebb4..8199eb6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -754,9 +754,9 @@ static void do_probe_callback(struct nfs4_client *clp)
  */
 void nfsd4_probe_callback(struct nfs4_client *clp)
 {
-	/* XXX: atomicity?  Also, should we be using cl_cb_flags? */
+	/* XXX: atomicity?  Also, should we be using cl_flags? */
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
-	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
+	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	do_probe_callback(clp);
 }
 
@@ -915,7 +915,7 @@ void nfsd4_destroy_callback_queue(void)
 /* must be called under the state lock */
 void nfsd4_shutdown_callback(struct nfs4_client *clp)
 {
-	set_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags);
+	set_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags);
 	/*
 	 * Note this won't actually result in a null callback;
 	 * instead, nfsd4_do_callback_rpc() will detect the killed
@@ -966,15 +966,15 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 		clp->cl_cb_conn.cb_xprt = NULL;
 	}
-	if (test_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags))
+	if (test_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags))
 		return;
 	spin_lock(&clp->cl_lock);
 	/*
 	 * Only serialized callback code is allowed to clear these
 	 * flags; main nfsd code can only set them:
 	 */
-	BUG_ON(!clp->cl_cb_flags);
-	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
+	BUG_ON(!(clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK));
+	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
 	c = __nfsd4_find_backchannel(clp);
 	if (c) {
@@ -1000,7 +1000,7 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
-	if (clp->cl_cb_flags)
+	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
 
 	clnt = clp->cl_cb_client;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 896da74..af2c3e8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -319,7 +319,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
 	 */
 	if (nfsd4_has_session(cstate) &&
-	    !cstate->session->se_client->cl_firststate &&
+	    !test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
+		      &cstate->session->se_client->cl_flags) &&
 	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		return nfserr_grace;
 
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 1dda803..ccd9b97 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -138,9 +138,8 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
 
-	if (clp->cl_firststate)
+	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
-	clp->cl_firststate = 1;
 	if (!rec_file)
 		return;
 	status = nfs4_save_creds(&original_cred);
@@ -283,13 +282,13 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	const struct cred *original_cred;
 	int status;
 
-	if (!rec_file || !clp->cl_firststate)
+	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
 
 	status = mnt_want_write_file(rec_file);
 	if (status)
 		goto out;
-	clp->cl_firststate = 0;
+	clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
@@ -457,10 +456,17 @@ nfs4_recoverydir(void)
 static int
 nfsd4_check_legacy_client(struct nfs4_client *clp)
 {
-	if (nfsd4_find_reclaim_client(clp) != NULL)
+	/* did we already find that this client is stable? */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return 0;
-	else
-		return -ENOENT;
+
+	/* look for it in the reclaim hashtable otherwise */
+	if (nfsd4_find_reclaim_client(clp)) {
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+		return 0;
+	}
+
+	return -ENOENT;
 }
 
 static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a5b2245..9b4cfa3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2030,7 +2030,8 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 
 	nfs4_lock_state();
 	status = nfserr_complete_already;
-	if (cstate->session->se_client->cl_firststate)
+	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
+			     &cstate->session->se_client->cl_flags))
 		goto out;
 
 	status = nfserr_stale_clientid;
@@ -2779,7 +2780,6 @@ static void
 nfs4_set_claim_prev(struct nfsd4_open *open)
 {
 	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-	open->op_openowner->oo_owner.so_client->cl_firststate = 1;
 }
 
 /* Should we give out recallable state?: */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e22f90f..fac413b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -245,14 +245,16 @@ struct nfs4_client {
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
-	u32			cl_firststate;	/* recovery dir creation */
 	u32			cl_minorversion;
 
 	/* for v4.0 and v4.1 callbacks: */
 	struct nfs4_cb_conn	cl_cb_conn;
-#define NFSD4_CLIENT_CB_UPDATE	1
-#define NFSD4_CLIENT_KILL	2
-	unsigned long		cl_cb_flags;
+#define NFSD4_CLIENT_CB_UPDATE		(0)
+#define NFSD4_CLIENT_CB_KILL		(1)
+#define NFSD4_CLIENT_STABLE		(2)	/* client on stable storage */
+#define NFSD4_CLIENT_RECLAIM_COMPLETE	(3)	/* reclaim_complete done */
+#define NFSD4_CLIENT_CB_FLAG_MASK	(0x3)
+	unsigned long		cl_flags;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
 #define NFSD4_CB_UP		0
-- 
1.7.7.6

