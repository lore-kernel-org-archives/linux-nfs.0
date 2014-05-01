Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:33493 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaEAK26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 06:28:58 -0400
Received: by mail-qc0-f178.google.com with SMTP id i8so3123450qcq.37
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 03:28:57 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] nfs4: turn free_lock_state into a void return operation
Date: Thu,  1 May 2014 06:28:47 -0400
Message-Id: <1398940127-31150-4-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
References: <1398940127-31150-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nothing checks its return value.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 fs/nfs/nfs4_fs.h  |  2 +-
 fs/nfs/nfs4proc.c | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 75aadf8c0429..f495ff306c4f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -54,7 +54,7 @@ struct nfs4_minor_version_ops {
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
 			struct nfs_fsinfo *);
-	int	(*free_lock_state)(struct nfs_server *,
+	void	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
 	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cc6c3fe3e060..06c1e9e777ab 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5915,7 +5915,8 @@ static const struct rpc_call_ops nfs4_release_lockowner_ops = {
 	.rpc_release = nfs4_release_lockowner_release,
 };
 
-static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
+static void
+nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
 	struct nfs_release_lockowner_data *data;
 	struct rpc_message msg = {
@@ -5923,11 +5924,11 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 	};
 
 	if (server->nfs_client->cl_mvops->minor_version != 0)
-		return -EINVAL;
+		return;
 
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
-		return -ENOMEM;
+		return;
 	data->lsp = lsp;
 	data->server = server;
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
@@ -5938,7 +5939,6 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 	msg.rpc_resp = &data->res;
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
-	return 0;
 }
 
 #define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
@@ -8225,7 +8225,8 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	return ret;
 }
 
-static int nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
+static void
+nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
 	struct rpc_task *task;
 	struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
@@ -8233,9 +8234,8 @@ static int nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_sta
 	task = _nfs41_free_stateid(server, &lsp->ls_stateid, cred, false);
 	nfs4_free_lock_state(server, lsp);
 	if (IS_ERR(task))
-		return PTR_ERR(task);
+		return;
 	rpc_put_task(task);
-	return 0;
 }
 
 static bool nfs41_match_stateid(const nfs4_stateid *s1,
-- 
1.9.0

