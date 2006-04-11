From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 6/6] NFS: Add timeout to submounts
Date: Tue, 11 Apr 2006 14:05:41 -0400
Message-ID: <20060411180541.12579.92977.stgit@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Make automounted partitions expire using the mark_mounts_for_expiry()
function. The timeout is controlled via a sysctl.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |    3 +++
 fs/nfs/namespace.c     |   25 ++++++++++++++++++++++++-
 fs/nfs/sysctl.c        |   10 ++++++++++
 include/linux/nfs_fs.h |    3 +++
 4 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f5a133f..e051d00 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -184,6 +184,7 @@ static void nfs_umount_begin(struct vfsm
 	struct nfs_server *server;
 	struct rpc_clnt	*rpc;
 
+	shrink_submounts(vfsmnt, &nfs_automount_list);
 	if (!(flags & MNT_FORCE))
 		return;
 	/* -EIO all pending I/O */
@@ -1964,6 +1965,7 @@ static void nfs_kill_super(struct super_
 	nfs_free_iostats(server->io_stats);
 	kfree(server->hostname);
 	kfree(server);
+	nfs_release_automount_timer();
 }
 
 static struct file_system_type nfs_fs_type = {
@@ -2310,6 +2312,7 @@ static void nfs4_kill_super(struct super
 	nfs_free_iostats(server->io_stats);
 	kfree(server->hostname);
 	kfree(server);
+	nfs_release_automount_timer();
 }
 
 static struct file_system_type nfs4_fs_type = {
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index a155505..e426516 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -18,6 +18,11 @@ #include <linux/vfs.h>
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+LIST_HEAD(nfs_automount_list);
+static void nfs_expire_automounts(void *list);
+static DECLARE_WORK(nfs_automount_task, nfs_expire_automounts, &nfs_automount_list);
+int nfs_mountpoint_expiry_timeout = 500 * HZ;
+
 /*
  * nfs_follow_mountpoint - handle crossing a mountpoint on the server
  * @dentry - dentry of mountpoint
@@ -59,7 +64,7 @@ static void * nfs_follow_mountpoint(stru
 		goto out_err;
 
 	mntget(mnt);
-	err = do_add_mount(mnt, nd, nd->mnt->mnt_flags, NULL);
+	err = do_add_mount(mnt, nd, nd->mnt->mnt_flags|MNT_SHRINKABLE, &nfs_automount_list);
 	if (err < 0) {
 		mntput(mnt);
 		if (err == -EBUSY)
@@ -70,6 +75,7 @@ static void * nfs_follow_mountpoint(stru
 	dput(nd->dentry);
 	nd->mnt = mnt;
 	nd->dentry = dget(mnt->mnt_root);
+	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
 out:
 	dprintk("%s: done, returned %d\n", __FUNCTION__, err);
 	return ERR_PTR(err);
@@ -87,3 +93,20 @@ struct inode_operations nfs_mountpoint_i
 	.follow_link	= nfs_follow_mountpoint,
 	.getattr	= nfs_getattr,
 };
+
+static void nfs_expire_automounts(void *data)
+{
+	struct list_head *list = (struct list_head *)data;
+
+	mark_mounts_for_expiry(list);
+	if (!list_empty(list))
+		schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
+}
+
+void nfs_release_automount_timer(void)
+{
+	if (list_empty(&nfs_automount_list)) {
+		cancel_delayed_work(&nfs_automount_task);
+		flush_scheduled_work();
+	}
+}
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 4c486eb..db61e51 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -12,6 +12,7 @@ #include <linux/sysctl.h>
 #include <linux/module.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_idmap.h>
+#include <linux/nfs_fs.h>
 
 #include "callback.h"
 
@@ -46,6 +47,15 @@ #ifdef CONFIG_NFS_V4
 		.strategy = &sysctl_jiffies,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nfs_mountpoint_timeout",
+		.data		= &nfs_mountpoint_expiry_timeout,
+		.maxlen		= sizeof(nfs_mountpoint_expiry_timeout),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 7cd75e0..fe1e962 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -400,7 +400,10 @@ #endif
 /*
  * linux/fs/nfs/namespace.c
  */
+extern struct list_head nfs_automount_list;
 extern struct inode_operations nfs_mountpoint_inode_operations;
+extern int nfs_mountpoint_expiry_timeout;
+extern void nfs_release_automount_timer(void);
 
 /*
  * linux/fs/nfs/unlink.c
