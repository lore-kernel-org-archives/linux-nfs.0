Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:45737 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752Ab1HPNqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 09:46:38 -0400
Received: by yie30 with SMTP id 30so3801362yie.19
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 06:46:38 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: benny@tonian.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH RESEND 2/2] pNFS: make _set_lo_fail generic
Date: Fri, 12 Aug 2011 18:02:18 -0700
Message-Id: <1313197338-4529-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1313197338-4529-1-git-send-email-bergwolf@gmail.com>
References: <1313197338-4529-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

file layout and block layout both use it to set mark layout io failure bit. So make it
generic.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   17 +++--------------
 fs/nfs/nfs4filelayout.c          |   19 +++----------------
 fs/nfs/pnfs.c                    |   12 ++++++++++++
 fs/nfs/pnfs.h                    |    1 +
 4 files changed, 19 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6fdddde..36648e1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -176,17 +176,6 @@ retry:
 	return bio;
 }
 
-static void bl_set_lo_fail(struct pnfs_layout_segment *lseg)
-{
-	if (lseg->pls_range.iomode == IOMODE_RW) {
-		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-	} else {
-		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
-	}
-}
-
 /* This is basically copied from mpage_end_io_read */
 static void bl_end_io_read(struct bio *bio, int err)
 {
@@ -206,7 +195,7 @@ static void bl_end_io_read(struct bio *bio, int err)
 	if (!uptodate) {
 		if (!rdata->pnfs_error)
 			rdata->pnfs_error = -EIO;
-		bl_set_lo_fail(rdata->lseg);
+		pnfs_set_lo_fail(rdata->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -370,7 +359,7 @@ static void bl_end_io_write_zero(struct bio *bio, int err)
 	if (!uptodate) {
 		if (!wdata->pnfs_error)
 			wdata->pnfs_error = -EIO;
-		bl_set_lo_fail(wdata->lseg);
+		pnfs_set_lo_fail(wdata->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -386,7 +375,7 @@ static void bl_end_io_write(struct bio *bio, int err)
 	if (!uptodate) {
 		if (!wdata->pnfs_error)
 			wdata->pnfs_error = -EIO;
-		bl_set_lo_fail(wdata->lseg);
+		pnfs_set_lo_fail(wdata->lseg);
 	}
 	bio_put(bio);
 	put_parallel(par);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e8915d4..4c78c62 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -77,19 +77,6 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	BUG();
 }
 
-/* For data server errors we don't recover from */
-static void
-filelayout_set_lo_fail(struct pnfs_layout_segment *lseg)
-{
-	if (lseg->pls_range.iomode == IOMODE_RW) {
-		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
-		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
-	} else {
-		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
-		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
-	}
-}
-
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
@@ -145,7 +132,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
-			filelayout_set_lo_fail(data->lseg);
+			pnfs_set_lo_fail(data->lseg);
 			nfs4_reset_read(task, data);
 			clp = NFS_SERVER(data->inode)->nfs_client;
 		}
@@ -221,7 +208,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
-			filelayout_set_lo_fail(data->lseg);
+			pnfs_set_lo_fail(data->lseg);
 			nfs4_reset_write(task, data);
 			clp = NFS_SERVER(data->inode)->nfs_client;
 		} else
@@ -256,7 +243,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
 			prepare_to_resend_writes(data);
-			filelayout_set_lo_fail(data->lseg);
+			pnfs_set_lo_fail(data->lseg);
 		} else
 			nfs_restart_rpc(task, data->ds_clp);
 		return -EAGAIN;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 329befe..b483bbc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1372,6 +1372,18 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 	}
 }
 
+void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
+{
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
+	} else {
+		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+	}
+}
+EXPORT_SYMBOL_GPL(pnfs_set_lo_fail);
+
 void
 pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3e159f2..d61c233 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -182,6 +182,7 @@ int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
+void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
-- 
1.7.1.262.g5ef3d

