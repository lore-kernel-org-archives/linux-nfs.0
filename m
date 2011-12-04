Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49837 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:50:12 -0500
Received: by mail-ee0-f46.google.com with SMTP id q14so1496904eea.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:50:12 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/13] pnfsd-block: set the sbid part of the deviceid
Date: Sun,  4 Dec 2011 15:50:06 +0200
Message-Id: <1323006606-13883-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c    |   34 ++++++++++++++++++----------------
 fs/nfsd/nfs4pnfsd.c |   28 +++++++++++++++++++++++++---
 fs/nfsd/pnfsd.h     |    1 +
 3 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index f5980a3..04788a1 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -95,7 +95,7 @@
     dev_t devid, int my_loc, int idx);
 static int layout_cache_fill_from(bl_layout_rec_t *r, struct list_head *h,
     struct nfsd4_layout_seg *seg);
-struct list_head *layout_cache_iter(bl_layout_rec_t *r,
+struct list_head *layout_cache_iter(struct super_block *, bl_layout_rec_t *r,
     struct list_head *bl_possible, struct nfsd4_layout_seg *seg);
 static void layout_cache_merge(bl_layout_rec_t *r, struct list_head *h);
 static int layout_cache_update(bl_layout_rec_t *r, struct list_head *h);
@@ -117,8 +117,8 @@ static void extents_count(struct fiemap_extent_info *fei, struct inode *i,
 static boolean_t extents_get(struct fiemap_extent_info *fei, struct inode *i,
     u64 foff, u64 len);
 static boolean_t extents_process(struct fiemap_extent_info *fei,
-    struct list_head *bl_candidates, struct nfsd4_layout_seg *, dev_t dev,
-    pnfs_blocklayout_layout_t *b);
+    struct list_head *bl_candidates, struct nfsd4_layout_seg *,
+    u64 sbid, dev_t dev, pnfs_blocklayout_layout_t *b);
 static void extents_cleanup(struct fiemap_extent_info *fei);
 
 void
@@ -420,7 +420,7 @@ enum nfsstat4
 	res->lg_return_on_close	= 1;
 	res->lg_seg.length	= 0;
 	
-	bl_candidates = layout_cache_iter(r, &bl_possible, &res->lg_seg);
+	bl_candidates = layout_cache_iter(i->i_sb, r, &bl_possible, &res->lg_seg);
 	if (!bl_candidates) {
 		nfserr = NFS4ERR_LAYOUTTRYLATER;
 		goto layoutget_cleanup;
@@ -775,8 +775,8 @@ enum nfsstat4
 }
 
 struct list_head *
-layout_cache_iter(bl_layout_rec_t *r, struct list_head *bl_possible,
-    struct nfsd4_layout_seg *seg)
+layout_cache_iter(struct super_block *sb, bl_layout_rec_t *r,
+		  struct list_head *bl_possible, struct nfsd4_layout_seg *seg)
 {
 	pnfs_blocklayout_layout_t	*b,
 					*n		= NULL;
@@ -784,6 +784,7 @@ struct list_head *
 	struct fiemap_extent_info	fei;
 	struct inode			*i;
 	dev_t				dev;
+	u64				sbid = find_sbid(sb);
 	
 	dev	= r->blr_rdev;
 	i	= r->blr_inode;
@@ -810,7 +811,7 @@ struct list_head *
 				    b->bll_len) == False)
 					goto cleanup;
 				if (extents_process(&fei, bl_candidates,
-				    seg, dev, b) == False)
+						    seg, sbid, dev, b) == False)
 					goto cleanup;
 				extents_cleanup(&fei);
 				
@@ -825,7 +826,7 @@ struct list_head *
 				n = bll_alloc(b->bll_foff, b->bll_len,
 				    BLOCK_LAYOUT_NEW, bl_candidates);
 				n->bll_es = PNFS_BLOCK_NONE_DATA;
