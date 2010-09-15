Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab0IONYN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:24:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] nfs: add a rename_setup nfs_rpc_op for async renames
Date: Wed, 15 Sep 2010 09:23:59 -0400
Message-Id: <1284557041-4375-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add a call that can set up the arguments and the response container for
an asynchronous rename call.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3proc.c       |   18 ++++++++++++++++++
 fs/nfs/nfs4proc.c       |   21 +++++++++++++++++++++
 fs/nfs/proc.c           |   12 ++++++++++++
 include/linux/nfs_xdr.h |    1 +
 4 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c5cccf1..0654177 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -439,6 +439,23 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 }
 
 static int
+nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	struct nfs_renameres *res = msg->rpc_resp;
+
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_RENAME];
+
+	res->old_fattr = nfs_alloc_fattr();
+	res->new_fattr = nfs_alloc_fattr();
+	if (res->old_fattr != NULL && res->new_fattr != NULL)
+		return 0;
+
+	nfs_free_fattr(res->old_fattr);
+	nfs_free_fattr(res->new_fattr);
+	return -ENOMEM;
+}
+
+static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
 {
@@ -842,6 +859,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.unlink_setup	= nfs3_proc_unlink_setup,
 	.unlink_done	= nfs3_proc_unlink_done,
 	.rename		= nfs3_proc_rename,
+	.rename_setup	= nfs3_proc_rename_setup,
 	.link		= nfs3_proc_link,
 	.symlink	= nfs3_proc_symlink,
 	.mkdir		= nfs3_proc_mkdir,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 120a8a6..011dc90 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2671,6 +2671,26 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	return 1;
 }
 
+static int nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	struct nfs_server *server = NFS_SERVER(dir);
+	struct nfs_renameargs *arg = msg->rpc_argp;
+	struct nfs_renameres *res = msg->rpc_resp;
+
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
+	arg->bitmask = server->attr_bitmask;
+	res->server = server;
+
+	res->old_fattr = nfs_alloc_fattr();
+	res->new_fattr = nfs_alloc_fattr();
+	if (res->old_fattr != NULL && res->new_fattr != NULL)
+		return 0;
+
+	nfs_free_fattr(res->old_fattr);
+	nfs_free_fattr(res->new_fattr);
+	return -ENOMEM;
+}
+
 static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
@@ -5443,6 +5463,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.unlink_setup	= nfs4_proc_unlink_setup,
 	.unlink_done	= nfs4_proc_unlink_done,
 	.rename		= nfs4_proc_rename,
+	.rename_setup	= nfs4_proc_rename_setup,
 	.link		= nfs4_proc_link,
 	.symlink	= nfs4_proc_symlink,
 	.mkdir		= nfs4_proc_mkdir,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 5c70b58..1b02dee 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -366,6 +366,17 @@ static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 }
 
 static int
+nfs_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	struct nfs_renameres *res = msg->rpc_resp;
+
+	msg->rpc_proc = &nfs_procedures[NFSPROC_RENAME];
+	res->old_fattr = NULL;
+	res->new_fattr = NULL;
+	return 0;
+}
+
+static int
 nfs_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
@@ -703,6 +714,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.unlink_setup	= nfs_proc_unlink_setup,
 	.unlink_done	= nfs_proc_unlink_done,
 	.rename		= nfs_proc_rename,
+	.rename_setup	= nfs_proc_rename_setup,
 	.link		= nfs_proc_link,
 	.symlink	= nfs_proc_symlink,
 	.mkdir		= nfs_proc_mkdir,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6265fa8..d470751 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1018,6 +1018,7 @@ struct nfs_rpc_ops {
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
+	int	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
 	int	(*symlink) (struct inode *, struct dentry *, struct page *,
 			    unsigned int, struct iattr *);
-- 
1.7.1

