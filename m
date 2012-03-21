Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42978 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2CUNwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:15 -0400
Received: by mail-gy0-f174.google.com with SMTP id r11so920975ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:15 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 1/8] nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
Date: Wed, 21 Mar 2012 09:52:02 -0400
Message-Id: <1332337929-18580-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
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
and add a new NFSD4_CLIENT_RECLAIM_COMPLETE flag.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c |   14 +++++++-------
 fs/nfsd/nfs4proc.c     |    3 ++-
 fs/nfsd/nfs4recover.c  |    7 +++----
 fs/nfsd/nfs4state.c    |   45 ++++++++++++++++++++++++++++-----------------
 fs/nfsd/state.h        |   11 +++++++----
 5 files changed, 47 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0e262f3..a09dcc4 100644
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
index 0b3e875..6523809 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -126,9 +126,8 @@ void nfsd4_create_clid_dir(struct nfs4_client *clp)
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
 
-	if (clp->cl_firststate)
+	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
-	clp->cl_firststate = 1;
 	if (!rec_file)
 		return;
 	status = nfs4_save_creds(&original_cred);
@@ -271,13 +270,13 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
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
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8b20707..534f82f1 100644
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
@@ -2779,12 +2780,6 @@ static void
 nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
 {
 	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-	/*
-	 * On a 4.1+ client, we don't create a state record for a client
-	 * until it performs RECLAIM_COMPLETE:
-	 */
-	if (!has_session)
-		open->op_openowner->oo_owner.so_client->cl_firststate = 1;
 }
 
 /* Should we give out recallable state?: */
@@ -4360,7 +4355,7 @@ nfs4_has_reclaimed_state(const char *name, bool use_exchange_id)
 	clp = find_confirmed_client_by_str(name, strhashval);
 	if (!clp)
 		return 0;
-	return clp->cl_firststate;
+	return test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 }
 
 /*
@@ -4405,18 +4400,11 @@ nfs4_release_reclaim(void)
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
 static struct nfs4_client_reclaim *
-nfs4_find_reclaim_client(clientid_t *clid)
+nfsd4_find_reclaim_client(struct nfs4_client *clp)
 {
 	unsigned int strhashval;
-	struct nfs4_client *clp;
 	struct nfs4_client_reclaim *crp = NULL;
 
-
-	/* find clientid in conf_id_hashtbl */
-	clp = find_confirmed_client(clid);
-	if (clp == NULL)
-		return NULL;
-
 	dprintk("NFSD: nfs4_find_reclaim_client for %.*s with recdir %s\n",
 		            clp->cl_name.len, clp->cl_name.data,
 			    clp->cl_recdir);
@@ -4431,13 +4419,36 @@ nfs4_find_reclaim_client(clientid_t *clid)
 	return NULL;
 }
 
+static int
+nfsd4_client_record_check(struct nfs4_client *clp)
+{
+	/* did we already find that this client is stable? */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return 0;
+
+	/* look for it in the reclaim hashtable otherwise */
+	if (nfsd4_find_reclaim_client(clp)) {
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
 /*
 * Called from OPEN. Look for clientid in reclaim list.
 */
 __be32
 nfs4_check_open_reclaim(clientid_t *clid)
 {
-	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
+	struct nfs4_client *clp;
+
+	/* find clientid in conf_id_hashtbl */
+	clp = find_confirmed_client(clid);
+	if (clp == NULL)
+		return nfserr_reclaim_bad;
+
+	return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
 }
 
 #ifdef CONFIG_NFSD_FAULT_INJECTION
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ffb5df1..b9c036d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -245,14 +245,17 @@ struct nfs4_client {
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
+#define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
+					 1 << NFSD4_CLIENT_CB_KILL)
+	unsigned long		cl_flags;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
 #define NFSD4_CB_UP		0
-- 
1.7.7.6

