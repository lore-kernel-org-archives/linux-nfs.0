From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 24/26] pnfs_submit: pnfs_update_layout can return void
Date: Fri, 11 Jun 2010 03:31:51 -0400
Message-ID: <1276241513-17942-25-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
 <1276241513-17942-13-git-send-email-iisaman@netapp.com>
 <1276241513-17942-14-git-send-email-iisaman@netapp.com>
 <1276241513-17942-15-git-send-email-iisaman@netapp.com>
 <1276241513-17942-16-git-send-email-iisaman@netapp.com>
 <1276241513-17942-17-git-send-email-iisaman@netapp.com>
 <1276241513-17942-18-git-send-email-iisaman@netapp.com>
 <1276241513-17942-19-git-send-email-iisaman@netapp.com>
 <1276241513-17942-20-git-send-email-iisaman@netapp.com>
 <1276241513-17942-21-git-send-email-iisaman@netapp.com>
 <1276241513-17942-22-git-send-email-iisaman@netapp.com>
 <1276241513-17942-23-git-send-email-iisaman@netapp.com>
 <1276241513-17942-24-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755069Ab0FKHci (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:38 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3uH024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:37 -0700 (PDT)
In-Reply-To: <1276241513-17942-24-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   27 +++++++++------------------
 fs/nfs/pnfs.h |   11 ++++-------
 2 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e37b71e..ae76e88 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1050,7 +1050,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
  * If lsegpp is given, the appropriate layout segment is referenced and
  * returned to the caller.
  */
-int
+void
 _pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   u64 count,
@@ -1068,14 +1068,12 @@ _pnfs_update_layout(struct inode *ino,
 	struct pnfs_layout_segment *lseg = NULL;
 	bool take_ref = (lsegpp != NULL);
 	DEFINE_WAIT(__wait);
-	int result = 0;
 
 	if (take_ref)
 		*lsegpp = NULL;
 	lo = get_lock_alloc_layout(ino);
 	if (IS_ERR(lo)) {
 		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
-		result = PTR_ERR(lo);
 		goto out;
 	}
 
@@ -1086,7 +1084,6 @@ _pnfs_update_layout(struct inode *ino,
 			put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
-		result = -EAGAIN;
 		goto out_put;
 	}
 
@@ -1109,21 +1106,18 @@ _pnfs_update_layout(struct inode *ino,
 			clear_bit(lo_fail_bit(iomode),
 				  &nfsi->layout.pnfs_layout_state);
 			nfsi->layout.pnfs_layout_suspend = 0;
-		} else {
-			result = 1;
+		} else
 			goto out_put;
-		}
 	}
 
 	/* Lose lock, but not reference, match this with pnfs_layout_release */
 	spin_unlock(&nfsi->lo_lock);
 
-	result = get_layout(ino, ctx, &arg, lsegpp, lo);
+	get_layout(ino, ctx, &arg, lsegpp, lo);
 out:
-	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-			__func__, result, nfsi->layout.pnfs_layout_state,
-		lseg);
-	return result;
+	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
+		nfsi->layout.pnfs_layout_state, lseg);
+	return;
 out_put:
 	if (lsegpp)
 		*lsegpp = lseg;
@@ -1364,7 +1358,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	size_t count = 0;
 	loff_t loff;
-	int status = 0;
 
 	pgio->pg_iswrite = 0;
 	pgio->pg_boundary = 0;
@@ -1378,11 +1371,9 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	readahead_range(inode, pages, &loff, &count);
 
 	if (count > 0) {
-		status = _pnfs_update_layout(inode, ctx, count,
-					    loff, IOMODE_READ,
-					    &pgio->pg_lseg);
-		dprintk("%s virt update returned %d\n", __func__, status);
-		if (status != 0)
+		_pnfs_update_layout(inode, ctx, count, loff, IOMODE_READ,
+				    &pgio->pg_lseg);
+		if (!pgio->pg_lseg)
 			return;
 
 		pgio->pg_boundary = pnfs_getboundary(inode);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bdf11bc..09de7a3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,7 +32,7 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait
 extern const nfs4_stateid zero_stateid;
 
 void put_lseg(struct pnfs_layout_segment *lseg);
-int _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
@@ -175,7 +175,7 @@ static inline int pnfs_return_layout(struct inode *ino,
 	return 0;
 }
 
-static inline int pnfs_update_layout(struct inode *ino,
+static inline void pnfs_update_layout(struct inode *ino,
 	struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
@@ -183,12 +183,10 @@ static inline int pnfs_update_layout(struct inode *ino,
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss))
-		return _pnfs_update_layout(ino, ctx, count, pos,
-					   access_type, lsegpp);
+		_pnfs_update_layout(ino, ctx, count, pos, access_type, lsegpp);
 	else {
 		if (lsegpp)
 			*lsegpp = NULL;
-		return 0;
 	}
 }
 
@@ -220,14 +218,13 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline int
+static inline void
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
 {
 	if (lsegpp)
 		*lsegpp = NULL;
-	return 0;
 }
 
 static inline enum pnfs_try_status
-- 
1.6.6.1

