Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37267 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757404Ab1EZTFa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:05:30 -0400
Message-ID: <4DDEA47A.6080700@panasas.com>
Date: Thu, 26 May 2011 22:05:30 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME V2: objio alloc/free lseg Bugs fixes
References: <4DDD7392.6040505@panasas.com> <1306358906-17366-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358906-17366-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Wrong allocation and pointering in lseg_alloc.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 725b1df..08f1d90 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -65,7 +65,7 @@ struct objio_segment {
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
-	struct osd_dev	*ods[1];
+	struct objio_dev_ent *ods[];
 };
 
 static inline struct objio_segment *
@@ -143,7 +143,6 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 	struct pnfs_osd_layout layout;
 	struct pnfs_osd_object_cred *cur_comp, src_comp;
 	struct caps_buffers *caps_p;
-
 	int err;
 
 	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
@@ -155,13 +154,15 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 		return err;
 
 	objio_seg = kzalloc(sizeof(*objio_seg) +
+			    sizeof(objio_seg->ods[0]) * layout.olo_num_comps +
 			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
 			    sizeof(struct caps_buffers) * layout.olo_num_comps,
 			    gfp_flags);
 	if (!objio_seg)
 		return -ENOMEM;
 
-	cur_comp = objio_seg->comps = (void *)(objio_seg + 1);
+	objio_seg->comps = (void *)(objio_seg->ods + layout.olo_num_comps);
+	cur_comp = objio_seg->comps;
 	caps_p = (void *)(cur_comp + layout.olo_num_comps);
 	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err))
 		copy_single_comp(cur_comp++, &src_comp, caps_p++);
-- 
1.7.2.3


