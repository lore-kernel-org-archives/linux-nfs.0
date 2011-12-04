Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49837 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNtr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:49:47 -0500
Received: by mail-ee0-f46.google.com with SMTP id q14so1496904eea.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:49:47 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/13] pnfsd-block: use SECT_SIZE helper macros
Date: Sun,  4 Dec 2011 15:49:41 +0200
Message-Id: <1323006581-13799-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_ops.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 0c3a536..31e23c2 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -44,9 +44,15 @@
 #define bl_layout_hashval(id) \
 	((id) & BL_LAYOUT_HASH_MASK)
 
+#define BL_SECT_SHIFT		9
+#define BL_SECT_SIZE		(1 << BL_SECT_SHIFT)
+#define BL_SECT_MASK		(~(BL_SECT_SIZE - 1))
+#define BL_SECT_ALIGN(x)	ALIGN((x), BL_SECT_SIZE)
+
 #define BLL_F_END(p) ((p)->bll_foff + (p)->bll_len)
 #define BLL_S_END(p) ((p)->bll_soff + (p)->bll_len)
-#define _2SECTS(v) ((v) >> 9)
+#define _2SECTS(v) ((v) >> BL_SECT_SHIFT)
+#define _2BYTES(v) ((unsigned long long)(v) << BL_SECT_SHIFT)
 
 #ifndef READ32
 #define READ32(x)	(x) = ntohl(*p++)
@@ -274,9 +280,9 @@ static boolean_t extents_process(struct fiemap_extent_info *fei,
 	memset(bld, 0, sizeof (*bld));
 	bld->bld_type			= PNFS_BLOCK_VOLUME_STRIPE;
 	bld->u.stripe.bld_stripes	= res->u.stripe.num_stripes;
-	bld->u.stripe.bld_chunk_size	= res->u.stripe.stripe_size * 512LL;
+	bld->u.stripe.bld_chunk_size	= _2BYTES(res->u.stripe.stripe_size);
 	dprintk("%s: stripes %d, chunk_size %Lu\n", __func__,
-	    bld->u.stripe.bld_stripes, bld->u.stripe.bld_chunk_size / 512LL);
+	    bld->u.stripe.bld_stripes, _2SECTS(bld->u.stripe.bld_chunk_size));
 	
 	bld->u.stripe.bld_stripe_indexs = kmalloc(bld->u.stripe.bld_stripes *
 						  sizeof (int), GFP_KERNEL);
@@ -381,10 +387,10 @@ enum nfsstat4
 	     (res->lg_seg.iomode == IOMODE_READ)))
 		res->lg_seg.length = i->i_size - res->lg_seg.offset;
 	
-	adj = (res->lg_seg.offset & 511) ? res->lg_seg.offset & 511 : 0;
+	adj = res->lg_seg.offset & ~BL_SECT_MASK;
 	res->lg_seg.offset -= adj;
-	res->lg_seg.length = (res->lg_seg.length + adj + 511) & ~511;
-	
+	res->lg_seg.length = BL_SECT_ALIGN(res->lg_seg.length + adj);
+
 	if (res->lg_seg.iomode != IOMODE_READ)
 		if (i->i_op->fallocate(i, FALLOC_FL_KEEP_SIZE,
 				       res->lg_seg.offset, res->lg_seg.length))
@@ -679,7 +685,7 @@ enum nfsstat4
 	if (!bld)
 		return NULL;
 	
-	bld->u.simple.bld_offset = (res->u.sig.sector * 512LL) + res->u.sig.offset;
+	bld->u.simple.bld_offset = _2BYTES(res->u.sig.sector) + res->u.sig.offset;
 	bld->u.simple.bld_sig_len = res->u.sig.len;
 	bld->u.simple.bld_sig = kmalloc(res->u.sig.len, GFP_KERNEL);
 	if (!bld->u.simple.bld_sig)
@@ -727,12 +733,12 @@ enum nfsstat4
 	
 	bld->bld_devid.devid = devid;
 	bld->bld_index_loc	= my_loc;
-	bld->u.slice.bld_start	= res->u.slice.start * 512LL;
-	bld->u.slice.bld_len	= res->u.slice.length * 512LL;
+	bld->u.slice.bld_start	= _2BYTES(res->u.slice.start);
+	bld->u.slice.bld_len	= _2BYTES(res->u.slice.length);
 	bld->u.slice.bld_index	= simple_loc;
 
 	dprintk("%s: start %Lu, len %Lu\n", __func__,
-		bld->u.slice.bld_start / 512LL, bld->u.slice.bld_len / 512LL);
+		_2SECTS(bld->u.slice.bld_start), _2SECTS(bld->u.slice.bld_len));
 
 	kfree(res);
 	dprintk("<-- %s (rval %p)\n", __func__, bld);
-- 
1.7.6

