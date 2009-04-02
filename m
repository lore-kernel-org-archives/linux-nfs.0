From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 53/67] nfs41: add session setup to the state manager
Date: Thu,  2 Apr 2009 16:58:19 +0300
Message-ID: <1238680699-15059-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2014 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756386AbZDBN6i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:58:38 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

At mount, nfs_alloc_client sets the cl_state NFS4CLNT_LEASE_EXPIRED bit
and nfs4_alloc_session sets the NFS4CLNT_SESSION_SETUP bit, so both bits are
set when nfs4_lookup_root calls nfs4_recover_expired_lease which schedules
the nfs4_state_manager and waits for it to complete.

Place the session setup after the clientid establishment in nfs4_state_manager
so that the session is setup right after the clientid has been established
without rescheduling the state manager.

Unlike nfsv4.0, the nfs_client struct is not ready to use until the session
has been established.  Postpone marking the nfs_client struct to NFS_CS_READY
until after a successful CREATE_SESSION call so that other threads cannot use
the client until the session is established.

If the EXCHANGE_ID call fails and the session has not been setup (the
NFS4CLNT_SESSION_SETUP bit is set), mark the client with the error and return.

If the session setup CREATE_SESSION call fails with NFS4ERR_STALE_CLIENTID
which could occur due to server reboot or network partition inbetween the
EXCHANGE_ID and CREATE_SESSION call, reset the NFS4CLNT_LEASE_EXPIRED and
NFS4CLNT_SESSION_SETUP bits and try again.

If the CREATE_SESSION call fails with other errors, mark the client with
the error and return.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[nfs41: NFS_CS_SESSION_SETUP cl_cons_state for back channel setup]
  On session setup, the CREATE_SESSION reply races with the server back channel
  probe which needs to succeed to setup the back channel. Set a new
  cl_cons_state NFS_CS_SESSION_SETUP just prior to the CREATE_SESSION call
  and add it as a valid state to nfs_find_client so that the client back channel
  can find the nfs_client struct and won't drop the server backchannel probe.
  Use a new cl_cons_state so that NFSv4.0 back channel behaviour which only
  sets NFS_CS_READY is unchanged.
  Adjust waiting on the nfs_client_active_wq accordingly.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[nfs41: rename NFS_CS_SESSION_SETUP to NFS_CS_SESSION_INITING]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: set NFS_CL_SESSION_INITING in alloc_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: move session setup into a function]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[moved nfs4_proc_create_session declaration here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |   10 ++++++----
 fs/nfs/internal.h         |    1 +
 fs/nfs/nfs4_fs.h          |    2 ++
 fs/nfs/nfs4proc.c         |   10 ++++++++++
 fs/nfs/nfs4state.c        |   35 ++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    1 +
 6 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index fda2c53..8a3aa9a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -366,7 +366,8 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 
 		/* Don't match clients that failed to initialise properly */
-		if (clp->cl_cons_state != NFS_CS_READY)
+		if (!(clp->cl_cons_state == NFS_CS_READY ||
+		      clp->cl_cons_state == NFS_CS_SESSION_INITING))
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
@@ -499,7 +500,7 @@ found_client:
 		nfs_free_client(new);
 
 	error = wait_event_killable(nfs_client_active_wq,
-				clp->cl_cons_state != NFS_CS_INITING);
+				clp->cl_cons_state < NFS_CS_INITING);
 	if (error < 0) {
 		nfs_put_client(clp);
 		return ERR_PTR(-ERESTARTSYS);
@@ -520,7 +521,7 @@ found_client:
 /*
  * Mark a server as ready or failed
  */
-static void nfs_mark_client_ready(struct nfs_client *clp, int state)
+void nfs_mark_client_ready(struct nfs_client *clp, int state)
 {
 	clp->cl_cons_state = state;
 	wake_up_all(&nfs_client_active_wq);
@@ -1150,7 +1151,8 @@ static int nfs4_init_client(struct nfs_client *clp,
 	if (error < 0)
 		goto error;
 
-	nfs_mark_client_ready(clp, NFS_CS_READY);
+	if (!nfs4_has_session(clp))
+		nfs_mark_client_ready(clp, NFS_CS_READY);
 	return 0;
 
 error:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f62bc52..f3b310e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -100,6 +100,7 @@ extern void nfs_free_server(struct nfs_server *server);
 extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
 					   struct nfs_fattr *);
+extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c2ef040..f9195d7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,6 +44,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
+	NFS4CLNT_SESSION_SETUP,
 };
 
 /*
@@ -208,6 +209,7 @@ extern int nfs4_setup_sequence(struct nfs_client *clp,
 		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+extern int nfs4_proc_create_session(struct nfs_client *, int reset);
 #else /* CONFIG_NFS_v4_1 */
 static inline int nfs4_setup_sequence(struct nfs_client *clp,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ba68d43..8e185eb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4385,6 +4385,16 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	session = kzalloc(sizeof(struct nfs4_session), GFP_KERNEL);
 	if (!session)
 		return NULL;
+
+	set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+	/*
+	 * The create session reply races with the server back
+	 * channel probe. Mark the client NFS_CS_SESSION_INITING
+	 * so that the client back channel can find the
+	 * nfs_client struct
+	 */
+	clp->cl_cons_state = NFS_CS_SESSION_INITING;
+
 	tbl = &session->fc_slot_table;
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "Slot table");
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bc683ed..df5b480 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1113,6 +1113,27 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	return status;
 }
 
+#ifdef CONFIG_NFS_V4_1
+
+static int nfs4_initialize_session(struct nfs_client *clp)
+{
+	int status;
+
+	status = nfs4_proc_create_session(clp, 0);
+	if (!status) {
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+	} else if (status == -NFS4ERR_STALE_CLIENTID) {
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+	} else {
+		nfs_mark_client_ready(clp, status);
+	}
+	return status;
+}
+#else /* CONFIG_NFS_V4_1 */
+static int nfs4_initialize_session(struct nfs_client *clp) { return 0; }
+#endif /* CONFIG_NFS_V4_1 */
+
 static void nfs4_state_manager(struct nfs_client *clp)
 {
 	int status = 0;
@@ -1126,6 +1147,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 				if (status == -EAGAIN)
 					continue;
+				if (clp->cl_cons_state ==
+							NFS_CS_SESSION_INITING)
+					nfs_mark_client_ready(clp, status);
 				goto out_error;
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
@@ -1136,7 +1160,16 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			if (status != 0)
 				continue;
 		}
-
+		/* Setup the session */
+		if (nfs4_has_session(clp) &&
+		   test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
+			status = nfs4_initialize_session(clp);
+			if (status) {
+				if (status == -NFS4ERR_STALE_CLIENTID)
+					continue;
+				goto out_error;
+			}
+		}
 		/* First recover reboot state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 876e5ff..bc90ad8 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -24,6 +24,7 @@ struct nfs_client {
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
 #define NFS_CS_INITING		1		/* busy initialising */
+#define NFS_CS_SESSION_INITING	2		/* busy initialising  session */
 	unsigned long		cl_res_state;	/* NFS resources state */
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */
-- 
1.6.2.1

