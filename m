Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17542 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932594Ab1EWTph (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 15:45:37 -0400
Message-ID: <4DDAB94C.6070407@panasas.com>
Date: Mon, 23 May 2011 22:45:16 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: objio read/write patch: Bugs fixes
References: <4DDA8C3D.5080706@panasas.com> <1306168626-11463-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306168626-11463-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Wrong allocation and pointering in lseg_alloc.

Cap BIO size it one page (This hunk goes into the read/write patch)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9bb5830..b6ec124 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -147,7 +147,7 @@ struct objio_segment {
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
-	struct osd_dev	*ods[1];
+	struct osd_dev	*ods[];
 };
 
 static inline struct objio_segment *
@@ -331,7 +331,6 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct pnfs_osd_layout layout;
 	struct pnfs_osd_object_cred *cur_comp, src_comp;
 	struct caps_buffers *caps_p;
-
 	int err;
 
 	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
@@ -342,14 +341,16 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	if (unlikely(err))
 		return err;
 
-	objio_seg = kzalloc(sizeof(*objio_seg) +
+	objio_seg = kzalloc(sizeof(*objio_seg) + 
+			    sizeof(objio_seg->ods[0]) * layout.olo_num_comps +
 			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
 			    sizeof(struct caps_buffers) * layout.olo_num_comps,
 			    GFP_KERNEL);
 	if (!objio_seg)
 		return -ENOMEM;
 
-	cur_comp = objio_seg->comps = (void *)(objio_seg + 1);
+	objio_seg->comps = (void *)(objio_seg->ods + layout.olo_num_comps);
+	cur_comp = objio_seg->comps;
 	caps_p = (void *)(cur_comp + layout.olo_num_comps);
 	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err)) {
 		copy_single_comp(cur_comp++, &src_comp, caps_p++);
@@ -606,6 +607,9 @@ static int _add_stripe_unit(struct objio_state *ios,  unsigned *cur_pg,
 		unsigned bio_size = (ios->ol_state.nr_pages + pages_in_stripe) /
 				    stripes;
 
+		if (BIO_MAX_PAGES_KMALLOC < bio_size)
+			bio_size = BIO_MAX_PAGES_KMALLOC;
+
 		per_dev->bio = bio_kmalloc(GFP_KERNEL, bio_size);
 		if (unlikely(!per_dev->bio)) {
 			dprintk("Faild to allocate BIO size=%u\n", bio_size);
-- 
1.7.2.3


