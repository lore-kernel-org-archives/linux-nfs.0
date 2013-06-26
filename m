Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44127 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab3FZQV6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 12:21:58 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] NFSv4.1 Refactor nfs4_init_session and nfs4_init_channel_attrs
Date: Wed, 26 Jun 2013 12:21:49 -0400
Message-Id: <1372263709-2257-2-git-send-email-andros@netapp.com>
In-Reply-To: <1372263709-2257-1-git-send-email-andros@netapp.com>
References: <1372263709-2257-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_init_session was originally written to be called prior to
nfs4_init_channel_attrs, setting the session target_max response and request
sizes that nfs4_init_channel_attrs would pay attention to.

In the current code flow, nfs4_init_session, just like nfs4_init_ds_session
for the data server case, is called after the session is all negotiated, and
is actually used in a RECLAIM COMPLETE call to the server.

Remove the un-needed fc_target_max response and request fields from
nfs4_session and just set the max_resp_sz and max_rqst_sz in
nfs4_init_channel_attrs.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c  |  2 +-
 fs/nfs/nfs4proc.c    | 17 +++++++----------
 fs/nfs/nfs4session.c | 41 +++--------------------------------------
 fs/nfs/nfs4session.h |  7 ++-----
 4 files changed, 13 insertions(+), 54 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c22565b..3432a6f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -735,7 +735,7 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 		return -ENOMEM;
 
 	/* We must ensure the session is initialised first */
-	error = nfs4_init_session(server);
+	error = nfs4_init_session(server->nfs_client);
 	if (error < 0)
 		goto out;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e40876..d95616f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6184,17 +6184,14 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
  */
 static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 {
-	struct nfs4_session *session = args->client->cl_session;
-	unsigned int mxrqst_sz = session->fc_target_max_rqst_sz,
-		     mxresp_sz = session->fc_target_max_resp_sz;
-
-	if (mxrqst_sz == 0)
-		mxrqst_sz = NFS_MAX_FILE_IO_SIZE;
-	if (mxresp_sz == 0)
-		mxresp_sz = NFS_MAX_FILE_IO_SIZE;
+	unsigned int max_rqst_sz, max_resp_sz;
+
+	max_rqst_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxwrite_overhead;
+	max_resp_sz = NFS_MAX_FILE_IO_SIZE + nfs41_maxread_overhead;
+
 	/* Fore channel attributes */
-	args->fc_attrs.max_rqst_sz = mxrqst_sz;
-	args->fc_attrs.max_resp_sz = mxresp_sz;
+	args->fc_attrs.max_rqst_sz = max_rqst_sz;
+	args->fc_attrs.max_resp_sz = max_resp_sz;
 	args->fc_attrs.max_ops = NFS4_MAX_OPS;
 	args->fc_attrs.max_reqs = max_session_slots;
 
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index c4e225e..088ad51 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -478,48 +478,13 @@ static int nfs41_check_session_ready(struct nfs_client *clp)
 	return 0;
 }
 
-int nfs4_init_session(struct nfs_server *server)
+int nfs4_init_session(struct nfs_client *clp)
 {
-	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_session *session;
-	unsigned int target_max_rqst_sz = NFS_MAX_FILE_IO_SIZE;
-	unsigned int target_max_resp_sz = NFS_MAX_FILE_IO_SIZE;
-
 	if (!nfs4_has_session(clp))
 		return 0;
 
-	if (server->rsize != 0)
-		target_max_resp_sz = server->rsize;
-	target_max_resp_sz += nfs41_maxread_overhead;
-
-	if (server->wsize != 0)
-		target_max_rqst_sz = server->wsize;
-	target_max_rqst_sz += nfs41_maxwrite_overhead;
-
-	session = clp->cl_session;
-	spin_lock(&clp->cl_lock);
-	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
-		/* Initialise targets and channel attributes */
-		session->fc_target_max_rqst_sz = target_max_rqst_sz;
-		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
-		session->fc_target_max_resp_sz = target_max_resp_sz;
-		session->fc_attrs.max_resp_sz = target_max_resp_sz;
-	} else {
-		/* Just adjust the targets */
-		if (target_max_rqst_sz > session->fc_target_max_rqst_sz) {
-			session->fc_target_max_rqst_sz = target_max_rqst_sz;
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-		}
-		if (target_max_resp_sz > session->fc_target_max_resp_sz) {
-			session->fc_target_max_resp_sz = target_max_resp_sz;
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-		}
-	}
-	spin_unlock(&clp->cl_lock);
-
-	if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
-		nfs4_schedule_lease_recovery(clp);
-
+	test_and_clear_bit(NFS4_SESSION_INITING,
+			   &clp->cl_session->session_state);
 	return nfs41_check_session_ready(clp);
 }
 
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index ff7d9f0..3a153d8 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -66,9 +66,6 @@ struct nfs4_session {
 	struct nfs4_channel_attrs	bc_attrs;
 	struct nfs4_slot_table		bc_slot_table;
 	struct nfs_client		*clp;
-	/* Create session arguments */
-	unsigned int			fc_target_max_rqst_sz;
-	unsigned int			fc_target_max_resp_sz;
 };
 
 enum nfs4_session_state {
@@ -89,7 +86,7 @@ extern int nfs4_setup_session_slot_tables(struct nfs4_session *ses);
 
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern void nfs4_destroy_session(struct nfs4_session *session);
-extern int nfs4_init_session(struct nfs_server *server);
+extern int nfs4_init_session(struct nfs_client *clp);
 extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
 
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
@@ -122,7 +119,7 @@ static inline int nfs4_has_persistent_session(const struct nfs_client *clp)
 
 #else /* defined(CONFIG_NFS_V4_1) */
 
-static inline int nfs4_init_session(struct nfs_server *server)
+static inline int nfs4_init_session(struct nfs_client *clp)
 {
 	return 0;
 }
-- 
1.7.11.7

