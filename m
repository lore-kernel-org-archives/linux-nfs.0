Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:56600 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab1HJPih (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 11:38:37 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so2033196pzk.1
        for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 08:38:37 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Benny Halevy <benny@tonian.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH 3/5] pnfs: introduce pnfs private workqueue
Date: Sat,  6 Aug 2011 19:53:53 -0700
Message-Id: <1312685635-1593-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For layoutdriver io done functions, default workqueue is not a good place
as the code is executed in IO path. So add a pnfs private workqueue to handle
them.

Also change block and object layout code to make use of this private workqueue.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   17 ++++++++++----
 fs/nfs/objlayout/objio_osd.c     |    8 ++++++
 fs/nfs/objlayout/objlayout.c     |    4 +-
 fs/nfs/pnfs.c                    |   46 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                    |    4 +++
 5 files changed, 71 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9561c8f..3aef9f0 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -228,7 +228,7 @@ bl_end_par_io_read(void *data)
 	struct nfs_read_data *rdata = data;
 
 	INIT_WORK(&rdata->task.u.tk_work, bl_read_cleanup);
-	schedule_work(&rdata->task.u.tk_work);
+	queue_work(pnfsiod_workqueue, &rdata->task.u.tk_work);
 }
 
 /* We don't want normal .rpc_call_done callback used, so we replace it
@@ -418,7 +418,7 @@ static void bl_end_par_io_write(void *data)
 	wdata->task.tk_status = 0;
 	wdata->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&wdata->task.u.tk_work, bl_write_cleanup);
-	schedule_work(&wdata->task.u.tk_work);
+	queue_work(pnfsiod_workqueue, &wdata->task.u.tk_work);
 }
 
 /* FIXME STUB - mark intersection of layout and page as bad, so is not
@@ -977,29 +977,35 @@ static int __init nfs4blocklayout_init(void)
 	if (ret)
 		goto out;
 
+	ret = pnfsiod_start();
+	if (ret)
+		goto out_remove;
+
 	init_waitqueue_head(&bl_wq);
 
 	mnt = rpc_get_mount();
 	if (IS_ERR(mnt)) {
 		ret = PTR_ERR(mnt);
-		goto out_remove;
+		goto out_stop;
 	}
 
 	ret = vfs_path_lookup(mnt->mnt_root,
 			      mnt,
 			      NFS_PIPE_DIRNAME, 0, &path);
 	if (ret)
-		goto out_remove;
+		goto out_stop;
 
 	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
 				    &bl_upcall_ops, 0);
 	if (IS_ERR(bl_device_pipe)) {
 		ret = PTR_ERR(bl_device_pipe);
-		goto out_remove;
+		goto out_stop;
 	}
 out:
 	return ret;
 
+out_stop:
+	pnfsiod_stop();
 out_remove:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 	return ret;
@@ -1011,6 +1017,7 @@ static void __exit nfs4blocklayout_exit(void)
 	       __func__);
 
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+	pnfsiod_stop();
 	rpc_unlink(bl_device_pipe);
 }
 
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index d0cda12..f28013f 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1042,7 +1042,14 @@ static int __init
 objlayout_init(void)
 {
 	int ret = pnfs_register_layoutdriver(&objlayout_type);
+	if (ret)
+		goto out;
 
+	ret = pnfsiod_start();
+	if (ret)
+		pnfs_unregister_layoutdriver(&objlayout_type);
+
+out:
 	if (ret)
 		printk(KERN_INFO
 			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
@@ -1057,6 +1064,7 @@ static void __exit
 objlayout_exit(void)
 {
 	pnfs_unregister_layoutdriver(&objlayout_type);
+	pnfsiod_stop();
 	printk(KERN_INFO "%s: Unregistered OSD pNFS Layout Driver\n",
 	       __func__);
 }
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 1d06f8e..1e7fa05 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -305,7 +305,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 		pnfs_ld_read_done(rdata);
 	else {
 		INIT_WORK(&rdata->task.u.tk_work, _rpc_read_complete);
-		schedule_work(&rdata->task.u.tk_work);
+		queue_task(pnfsiod_workqueue, &rdata->task.u.tk_work);
 	}
 }
 
@@ -396,7 +396,7 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
 		pnfs_ld_write_done(wdata);
 	else {
 		INIT_WORK(&wdata->task.u.tk_work, _rpc_write_complete);
-		schedule_work(&wdata->task.u.tk_work);
+		queue_task(pnfsiod_workqueue, &wdata->task.u.tk_work);
 	}
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 66fc854..e183a4f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -38,7 +38,7 @@
 /* Locking:
  *
  * pnfs_spinlock:
- *      protects pnfs_modules_tbl.
+ *      protects pnfs_modules_tbl, pnfsiod_workqueue and pnfsiod_users.
  */
 static DEFINE_SPINLOCK(pnfs_spinlock);
 
@@ -47,6 +47,9 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
  */
 static LIST_HEAD(pnfs_modules_tbl);
 
+struct workqueue_struct *pnfsiod_workqueue;
+static int pnfsiod_users = 0;
+
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver_locked(u32 id)
@@ -1517,3 +1520,44 @@ out:
 	dprintk("<-- %s status %d\n", __func__, status);
 	return status;
 }
+
+/*
+ * start up the pnfsiod workqueue
+ */
+int pnfsiod_start(void)
+{
+	struct workqueue_struct *wq;
+	dprintk("RPC:       creating workqueue pnfsiod\n");
+	wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
+	if (wq == NULL)
+		return -ENOMEM;
+	spin_lock(&pnfs_spinlock);
+	pnfsiod_users++;
+	if (pnfsiod_workqueue == NULL) {
+		pnfsiod_workqueue = wq;
+	} else {
+		destroy_workqueue(wq);
+	}
+	spin_unlock(&pnfs_spinlock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(pnfsiod_start);
+
+/*
+ * Destroy the pnfsiod workqueue
+ */
+void pnfsiod_stop(void)
+{
+	struct workqueue_struct *wq == NULL;
+
+	spin_lock(&pnfs_spinlock);
+	pnfsiod_users--;
+	if (pnfsiod_users == 0) {
+		wq = pnfsiod_workqueue;
+		pnfsiod_workqueue = NULL;
+	}
+	spin_unlock(&pnfs_spinlock);
+	if (wq)
+		destroy_workqueue(wq);
+}
+EXPORT_SYMBOL_GPL(pnfsiod_stop);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 01cbfd5..af7530b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -155,6 +155,10 @@ struct pnfs_devicelist {
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
+extern struct workqueue_struct *pnfsiod_workqueue;
+extern int pnfsiod_start(void);
+extern void pnfsiod_stop(void);
+
 /* nfs4proc.c */
 extern int nfs4_proc_getdevicelist(struct nfs_server *server,
 				   const struct nfs_fh *fh,
-- 
1.7.1.262.g5ef3d

