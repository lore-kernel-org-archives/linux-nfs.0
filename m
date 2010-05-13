Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54791 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab0EMP7E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 11:59:04 -0400
Received: by wyb32 with SMTP id 32so1012089wyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 08:59:03 -0700 (PDT)
Message-ID: <4BEC21C3.50007@panasas.com>
Date: Thu, 13 May 2010 18:58:59 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: ONE More BAD bug with 2.6.34-pnfs branch found - watch out.
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


The NFS_FILE_SYNC return from write_done is one big bug. Do not use it!

Both Pan_shim and osd_objio where returning NFS_FILE_SYN. For pan_shim it
is true and for osd_objio it was out of laziness and was actually a lie.

The patch below will work around the situation and will finally after
many month return my 2.6.34 client to it's previous glory. Fffffff

If any one is returning NFS_FILE_SYNC from write then they have a problem

Boaz
---
git diff --stat -p -M fs/nfs/objlayout
 fs/nfs/objlayout/objio_osd.c |    2 +-
 fs/nfs/objlayout/objlayout.c |   17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 642d6fa..73e8b85 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -852,7 +852,7 @@ static ssize_t _write_done(struct objio_state *ios)
 	if (likely(!ret)) {
 		/* FIXME: should be based on the OSD's persistence model
 		 * See OSD2r05 Section 4.13 Data persistence model */
-		ios->ol_state.committed = NFS_FILE_SYNC;
+		ios->ol_state.committed = NFS_UNSTABLE; //NFS_FILE_SYNC;
 		status = ios->length;
 	} else {
 		status = ret;
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 880d987..60f64b7 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -287,15 +287,30 @@ objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
 	}
 }
 
+static void _rpc_commit_complete(struct work_struct *work)
+{
+	struct rpc_task *task;
+	struct nfs_write_data *wdata;
+
+	dprintk("%s enter\n", __func__);
+	task = container_of(work, struct rpc_task, u.tk_work);
+	wdata = container_of(task, struct nfs_write_data, task);
+
+	pnfs_client_ops->nfs_commit_complete(wdata);
+}
+
 /*
  * Commit data remotely on OSDs
  */
 enum pnfs_try_status
 objlayout_commit(struct pnfs_layout_type *pnfslay,
 		 int sync,
-		 struct nfs_write_data *data)
+		 struct nfs_write_data *wdata)
 {
 	int status = PNFS_ATTEMPTED;
+
+	INIT_WORK(&wdata->task.u.tk_work, _rpc_commit_complete);
+	schedule_work(&wdata->task.u.tk_work);
 	dprintk("%s: Return %d\n", __func__, status);
 	return status;
 }

