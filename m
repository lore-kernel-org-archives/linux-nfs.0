From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFS: Add an nfsiod workqueue
Date: Tue, 19 Feb 2008 18:05:00 -0500
Message-ID: <20080219230459.22007.63210.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080219230459.22007.10990.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53378 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984AbYBSXPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 18:15:05 -0500
In-Reply-To: <20080219230459.22007.10990.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS post-rpciod cleanups often involve tasks that cannot be safely
performed within the rpciod context (due to deadlock concerns). We
therefore add a dedicated NFS workqueue that can perform tasks like
cleaning up state after an interrupted NFSv4 open() call, or calling
put_nfs_open_context() after an asynchronous read or write call.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c    |   37 +++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h |    1 +
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a499fb5..77a0986 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1219,6 +1219,36 @@ static void nfs_destroy_inodecache(void)
 	kmem_cache_destroy(nfs_inode_cachep);
 }
 
+struct workqueue_struct *nfsiod_workqueue;
+
+/*
+ * start up the nfsiod workqueue
+ */
+static int nfsiod_start(void)
+{
+	struct workqueue_struct *wq;
+	dprintk("RPC:       creating workqueue nfsiod\n");
+	wq = create_workqueue("nfsiod");
+	if (wq == NULL)
+		return -ENOMEM;
+	nfsiod_workqueue = wq;
+	return 0;
+}
+
+/*
+ * Destroy the nfsiod workqueue
+ */
+static void nfsiod_stop(void)
+{
+	struct workqueue_struct *wq;
+
+	wq = nfsiod_workqueue;
+	if (wq == NULL)
+		return;
+	nfsiod_workqueue = NULL;
+	destroy_workqueue(wq);
+}
+
 /*
  * Initialize NFS
  */
@@ -1226,6 +1256,10 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
+	err = nfsiod_start();
+	if (err)
+		goto out6;
+
 	err = nfs_fs_proc_init();
 	if (err)
 		goto out5;
@@ -1272,6 +1306,8 @@ out3:
 out4:
 	nfs_fs_proc_exit();
 out5:
+	nfsiod_stop();
+out6:
 	return err;
 }
 
@@ -1287,6 +1323,7 @@ static void __exit exit_nfs_fs(void)
 #endif
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
+	nfsiod_stop();
 }
 
 /* Not quite true; I just maintain it */
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0f56196..985dc29 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -143,6 +143,7 @@ extern struct rpc_procinfo nfs4_procedures[];
 extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
 
 /* inode.c */
+extern struct workqueue_struct *nfsiod_workqueue;
 extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
 extern int nfs_write_inode(struct inode *,int);
