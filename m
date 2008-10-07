From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/30] NFS: Clean up nfs_sb_active/nfs_sb_deactive
Date: Tue, 07 Oct 2008 18:19:52 -0400
Message-ID: <20081007221952.20945.20813.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755948AbYJGWcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:52 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkw6026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:48 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of causing umount requests to block on server->active_wq while the
asynchronous sillyrename deletes are executing, we can use the sb->s_active
counter to obtain a reference to the super_block, and then release that
reference in nfs_async_unlink_release().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    1 -
 fs/nfs/internal.h         |    4 ++--
 fs/nfs/super.c            |   24 ++++++++----------------
 fs/nfs/unlink.c           |    5 +++--
 include/linux/nfs_fs_sb.h |    1 -
 5 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5ee23e7..2accb67 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -850,7 +850,6 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);
 
-	init_waitqueue_head(&server->active_wq);
 	atomic_set(&server->active, 0);
 
 	server->io_stats = nfs_alloc_iostats();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 24241fc..7bcf6ec 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -163,8 +163,8 @@ extern struct rpc_stat nfs_rpcstat;
 
 extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
-extern void nfs_sb_active(struct nfs_server *server);
-extern void nfs_sb_deactive(struct nfs_server *server);
+extern void nfs_sb_active(struct super_block *sb);
+extern void nfs_sb_deactive(struct super_block *sb);
 
 /* namespace.c */
 extern char *nfs_path(const char *base,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e9b2017..e527fab 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -209,7 +209,6 @@ static int nfs_get_sb(struct file_system_type *, int, const char *, void *, stru
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
-static void nfs_put_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 static struct file_system_type nfs_fs_type = {
@@ -232,7 +231,6 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
-	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -337,26 +335,20 @@ void __exit unregister_nfs_fs(void)
 	unregister_filesystem(&nfs_fs_type);
 }
 
-void nfs_sb_active(struct nfs_server *server)
+void nfs_sb_active(struct super_block *sb)
 {
-	atomic_inc(&server->active);
-}
+	struct nfs_server *server = NFS_SB(sb);
 
-void nfs_sb_deactive(struct nfs_server *server)
-{
-	if (atomic_dec_and_test(&server->active))
-		wake_up(&server->active_wq);
+	if (atomic_inc_return(&server->active) == 1)
+		atomic_inc(&sb->s_active);
 }
 
-static void nfs_put_super(struct super_block *sb)
+void nfs_sb_deactive(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
-	/*
-	 * Make sure there are no outstanding ops to this server.
-	 * If so, wait for them to finish before allowing the
-	 * unmount to continue.
-	 */
-	wait_event(server->active_wq, atomic_read(&server->active) == 0);
+
+	if (atomic_dec_and_test(&server->active))
+		deactivate_super(sb);
 }
 
 /*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index f089e58..ecc2953 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -99,7 +99,7 @@ static void nfs_async_unlink_release(void *calldata)
 
 	nfs_dec_sillycount(data->dir);
 	nfs_free_unlinkdata(data);
-	nfs_sb_deactive(NFS_SB(sb));
+	nfs_sb_deactive(sb);
 }
 
 static const struct rpc_call_ops nfs_unlink_ops = {
@@ -118,6 +118,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		.rpc_message = &msg,
 		.callback_ops = &nfs_unlink_ops,
 		.callback_data = data,
+		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct rpc_task *task;
@@ -149,7 +150,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		nfs_dec_sillycount(dir);
 		return 0;
 	}
-	nfs_sb_active(NFS_SERVER(dir));
+	nfs_sb_active(dir->i_sb);
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c9beacd..4e477ae 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -119,7 +119,6 @@ struct nfs_server {
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */
-	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
 
 	/* mountd-related mount options */
 	struct sockaddr_storage	mountd_address;

