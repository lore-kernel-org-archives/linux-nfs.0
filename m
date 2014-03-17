Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:42835 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbaCQLHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 07:07:11 -0400
Received: by mail-qa0-f44.google.com with SMTP id f11so5146041qae.31
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 04:07:11 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] nfs: remove synchronous rename code
Date: Mon, 17 Mar 2014 07:06:57 -0400
Message-Id: <1395054418-14504-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
References: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that nfs_rename uses the async infrastructure, we can remove this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3proc.c       | 36 ------------------------------------
 fs/nfs/nfs4proc.c       | 44 --------------------------------------------
 fs/nfs/proc.c           | 25 -------------------------
 include/linux/nfs_xdr.h |  2 --
 4 files changed, 107 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index a462ef0fb5d6..db60149c4579 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -479,41 +479,6 @@ nfs3_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 }
 
 static int
-nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
-		 struct inode *new_dir, struct qstr *new_name)
-{
-	struct nfs_renameargs	arg = {
-		.old_dir	= NFS_FH(old_dir),
-		.old_name	= old_name,
-		.new_dir	= NFS_FH(new_dir),
-		.new_name	= new_name,
-	};
-	struct nfs_renameres res;
-	struct rpc_message msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_RENAME],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
-	};
-	int status = -ENOMEM;
-
-	dprintk("NFS call  rename %s -> %s\n", old_name->name, new_name->name);
-
-	res.old_fattr = nfs_alloc_fattr();
-	res.new_fattr = nfs_alloc_fattr();
-	if (res.old_fattr == NULL || res.new_fattr == NULL)
-		goto out;
-
-	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_post_op_update_inode(old_dir, res.old_fattr);
-	nfs_post_op_update_inode(new_dir, res.new_fattr);
-out:
-	nfs_free_fattr(res.old_fattr);
-	nfs_free_fattr(res.new_fattr);
-	dprintk("NFS reply rename: %d\n", status);
-	return status;
-}
-
-static int
 nfs3_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
 	struct nfs3_linkargs	arg = {
@@ -968,7 +933,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.unlink_setup	= nfs3_proc_unlink_setup,
 	.unlink_rpc_prepare = nfs3_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs3_proc_unlink_done,
-	.rename		= nfs3_proc_rename,
 	.rename_setup	= nfs3_proc_rename_setup,
 	.rename_rpc_prepare = nfs3_proc_rename_rpc_prepare,
 	.rename_done	= nfs3_proc_rename_done,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 450bfedbe2f4..a501a5a82a42 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3507,49 +3507,6 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 	return 1;
 }
 
-static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
-		struct inode *new_dir, struct qstr *new_name)
-{
-	struct nfs_server *server = NFS_SERVER(old_dir);
-	struct nfs_renameargs arg = {
-		.old_dir = NFS_FH(old_dir),
-		.new_dir = NFS_FH(new_dir),
-		.old_name = old_name,
-		.new_name = new_name,
-	};
-	struct nfs_renameres res = {
-		.server = server,
-	};
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME],
-		.rpc_argp = &arg,
-		.rpc_resp = &res,
-	};
-	int status = -ENOMEM;
-
-	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
-	if (!status) {
-		update_changeattr(old_dir, &res.old_cinfo);
-		update_changeattr(new_dir, &res.new_cinfo);
-	}
-	return status;
-}
-
-static int nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
-		struct inode *new_dir, struct qstr *new_name)
-{
-	struct nfs4_exception exception = { };
-	int err;
-	do {
-		err = _nfs4_proc_rename(old_dir, old_name,
-					new_dir, new_name);
-		trace_nfs4_rename(old_dir, old_name, new_dir, new_name, err);
-		err = nfs4_handle_exception(NFS_SERVER(old_dir), err,
-				&exception);
-	} while (exception.retry);
-	return err;
-}
-
 static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -8408,7 +8365,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.unlink_setup	= nfs4_proc_unlink_setup,
 	.unlink_rpc_prepare = nfs4_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs4_proc_unlink_done,
-	.rename		= nfs4_proc_rename,
 	.rename_setup	= nfs4_proc_rename_setup,
 	.rename_rpc_prepare = nfs4_proc_rename_rpc_prepare,
 	.rename_done	= nfs4_proc_rename_done,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index fddbba2d9eff..e55ce9e8b034 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -357,30 +357,6 @@ nfs_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 }
 
 static int
-nfs_proc_rename(struct inode *old_dir, struct qstr *old_name,
-		struct inode *new_dir, struct qstr *new_name)
-{
-	struct nfs_renameargs	arg = {
-		.old_dir	= NFS_FH(old_dir),
-		.old_name	= old_name,
-		.new_dir	= NFS_FH(new_dir),
-		.new_name	= new_name,
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &nfs_procedures[NFSPROC_RENAME],
-		.rpc_argp	= &arg,
-	};
-	int			status;
-
-	dprintk("NFS call  rename %s -> %s\n", old_name->name, new_name->name);
-	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_mark_for_revalidate(old_dir);
-	nfs_mark_for_revalidate(new_dir);
-	dprintk("NFS reply rename: %d\n", status);
-	return status;
-}
-
-static int
 nfs_proc_link(struct inode *inode, struct inode *dir, struct qstr *name)
 {
 	struct nfs_linkargs	arg = {
@@ -745,7 +721,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.unlink_setup	= nfs_proc_unlink_setup,
 	.unlink_rpc_prepare = nfs_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs_proc_unlink_done,
-	.rename		= nfs_proc_rename,
 	.rename_setup	= nfs_proc_rename_setup,
 	.rename_rpc_prepare = nfs_proc_rename_rpc_prepare,
 	.rename_done	= nfs_proc_rename_done,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 440d7b42525a..6fb5b2335b59 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1445,8 +1445,6 @@ struct nfs_rpc_ops {
 	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
 	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
-	int	(*rename)  (struct inode *, struct qstr *,
-			    struct inode *, struct qstr *);
 	void	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
 	void	(*rename_rpc_prepare)(struct rpc_task *task, struct nfs_renamedata *);
 	int	(*rename_done) (struct rpc_task *task, struct inode *old_dir, struct inode *new_dir);
-- 
1.8.5.3

