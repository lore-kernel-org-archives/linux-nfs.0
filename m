From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 24/24] pnfs_submit: pnfs_update_layout can return void
Date: Tue,  8 Jun 2010 00:19:21 -0400
Message-ID: <1275970761-31806-25-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
 <1275970761-31806-15-git-send-email-iisaman@netapp.com>
 <1275970761-31806-16-git-send-email-iisaman@netapp.com>
 <1275970761-31806-17-git-send-email-iisaman@netapp.com>
 <1275970761-31806-18-git-send-email-iisaman@netapp.com>
 <1275970761-31806-19-git-send-email-iisaman@netapp.com>
 <1275970761-31806-20-git-send-email-iisaman@netapp.com>
 <1275970761-31806-21-git-send-email-iisaman@netapp.com>
 <1275970761-31806-22-git-send-email-iisaman@netapp.com>
 <1275970761-31806-23-git-send-email-iisaman@netapp.com>
 <1275970761-31806-24-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0FHETu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:50 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQF014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:42 -0700 (PDT)
In-Reply-To: <1275970761-31806-24-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   27 +++++++++------------------
 fs/nfs/pnfs.h |   11 ++++-------
 2 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9f28b28..4f5d2ea 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1072,7 +1072,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
  * If lsegpp is given, the appropriate layout segment is referenced and
  * returned to the caller.
  */
-int
+void
 _pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   u64 count,
@@ -1090,14 +1090,12 @@ _pnfs_update_layout(struct inode *ino,
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
 
@@ -1108,7 +1106,6 @@ _pnfs_update_layout(struct inode *ino,
 			put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
-		result = -EAGAIN;
 		goto out_put;
 	}
 
@@ -1131,21 +1128,18 @@ _pnfs_update_layout(struct inode *ino,
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
 	unlock_current_layout(nfsi);
 
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
@@ -1386,7 +1380,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	size_t count = 0;
 	loff_t loff;
-	int status = 0;
 
 	pgio->pg_iswrite = 0;
 	pgio->pg_boundary = 0;
@@ -1400,11 +1393,9 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
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
index e231ca3..f7e21dc 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,7 +32,7 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait
 extern const nfs4_stateid zero_stateid;
 
 void put_lseg(struct pnfs_layout_segment *lseg);
-int _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
@@ -176,7 +176,7 @@ static inline int pnfs_return_layout(struct inode *ino,
 	return 0;
 }
 
-static inline int pnfs_update_layout(struct inode *ino,
+static inline void pnfs_update_layout(struct inode *ino,
 	struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
@@ -184,12 +184,10 @@ static inline int pnfs_update_layout(struct inode *ino,
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
 
@@ -221,14 +219,13 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
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