-				n->bll_vol_id.sbid = 0;
+				n->bll_vol_id.sbid = sbid;
 				n->bll_vol_id.devid = dev;
 				seg->length += b->bll_len;
 			} else {
@@ -1177,7 +1178,8 @@ struct list_head *
 	pnfs_blocklayout_layout_t	*b,
 					*n;
 	enum pnfs_block_extent_state4	s;
-	
+	u64				sbid = find_sbid(r->blr_inode->i_sb);
+
 	list_for_each_entry(b, &r->blr_layouts, bll_list) {
 		if (seg->offset < b->bll_foff) {
 			n = bll_alloc(seg->offset,
@@ -1218,7 +1220,7 @@ struct list_head *
 				return False;
 			
 			n->bll_soff = b->bll_soff + seg->offset - b->bll_foff;
-			n->bll_vol_id.sbid = 0;
+			n->bll_vol_id.sbid = sbid;
 			n->bll_vol_id.devid = b->bll_vol_id.devid;
 			n->bll_es = s;
 			seg->offset += n->bll_len;
@@ -1232,7 +1234,7 @@ struct list_head *
 
 static u64
 bll_alloc_holey(struct list_head *bl_candidates, u64 offset, u64 length,
-    dev_t dev)
+		u64 sbid, dev_t dev)
 {
 	pnfs_blocklayout_layout_t	*n;
 	
@@ -1240,7 +1242,7 @@ struct list_head *
 	if (!n)
 		return 0;
 	n->bll_es = PNFS_BLOCK_NONE_DATA;
-	n->bll_vol_id.sbid = 0;
+	n->bll_vol_id.sbid = sbid;
 	n->bll_vol_id.devid = dev;
 	
 	return n->bll_len;
@@ -1323,7 +1325,7 @@ struct list_head *
  */
 static boolean_t
 extents_process(struct fiemap_extent_info *fei, struct list_head *bl_candidates,
-    struct nfsd4_layout_seg *seg, dev_t dev, pnfs_blocklayout_layout_t *b)
+    struct nfsd4_layout_seg *seg, u64 sbid, dev_t dev, pnfs_blocklayout_layout_t *b)
 {
 	struct fiemap_extent		*fep,
 					*fep_last	= NULL;
@@ -1353,7 +1355,7 @@ struct list_head *
 			    _2SECTS(fep_last->fe_length));
 			last_end = fep_last->fe_logical + fep_last->fe_length;
 			rval = bll_alloc_holey(bl_candidates, last_end,
-			    fep->fe_logical - last_end, dev);
+			    fep->fe_logical - last_end, sbid, dev);
 			if (!rval)
 				return False;
 			seg->length += rval;
@@ -1369,7 +1371,7 @@ struct list_head *
 		n->bll_soff = fep->fe_physical;
 		n->bll_es = seg->iomode == IOMODE_READ ?
 		    PNFS_BLOCK_READ_DATA : PNFS_BLOCK_READWRITE_DATA;
-		n->bll_vol_id.sbid = 0;
+		n->bll_vol_id.sbid = sbid;
 		n->bll_vol_id.devid = dev;
 		seg->length += fep->fe_length;
 		print_bll(n, "New extent");
@@ -1638,7 +1640,7 @@ struct list_head *
 	if (n) {
 		n->bll_es			= b->bll_es;
 		n->bll_soff			= b->bll_soff;
-		n->bll_vol_id.devid		= b->bll_vol_id.devid;
+		n->bll_vol_id			= b->bll_vol_id;
 	}
 	return n;
 }
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 42e2bb0..6b2e327 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -416,15 +416,14 @@ struct super_block *
 	return sb;
 }
 
-u64
-find_create_sbid(struct super_block *sb)
+static u64
+__find_sbid(struct super_block *sb)
 {
 	struct sbid_tracker *sbid;
 	unsigned long hash_idx = sbid_hashval(sb);
 	int pos = 0;
 	u64 id = 0;
 
-	spin_lock(&layout_lock);
 	list_for_each_entry (sbid, &sbid_hashtbl[hash_idx], hash) {
 		pos++;
 		if (sbid->sb != sb)
@@ -434,6 +433,29 @@ struct super_block *
 		id = sbid->id;
 		break;
 	}
+
+	return id;
+}
+
+u64
+find_sbid(struct super_block *sb)
+{
+	u64 id;
+
+	spin_lock(&layout_lock);
+	id = __find_sbid(sb);
+	spin_unlock(&layout_lock);
+
+	return id;
+}
+
+u64
+find_create_sbid(struct super_block *sb)
+{
+	u64 id;
+
+	spin_lock(&layout_lock);
+	id = __find_sbid(sb);
 	spin_unlock(&layout_lock);
 
 	if (!id)
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index f0862fb..abcb308 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -111,6 +111,7 @@ struct nfs4_notify_device {
 	struct nfsd4_callback		nd_recall;
 };
 
+u64 find_sbid(struct super_block *);
 u64 find_create_sbid(struct super_block *);
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
-- 
1.7.6

