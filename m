Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759252Ab2CSSyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:54:46 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/4] NFS: Remove nfs4_setup_sequence from generic unlink code
Date: Mon, 19 Mar 2012 14:54:41 -0400
Message-Id: <1332183282-9743-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
References: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is an NFS v4 specific operation, so it belongs in the NFS v4 code
and not the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs3proc.c       |    6 ++++++
 fs/nfs/nfs4proc.c       |   11 +++++++++++
 fs/nfs/proc.c           |    6 ++++++
 fs/nfs/unlink.c         |   20 +-------------------
 include/linux/nfs_xdr.h |   10 ++++++++++
 5 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 9d9b239..7f3f957 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -428,6 +428,11 @@ nfs3_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
 }
 
+static void nfs3_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
+{
+	rpc_call_start(task);
+}
+
 static int
 nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
@@ -874,6 +879,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.create		= nfs3_proc_create,
 	.remove		= nfs3_proc_remove,
 	.unlink_setup	= nfs3_proc_unlink_setup,
+	.unlink_rpc_prepare = nfs3_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs3_proc_unlink_done,
 	.rename		= nfs3_proc_rename,
 	.rename_setup	= nfs3_proc_rename_setup,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0845733..918af9c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2779,6 +2779,16 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
 }
 
+static void nfs4_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
+{
+	if (nfs4_setup_sequence(NFS_SERVER(data->dir),
+				&data->args.seq_args,
+				&data->res.seq_res,
+				task))
+		return;
+	rpc_call_start(task);
+}
+
 static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
@@ -6449,6 +6459,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.create		= nfs4_proc_create,
 	.remove		= nfs4_proc_remove,
 	.unlink_setup	= nfs4_proc_unlink_setup,
+	.unlink_rpc_prepare = nfs4_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs4_proc_unlink_done,
 	.rename		= nfs4_proc_rename,
 	.rename_setup	= nfs4_proc_rename_setup,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index a8df707..528b9a2 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -358,6 +358,11 @@ nfs_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
 }
 
+static void nfs_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
+{
+	rpc_call_start(task);
+}
+
 static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	if (nfs_async_handle_expired_key(task))
@@ -731,6 +736,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.create		= nfs_proc_create,
 	.remove		= nfs_proc_remove,
 	.unlink_setup	= nfs_proc_unlink_setup,
+	.unlink_rpc_prepare = nfs_proc_unlink_rpc_prepare,
 	.unlink_done	= nfs_proc_unlink_done,
 	.rename		= nfs_proc_rename,
 	.rename_setup	= nfs_proc_rename_setup,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index fae71c9..9c5a798 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -20,15 +20,6 @@
 #include "iostat.h"
 #include "delegation.h"
 
-struct nfs_unlinkdata {
-	struct hlist_node list;
-	struct nfs_removeargs args;
-	struct nfs_removeres res;
-	struct inode *dir;
-	struct rpc_cred	*cred;
-	struct nfs_fattr dir_attr;
-};
-
 /**
  * nfs_free_unlinkdata - release data from a sillydelete operation.
  * @data: pointer to unlink structure.
@@ -107,25 +98,16 @@ static void nfs_async_unlink_release(void *calldata)
 	nfs_sb_deactive(sb);
 }
 
-#if defined(CONFIG_NFS_V4_1)
 static void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_unlinkdata *data = calldata;
-	struct nfs_server *server = NFS_SERVER(data->dir);
-
-	if (nfs4_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, task))
-		return;
-	rpc_call_start(task);
+	NFS_PROTO(data->dir)->unlink_rpc_prepare(task, data);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_call_done = nfs_async_unlink_done,
 	.rpc_release = nfs_async_unlink_release,
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_unlink_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 };
 
 static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 286d74d..8d93e68 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1192,6 +1192,15 @@ struct nfs_write_data {
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
+struct nfs_unlinkdata {
+	struct hlist_node list;
+	struct nfs_removeargs args;
+	struct nfs_removeres res;
+	struct inode *dir;
+	struct rpc_cred	*cred;
+	struct nfs_fattr dir_attr;
+};
+
 struct nfs_access_entry;
 struct nfs_client;
 struct rpc_timeout;
@@ -1221,6 +1230,7 @@ struct nfs_rpc_ops {
 			    struct iattr *, int, struct nfs_open_context *);
 	int	(*remove)  (struct inode *, struct qstr *);
 	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
+	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
-- 
1.7.9.4

