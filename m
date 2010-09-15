Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab0IONYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:24:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] nfs: add rename_done nfs_rpc_op
Date: Wed, 15 Sep 2010 09:24:00 -0400
Message-Id: <1284557041-4375-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...for processing the rename reply.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3proc.c       |   16 ++++++++++++++++
 fs/nfs/nfs4proc.c       |   18 ++++++++++++++++++
 fs/nfs/proc.c           |   12 ++++++++++++
 include/linux/nfs_xdr.h |    1 +
 4 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0654177..b072519 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -456,6 +456,21 @@ nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 }
 
 static int
+nfs3_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+		      struct inode *new_dir)
+{
+	struct nfs_renameres *res;
+
+	if (nfs3_async_handle_jukebox(task, old_dir))
+		return 0;
+	res = task->tk_msg.rpc_resp;
+
+	nfs_post_op_update_inode(old_dir, res->old_fattr);
+	nfs_post_op_update_inode(new_dir, res->new_fattr);
+	return 1;
+}
+
+static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
 {
@@ -860,6 +875,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.unlink_done	= nfs3_proc_unlink_done,
 	.rename		= nfs3_proc_rename,
 	.rename_setup	= nfs3_proc_rename_setup,
+	.rename_done	= nfs3_proc_rename_done,
 	.link		= nfs3_proc_link,
 	.symlink	= nfs3_proc_symlink,
 	.mkdir		= nfs3_proc_mkdir,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 011dc90..9c4160c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2691,6 +2691,23 @@ static int nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	return -ENOMEM;
 }
 
+static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+				 struct inode *new_dir)
+{
+	struct nfs_renameres *res = task->tk_msg.rpc_resp;
+
+	if (!nfs4_sequence_done(task, &res->seq_res))
+		return 0;
+	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+		return 0;
+
+	update_changeattr(old_dir, &res->old_cinfo);
+	nfs_post_op_update_inode(old_dir, res->old_fattr);
+	update_changeattr(new_dir, &res->new_cinfo);
+	nfs_post_op_update_inode(new_dir, res->new_fattr);
+	return 1;
+}
+
 static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
@@ -5464,6 +5481,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.unlink_done	= nfs4_proc_unlink_done,
 	.rename		= nfs4_proc_rename,
 	.rename_setup	= nfs4_proc_rename_setup,
+	.rename_done	= nfs4_proc_rename_done,
 	.link		= nfs4_proc_link,
 	.symlink	= nfs4_proc_symlink,
 	.mkdir		= nfs4_proc_mkdir,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 1b02dee..e2d5cae 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -377,6 +377,17 @@ nfs_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 }
 
 static int
+nfs_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+		     struct inode *new_dir)
+{
+	if (nfs_async_handle_expired_key(task))
+		return 0;
+	nfs_mark_for_revalidate(old_dir);
+	nfs_mark_for_revalidate(new_dir);
+	return 1;
+}
+
+static int
 nfs_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
@@ -715,6 +726,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.unlink_done	= nfs_proc_unlink_done,
 	.rename		= nfs_proc_rename,
 	.rename_setup	= nfs_proc_rename_setup,
+	.rename_done	= nfs_proc_rename_done,
 	.link		= nfs_proc_link,
 	.symlink	= nfs_proc_symlink,
 	.mkdir		= nfs_proc_mkdir,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d470751..97f7eaa 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1019,6 +1019,7 @@ struct nfs_rpc_ops {
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
+	int	(*rename_done) (struct rpc_task *task, struct inode *old_dir, struct inode *new_dir);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
 	int	(*symlink) (struct inode *, struct dentry *, struct page *,
 			    unsigned int, struct iattr *);
-- 
1.7.1

