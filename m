Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36201 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934107Ab2J3VBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 17:01:43 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFS: add nfs_sb_deactive_async to avoid deadlock
Date: Tue, 30 Oct 2012 17:01:39 -0400
Message-Id: <1351630900-6498-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use nfs_sb_deactive_async instead of nfs_sb_deactive when in a workqueue
context.  This avoids a deadlock where rpc_shutdown_client loops forever
in a workqueue kworker context, trying to kill all RPC tasks associated with
the client, while one or more of these tasks have already been assigned to the
same kworker (and will never run rpc_exit_task).

This approach is needed because RPC tasks that have already been assigned
to a kworker by queue_work cannot be canceled, as explained in the comment
for workqueue.c:insert_wq_barrier.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

This version calls kthread_run *only* when deactivate_super will result
in an umount -- the previous version could cause many unneeded kthread_runs
with certain workloads.

 fs/nfs/inode.c    |    5 ++++-
 fs/nfs/internal.h |    1 +
 fs/nfs/nfs4proc.c |    2 +-
 fs/nfs/super.c    |   45 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/unlink.c   |    2 +-
 5 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3967be2..117183b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -685,7 +685,10 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
 	dput(ctx->dentry);
-	nfs_sb_deactive(sb);
+	if (is_sync)
+		nfs_sb_deactive(sb);
+	else
+		nfs_sb_deactive_async(sb);
 	kfree(ctx->mdsthreshold);
 	kfree(ctx);
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 59b133c..12b8d69 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -351,6 +351,7 @@ extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
 extern void nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
+extern void nfs_sb_deactive_async(struct super_block *sb);
 
 /* namespace.c */
 extern char *nfs_path(char **p, struct dentry *dentry,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b04d14..33a36e0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2193,7 +2193,7 @@ static void nfs4_free_closedata(void *data)
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
-	nfs_sb_deactive(sb);
+	nfs_sb_deactive_async(sb);
 	kfree(calldata);
 }
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e831bce..c25678c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -54,6 +54,7 @@
 #include <linux/parser.h>
 #include <linux/nsproxy.h>
 #include <linux/rcupdate.h>
+#include <linux/kthread.h>
 
 #include <asm/uaccess.h>
 
@@ -415,6 +416,50 @@ void nfs_sb_deactive(struct super_block *sb)
 }
 EXPORT_SYMBOL_GPL(nfs_sb_deactive);
 
+static int nfs_deactivate_super_async_work(void *ptr)
+{
+	struct super_block *sb = ptr;
+
+	deactivate_super(sb);
+	return 0;
+}
+
+/*
+ * same effect as deactivate_super, but will do final unmount in kthread
+ * context
+ */
+static void nfs_deactivate_super_async(struct super_block *sb)
+{
+	struct task_struct *task;
+	char buf[INET6_ADDRSTRLEN + sizeof("-deactivate-super") + 1];
+	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_client *clp = server->nfs_client;
+
+	if (!atomic_add_unless(&sb->s_active, -1, 1)) {
+		rcu_read_lock();
+		snprintf(buf, sizeof(buf), "%s-deactivate-super",
+			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+		rcu_read_unlock();
+
+		task = kthread_run(nfs_deactivate_super_async_work, sb, buf);
+		if (IS_ERR(task)) {
+			pr_err("%s: kthread_run: %ld\n",
+				__func__, PTR_ERR(task));
+			/* make synchronous call and hope for the best */
+			deactivate_super(sb);
+		}
+	}
+}
+
+void nfs_sb_deactive_async(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+
+	if (atomic_dec_and_test(&server->active))
+		nfs_deactivate_super_async(sb);
+}
+EXPORT_SYMBOL_GPL(nfs_sb_deactive_async);
+
 /*
  * Deliver file system statistics to userspace
  */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 13cea63..3f79c77 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -95,7 +95,7 @@ static void nfs_async_unlink_release(void *calldata)
 
 	nfs_dec_sillycount(data->dir);
 	nfs_free_unlinkdata(data);
-	nfs_sb_deactive(sb);
+	nfs_sb_deactive_async(sb);
 }
 
 static void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
-- 
1.7.9.6 (Apple Git-31.1)

