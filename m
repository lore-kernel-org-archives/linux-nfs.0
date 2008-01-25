From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 004/112] NFS: Stop sillyname renames and unmounts from
	racing
Date: Fri, 25 Jan 2008 11:37:24 -0500
Message-ID: <20080125163724.31887.98509.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756764AbYAYRAa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:30 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmk010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:28 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <SteveD@redhat.com>

Added an active/deactive mechanism to the nfs_server structure
allowing async operations to hold off umount until the
operations are done.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    3 +++
 fs/nfs/internal.h         |    2 ++
 fs/nfs/super.c            |   24 ++++++++++++++++++++++++
 fs/nfs/unlink.c           |    4 ++++
 include/linux/nfs_fs_sb.h |    6 ++++++
 5 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a6f6254..c3740f5 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -729,6 +729,9 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);
 
+	init_waitqueue_head(&server->active_wq);
+	atomic_set(&server->active, 0);
+
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
 		kfree(server);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f3acf48..7579379 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -160,6 +160,8 @@ extern struct rpc_stat nfs_rpcstat;
 
 extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
+extern void nfs_sb_active(struct nfs_server *server);
+extern void nfs_sb_deactive(struct nfs_server *server);
 
 /* namespace.c */
 extern char *nfs_path(const char *base,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0b0c72a..fda1635 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -202,6 +202,7 @@ static int nfs_get_sb(struct file_system_type *, int, const char *, void *, stru
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
+static void nfs_put_super(struct super_block *);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -223,6 +224,7 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -325,6 +327,28 @@ void __exit unregister_nfs_fs(void)
 	unregister_filesystem(&nfs_fs_type);
 }
 
+void nfs_sb_active(struct nfs_server *server)
+{
+	atomic_inc(&server->active);
+}
+
+void nfs_sb_deactive(struct nfs_server *server)
+{
+	if (atomic_dec_and_test(&server->active))
+		wake_up(&server->active_wq);
+}
+
+static void nfs_put_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	/*
+	 * Make sure there are no outstanding ops to this server.
+	 * If so, wait for them to finish before allowing the
+	 * unmount to continue.
+	 */
+	wait_event(server->active_wq, atomic_read(&server->active) == 0);
+}
+
 /*
  * Deliver file system statistics to userspace
  */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 233ad38..c90862a 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -14,6 +14,8 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 
+#include "internal.h"
+
 struct nfs_unlinkdata {
 	struct hlist_node list;
 	struct nfs_removeargs args;
@@ -113,6 +115,7 @@ static void nfs_async_unlink_release(void *calldata)
 	struct nfs_unlinkdata	*data = calldata;
 
 	nfs_dec_sillycount(data->dir);
+	nfs_sb_deactive(NFS_SERVER(data->dir));
 	nfs_free_unlinkdata(data);
 }
 
@@ -151,6 +154,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		nfs_dec_sillycount(dir);
 		return 0;
 	}
+	nfs_sb_active(NFS_SERVER(dir));
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0cac49b..9f949b5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -3,6 +3,9 @@
 
 #include <linux/list.h>
 #include <linux/backing-dev.h>
+#include <linux/wait.h>
+
+#include <asm/atomic.h>
 
 struct nfs_iostats;
 
@@ -110,6 +113,9 @@ struct nfs_server {
 						   filesystem */
 #endif
 	void (*destroy)(struct nfs_server *);
+
+	atomic_t active; /* Keep trace of any activity to this server */
+	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
 };
 
 /* Server capabilities */
