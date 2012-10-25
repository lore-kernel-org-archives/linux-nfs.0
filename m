Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759899Ab2JYSCz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 14:02:55 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: avoid deadlock in nfs_kill_super
Date: Thu, 25 Oct 2012 14:02:43 -0400
Message-Id: <1351188163-10067-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling nfs_kill_super from an RPC task callback would result in a deadlock
where nfs_free_server (via rpc_shutdown_client) tries to kill all
RPC tasks associated with that connection - including itself!

Instead of calling nfs_kill_super directly, queue a job on the nfsiod
workqueue.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

This fixes the current incarnation of the lockup I've been tracking down for
some time now.  I still have to go back and see why the reproducer changed
behavior a few weeks ago - tasks used to get stuck in rpc_prepare_task, but
now (before this patch) are stuck in rpc_exit.

The reproducer works against a server with write delegations:

./nfsometer.py -m v4 server:/path dd_100m_100k

which is basically:
 - mount
 - dd if=/dev/zero of=./dd_file.100m_100k bs=102400 count=1024
 - umount
 - break if /proc/fs/nfsfs/servers still has entry after 5 seconds (in this
   case it NEVER goes away)

There are clearly other ways to trigger this deadlock, like a v4.1 CLOSE - the
done handler calls nfs_sb_deactivate...

I've tested this approach with 10 runs X 3 nfs versions X 5 workloads 
(dd_100m_100k, dd_100m_1k, python, kernel, cthon), so I'm pretty confident
its correct.

One question for the list: should nfs_free_server *always* be scheduled on
the nfsiod workqueue? It's called in error paths in several locations.
After looking at them, I don't think my approach would break anything, but 
some might have style objections.

 -dros

 fs/nfs/client.c           |   20 +++++++++++++++++---
 include/linux/nfs_fs_sb.h |    1 +
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c285e0a..9186a96 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1010,9 +1010,11 @@ EXPORT_SYMBOL_GPL(nfs_alloc_server);
 /*
  * Free up a server record
  */
-void nfs_free_server(struct nfs_server *server)
+static void nfs_free_server_schedule_work(struct work_struct *work)
 {
-	dprintk("--> nfs_free_server()\n");
+	struct nfs_server *server = container_of(work, struct nfs_server, work);
+
+	dprintk("--> %s\n", __func__);
 
 	nfs_server_remove_lists(server);
 
@@ -1032,7 +1034,19 @@ void nfs_free_server(struct nfs_server *server)
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
-	dprintk("<-- nfs_free_server()\n");
+	dprintk("<-- %s\n", __func__);
+}
+
+/*
+ * Queue work on nfsiod workqueue to free up a server record.
+ * This avoids a deadlock when an RPC task scheduled from the rpciod
+ * workqueue tries to kill itself.
+ */
+void nfs_free_server(struct nfs_server *server)
+{
+	WARN_ON_ONCE(work_pending(&server->work));
+	INIT_WORK(&server->work, nfs_free_server_schedule_work);
+	queue_work(nfsiod_workqueue, &server->work);
 }
 EXPORT_SYMBOL_GPL(nfs_free_server);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a9e76ee..a607886 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -171,6 +171,7 @@ struct nfs_server {
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */
+	struct work_struct	work;		/* used to schedule free */
 
 	/* mountd-related mount options */
 	struct sockaddr_storage	mountd_address;
-- 
1.7.9.6 (Apple Git-31.1)

