Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30638 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755105AbZGUXaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 19:30:24 -0400
Subject: [GIT] Please pull NFS client bugfixes from linux-nfs.org
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain
Date: Tue, 21 Jul 2009 19:29:35 -0400
Message-Id: <1248218975.5034.21.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c    |   18 +++---------------
 fs/nfs/dir.c       |    2 +-
 fs/nfs/nfs4_fs.h   |    6 ++++++
 fs/nfs/nfs4proc.c  |   40 +++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4state.c |    2 +-
 5 files changed, 40 insertions(+), 28 deletions(-)

commit d953126a28f97ec965d23c69fd5795854c048f30
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 21 19:22:38 2009 -0400

    NFSv4: Fix a problem whereby a buggy server can oops the kernel
    
    We just had a case in which a buggy server occasionally returns the wrong
    attributes during an OPEN call. While the client does catch this sort of
    condition in nfs4_open_done(), and causes the nfs4_atomic_open() to return
    -EISDIR, the logic in nfs_atomic_lookup() is broken, since it causes a
    fallback to an ordinary lookup instead of just returning the error.
    
    When the buggy server then returns a regular file for the fallback lookup,
    the VFS allows the open, and bad things start to happen, since the open
    file doesn't have any associated NFSv4 state.
    
    The fix is firstly to return the EISDIR/ENOTDIR errors immediately, and
    secondly to ensure that we are always careful when dereferencing the
    nfs_open_context state pointer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fccba8045537f7e840d0e7565e1989d465e488a3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 21 16:48:07 2009 -0400

    NFSv4: Fix an NFSv4 mount regression
    
    Commit 008f55d0e019943323c20a03493a2ba5672a4cc8 (nfs41: recover lease in
    _nfs4_lookup_root) forces the state manager to always run on mount. This is
    a bug in the case of NFSv4.0, which doesn't require us to send a
    setclientid until we want to grab file state.
    
    In any case, this is completely the wrong place to be doing state
    management. Moving that code into nfs4_init_session...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b64aec8d1e1d8482a7b6cca60c8105c756bf1fe4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 21 16:47:46 2009 -0400

    NFSv4: Fix an Oops in nfs4_free_lock_state
    
    The oops http://www.kerneloops.org/raw.php?rawid=537858&msgid= appears to
    be due to the nfs4_lock_state->ls_state field being uninitialised. This
    happens if the call to nfs4_free_lock_state() is triggered at the end of
    nfs4_get_lock_state().
    
    The fix is to move the initialisation of ls_state into the allocator.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c2d0616..8d25ccb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1242,20 +1242,6 @@ error:
 	return error;
 }
 
-/*
- * Initialize a session.
- * Note: save the mount rsize and wsize for create_server negotiation.
- */
-static void nfs4_init_session(struct nfs_client *clp,
-			      unsigned int wsize, unsigned int rsize)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (nfs4_has_session(clp)) {
-		clp->cl_session->fc_attrs.max_rqst_sz = wsize;
-		clp->cl_session->fc_attrs.max_resp_sz = rsize;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-}
 
 /*
  * Session has been established, and the client marked ready.
@@ -1350,7 +1336,9 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
-	nfs4_init_session(server->nfs_client, server->wsize, server->rsize);
+	error = nfs4_init_session(server);
+	if (error < 0)
+		goto error;
 
 	/* Probe the root fh to retrieve its FSID */
 	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 38d42c2..32062c3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1025,12 +1025,12 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 				res = NULL;
 				goto out;
 			/* This turned out not to be a regular file */
-			case -EISDIR:
 			case -ENOTDIR:
 				goto no_open;
 			case -ELOOP:
 				if (!(nd->intent.open.flags & O_NOFOLLOW))
 					goto no_open;
+			/* case -EISDIR: */
 			/* case -EINVAL: */
 			default:
 				goto out;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 61bc3a3..6ea07a3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -220,6 +220,7 @@ extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *, int reset);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
+extern int nfs4_init_session(struct nfs_server *server);
 #else /* CONFIG_NFS_v4_1 */
 static inline int nfs4_setup_sequence(struct nfs_client *clp,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
@@ -227,6 +228,11 @@ static inline int nfs4_setup_sequence(struct nfs_client *clp,
 {
 	return 0;
 }
+
+static inline int nfs4_init_session(struct nfs_server *server)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern struct nfs4_state_maintenance_ops *nfs4_state_renewal_ops[];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff0c080..6917311 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2040,15 +2040,9 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	int status;
 
 	nfs_fattr_init(info->fattr);
-	status = nfs4_recover_expired_lease(server);
-	if (!status)
-		status = nfs4_check_client_ready(server->nfs_client);
-	if (!status)
-		status = nfs4_call_sync(server, &msg, &args, &res, 0);
-	return status;
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -4099,15 +4093,23 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	if (request->fl_start < 0 || request->fl_end < 0)
 		return -EINVAL;
 
-	if (IS_GETLK(cmd))
-		return nfs4_proc_getlk(state, F_GETLK, request);
+	if (IS_GETLK(cmd)) {
+		if (state != NULL)
+			return nfs4_proc_getlk(state, F_GETLK, request);
+		return 0;
+	}
 
 	if (!(IS_SETLK(cmd) || IS_SETLKW(cmd)))
 		return -EINVAL;
 
-	if (request->fl_type == F_UNLCK)
-		return nfs4_proc_unlck(state, cmd, request);
+	if (request->fl_type == F_UNLCK) {
+		if (state != NULL)
+			return nfs4_proc_unlck(state, cmd, request);
+		return 0;
+	}
 
+	if (state == NULL)
+		return -ENOLCK;
 	do {
 		status = nfs4_proc_setlk(state, cmd, request);
 		if ((status != -EAGAIN) || IS_SETLK(cmd))
@@ -4793,6 +4795,22 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	return status;
 }
 
+int nfs4_init_session(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	int ret;
+
+	if (!nfs4_has_session(clp))
+		return 0;
+
+	clp->cl_session->fc_attrs.max_rqst_sz = server->wsize;
+	clp->cl_session->fc_attrs.max_resp_sz = server->rsize;
+	ret = nfs4_recover_expired_lease(server);
+	if (!ret)
+		ret = nfs4_check_client_ready(clp);
+	return ret;
+}
+
 /*
  * Renew the cl_session lease.
  */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b73c5a7..65ca8c1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -553,6 +553,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	INIT_LIST_HEAD(&lsp->ls_sequence.list);
 	lsp->ls_seqid.sequence = &lsp->ls_sequence;
 	atomic_set(&lsp->ls_count, 1);
+	lsp->ls_state = state;
 	lsp->ls_owner = fl_owner;
 	spin_lock(&clp->cl_lock);
 	nfs_alloc_unique_id(&clp->cl_lockowner_id, &lsp->ls_id, 1, 64);
@@ -587,7 +588,6 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
 		if (lsp != NULL)
 			break;
 		if (new != NULL) {
-			new->ls_state = state;
 			list_add(&new->ls_locks, &state->lock_states);
 			set_bit(LK_STATE_IN_USE, &state->flags);
 			lsp = new;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
