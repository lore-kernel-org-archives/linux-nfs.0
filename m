Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46003 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab1E2KaX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 06:30:23 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 2/8] SQUASHME V2: objio alloc/free lseg Bugs fixes
Date: Sun, 29 May 2011 13:30:12 +0300
Message-Id: <1306665012-1006-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE21CD5.8070907@panasas.com>
References: <4DE21CD5.8070907@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
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

