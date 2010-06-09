Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1306 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752734Ab0FIPPg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 11:15:36 -0400
Message-ID: <4C0FB016.3020208@panasas.com>
Date: Wed, 09 Jun 2010 18:15:34 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] FIXME: pnfs-obj: Short circuit the objlayout_commit to be
 a no-op
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>	<1275970761-31806-8-git-send-email-iisaman@netapp.com>	<1275970761-31806-9-git-send-email-iisaman@netapp.com>	<1275970761-31806-10-git-send-email-iisaman@netapp.com>	<1275970761-31806-11-git-send-email-iisaman@netapp.com>	<1275970761-31806-12-git-send-email-iisaman@netapp.com>	<1275970761-31806-13-git-send-email-iisaman@netapp.com>	<1275970761-31806-14-git-send-email-iisaman@netapp.com>	<1275970761-31806-15-git-send-email-iisaman@netapp.com>	<1275970761-31806-16-git-send-email-iisaman@netapp.com>	<1275970761-31806-17-git-send-email-iisaman@netapp.com>	<1275970761-31806-18-git-send-email-iisaman@netapp.com>	<1275970761-31806-19-git-send-email-iisaman@netapp.com>	<1275970761-31806-20-git-send-email-iisaman@netapp.com>	<1275970761-31806-21-git-send-email-iisaman@netapp.com>	<4C0F5A31.1070705@panasas.com> <AANLkTilh-FehoprAFUxFo5ndiu-TcqW-_LElPn3jrCgO@mail.gmail.com> <4C0FAF6B.90902@panasas.com>
In-Reply-To: <4C0FAF6B.90902@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Do to a bug in generic client: Return of NFS_FILE_SYNC from
write_done will render the system useless. When returning
NFS_UNSTABLE the generic layer then returns with a call to
objlayout_commit. At the outpost a successful nfs_commit_complete()
should be called and PNFS_ATTEMPTED returned.

Since nfs_commit_complete cannot be called from within
objlayout_commit. It is scheduled on an rpc task to be called
asynchronously.

TODO:
  All this is good code, actually needed and missing from obio_osd.
  What's missing is the actual call to osd_flush() and the completion
  call on request return.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    2 +-
 fs/nfs/objlayout/objlayout.c |   17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 315f8c6..4e266a2 100644
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
-- 
1.6.6.1


