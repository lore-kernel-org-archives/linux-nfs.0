Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60394 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752122Ab0I2LKy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:10:54 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] SQUASHME: pnfs: refactor put_lseg{_locked}
Date: Wed, 29 Sep 2010 13:10:51 +0200
Message-Id: <1285758651-27008-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

move common code into put_lseg_common

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++++
 fs/nfs/pnfs.c     |   36 ++++++++++++++----------------------
 fs/nfs/pnfs.h     |    1 +
 3 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ebf5127..52c5ddf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5664,9 +5664,17 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct inode *ino = lrp->args.inode;
+	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *server = NFS_SERVER(ino);
 
 	dprintk("--> %s\n", __func__);
+	if ((lrp->args.return_type == RETURN_FILE) &&
+	    pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
+		dprintk("%s: waiting on barrier\n", __func__);
+		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
+		return;
+	}
+
 	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 31a703d..4e47c2a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -301,14 +301,10 @@ destroy_lseg(struct kref *kref)
 	put_layout_hdr_locked(local);
 }
 
-void
-put_lseg_locked(struct pnfs_layout_segment *lseg)
+static void
+put_lseg_common(struct nfs_inode *nfsi, struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
-	struct nfs_inode *nfsi;
-
-	if (!lseg)
-		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->kref.refcount), lseg->valid);
@@ -320,12 +316,21 @@ put_lseg_locked(struct pnfs_layout_segment *lseg)
 		rpc_wake_up(&nfsi->lo_rpcwaitq);
 	}
 }
+
+void
+put_lseg_locked(struct pnfs_layout_segment *lseg)
+{
+	if (!lseg)
+		return;
+
+	assert_spin_locked(&lseg->layout->inode->i_lock);
+	put_lseg_common(NFS_I(lseg->layout->inode), lseg);
+}
 EXPORT_SYMBOL_GPL(put_lseg_locked);
 
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
-	bool do_wake_up;
 	struct nfs_inode *nfsi;
 
 	if (!lseg)
@@ -333,13 +338,10 @@ put_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->kref.refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
 	nfsi = NFS_I(lseg->layout->inode);
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	kref_put(&lseg->kref, destroy_lseg);
+	put_lseg_common(nfsi, lseg);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	if (do_wake_up)
-		wake_up(&nfsi->lo_waitq);
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
@@ -654,7 +656,7 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 	return out;
 }
 
-static bool
+bool
 pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			   struct pnfs_layout_range *range)
 {
@@ -743,16 +745,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 
 		spin_unlock(&ino->i_lock);
 
-		if (pnfs_return_layout_barrier(nfsi, &arg)) {
-			if (stateid) { /* callback */
-				status = -EAGAIN;
-				goto out_put;
-			}
-			dprintk("%s: waiting\n", __func__);
-			wait_event(nfsi->lo_waitq,
-				   !pnfs_return_layout_barrier(nfsi, &arg));
-		}
-
 		if (layoutcommit_needed(nfsi)) {
 			if (stateid && !wait) { /* callback */
 				dprintk("%s: layoutcommit pending\n", __func__);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 36ce9fa..b143390 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -239,6 +239,7 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo, struct pnfs_layout_range *range);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   loff_t pos, u64 count, enum pnfs_iomode access_type);
+bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type, bool wait);
-- 
1.7.2.3

