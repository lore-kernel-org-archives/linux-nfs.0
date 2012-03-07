Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38808 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759852Ab2CGTWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 14:22:54 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Don't free the nfs4_lock_state until after the release_lockowner
Date: Wed,  7 Mar 2012 14:22:33 -0500
Message-Id: <1331148153-13792-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise we can end up with sequence id problems if the client reuses
the owner_id before the server has processed the release_lockowner

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    4 +++-
 fs/nfs/nfs4proc.c  |   31 ++++++++++++++++++++-----------
 fs/nfs/nfs4state.c |    8 +++++---
 3 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 16373df..026878c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -213,7 +213,7 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
-extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
+extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
 #if defined(CONFIG_NFS_V4_1)
@@ -338,6 +338,8 @@ extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
 extern void nfs_release_seqid(struct nfs_seqid *seqid);
 extern void nfs_free_seqid(struct nfs_seqid *seqid);
 
+extern void nfs4_free_lock_state(struct nfs4_lock_state *lsp);
+
 extern const nfs4_stateid zero_stateid;
 
 /* nfs4xdr.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ec0522..32e0d08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4745,8 +4745,15 @@ out:
 	return err;
 }
 
+struct nfs_release_lockowner_data {
+	struct nfs4_lock_state *lsp;
+	struct nfs_release_lockowner_args args;
+};
+
 static void nfs4_release_lockowner_release(void *calldata)
 {
+	struct nfs_release_lockowner_data *data = calldata;
+	nfs4_free_lock_state(data->lsp);
 	kfree(calldata);
 }
 
@@ -4754,24 +4761,26 @@ const struct rpc_call_ops nfs4_release_lockowner_ops = {
 	.rpc_release = nfs4_release_lockowner_release,
 };
 
-void nfs4_release_lockowner(const struct nfs4_lock_state *lsp)
+int nfs4_release_lockowner(struct nfs4_lock_state *lsp)
 {
 	struct nfs_server *server = lsp->ls_state->owner->so_server;
-	struct nfs_release_lockowner_args *args;
+	struct nfs_release_lockowner_data *data;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RELEASE_LOCKOWNER],
 	};
 
 	if (server->nfs_client->cl_mvops->minor_version != 0)
-		return;
-	args = kmalloc(sizeof(*args), GFP_NOFS);
-	if (!args)
-		return;
-	args->lock_owner.clientid = server->nfs_client->cl_clientid;
-	args->lock_owner.id = lsp->ls_seqid.owner_id;
-	args->lock_owner.s_dev = server->s_dev;
-	msg.rpc_argp = args;
-	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, args);
+		return -EINVAL;
+	data = kmalloc(sizeof(*data), GFP_NOFS);
+	if (!data)
+		return -ENOMEM;
+	data->lsp = lsp;
+	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
+	data->args.lock_owner.id = lsp->ls_seqid.owner_id;
+	data->args.lock_owner.s_dev = server->s_dev;
+	msg.rpc_argp = &data->args;
+	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
+	return 0;
 }
 
 #define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a58d02a..7adc46b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -784,7 +784,7 @@ out_free:
 	return NULL;
 }
 
-static void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
+void nfs4_free_lock_state(struct nfs4_lock_state *lsp)
 {
 	struct nfs_server *server = lsp->ls_state->owner->so_server;
 
@@ -842,8 +842,10 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
-	if (lsp->ls_flags & NFS_LOCK_INITIALIZED)
-		nfs4_release_lockowner(lsp);
+	if (lsp->ls_flags & NFS_LOCK_INITIALIZED) {
+		if (nfs4_release_lockowner(lsp) == 0)
+			return;
+	}
 	nfs4_free_lock_state(lsp);
 }
 
-- 
1.7.7.6

