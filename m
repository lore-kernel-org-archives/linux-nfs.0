Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50864 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab1E2SWq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:22:46 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 16/32] pnfs-obj: decode layout, alloc/free lseg
Date: Sun, 29 May 2011 21:22:34 +0300
Message-Id: <1306693354-8155-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

objlayout_alloc_lseg prepares an xdr_stream and calls the
raid engins objio_alloc_lseg() to allocate a private
pnfs_layout_segment.

objio_osd.c::objio_alloc_lseg() uses passed xdr_stream to
decode and store the layout_segment information in an
objio_segment struct, using the pnfs_osd_xdr.h API for
the actual parsing the layout xdr.

objlayout_free_lseg calls objio_free_lseg() to free the
allocated space.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[gfp_flags]
[removed "extern" from function definitions]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/Kbuild      |    2 +-
 fs/nfs/objlayout/objio_osd.c |  170 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/objlayout.c |  104 +++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   67 +++++++++++++++++
 4 files changed, 341 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/objlayout/objlayout.c
 create mode 100644 fs/nfs/objlayout/objlayout.h

diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
index 7b2a5a2..ed30ea0 100644
--- a/fs/nfs/objlayout/Kbuild
+++ b/fs/nfs/objlayout/Kbuild
@@ -1,5 +1,5 @@
 #
 # Makefile for the pNFS Objects Layout Driver kernel module
 #
-objlayoutdriver-y := objio_osd.o pnfs_osd_xdr_cli.o
+objlayoutdriver-y := objio_osd.o pnfs_osd_xdr_cli.o objlayout.o
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 379595f..08f1d90 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -38,11 +38,179 @@
  */
 
 #include <linux/module.h>
-#include "../pnfs.h"
+#include <scsi/osd_initiator.h>
+
+#include "objlayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+#define _LLU(x) ((unsigned long long)x)
+
+struct caps_buffers {
+	u8 caps_key[OSD_CRYPTO_KEYID_SIZE];
+	u8 creds[OSD_CAP_LEN];
+};
+
+struct objio_segment {
+	struct pnfs_layout_segment lseg;
+
+	struct pnfs_osd_object_cred *comps;
+
+	unsigned mirrors_p1;
+	unsigned stripe_unit;
+	unsigned group_width;	/* Data stripe_units without integrity comps */
+	u64 group_depth;
+	unsigned group_count;
+
+	unsigned comps_index;
+	unsigned num_comps;
+	/* variable length */
+	struct objio_dev_ent *ods[];
+};
+
+static inline struct objio_segment *
+OBJIO_LSEG(struct pnfs_layout_segment *lseg)
+{
+	return container_of(lseg, struct objio_segment, lseg);
+}
+
+static int _verify_data_map(struct pnfs_osd_layout *layout)
+{
+	struct pnfs_osd_data_map *data_map = &layout->olo_map;
+	u64 stripe_length;
+	u32 group_width;
+
+/* FIXME: Only raid0 for now. if not go through MDS */
+	if (data_map->odm_raid_algorithm != PNFS_OSD_RAID_0) {
+		printk(KERN_ERR "Only RAID_0 for now\n");
+		return -ENOTSUPP;
+	}
+	if (0 != (data_map->odm_num_comps % (data_map->odm_mirror_cnt + 1))) {
+		printk(KERN_ERR "Data Map wrong, num_comps=%u mirrors=%u\n",
+			  data_map->odm_num_comps, data_map->odm_mirror_cnt);
+		return -EINVAL;
+	}
+
+	if (data_map->odm_group_width)
+		group_width = data_map->odm_group_width;
+	else
+		group_width = data_map->odm_num_comps /
+						(data_map->odm_mirror_cnt + 1);
+
+	stripe_length = (u64)data_map->odm_stripe_unit * group_width;
+	if (stripe_length >= (1ULL << 32)) {
+		printk(KERN_ERR "Total Stripe length(0x%llx)"
+			  " >= 32bit is not supported\n", _LLU(stripe_length));
+		return -ENOTSUPP;
+	}
+
+	if (0 != (data_map->odm_stripe_unit & ~PAGE_MASK)) {
+		printk(KERN_ERR "Stripe Unit(0x%llx)"
+			  " must be Multples of PAGE_SIZE(0x%lx)\n",
+			  _LLU(data_map->odm_stripe_unit), PAGE_SIZE);
+		return -ENOTSUPP;
+	}
+
+	return 0;
+}
+
+static void copy_single_comp(struct pnfs_osd_object_cred *cur_comp,
+			     struct pnfs_osd_object_cred *src_comp,
+			     struct caps_buffers *caps_p)
+{
+	WARN_ON(src_comp->oc_cap_key.cred_len > sizeof(caps_p->caps_key));
+	WARN_ON(src_comp->oc_cap.cred_len > sizeof(caps_p->creds));
+
+	*cur_comp = *src_comp;
+
+	memcpy(caps_p->caps_key, src_comp->oc_cap_key.cred,
+	       sizeof(caps_p->caps_key));
+	cur_comp->oc_cap_key.cred = caps_p->caps_key;
+
+	memcpy(caps_p->creds, src_comp->oc_cap.cred,
+	       sizeof(caps_p->creds));
+	cur_comp->oc_cap.cred = caps_p->creds;
+}
+
+int objio_alloc_lseg(struct pnfs_layout_segment **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_range *range,
+	struct xdr_stream *xdr,
+	gfp_t gfp_flags)
+{
+	struct objio_segment *objio_seg;
+	struct pnfs_osd_xdr_decode_layout_iter iter;
+	struct pnfs_osd_layout layout;
+	struct pnfs_osd_object_cred *cur_comp, src_comp;
+	struct caps_buffers *caps_p;
+	int err;
+
+	err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
+	if (unlikely(err))
+		return err;
+
+	err = _verify_data_map(&layout);
+	if (unlikely(err))
+		return err;
+
+	objio_seg = kzalloc(sizeof(*objio_seg) +
+			    sizeof(objio_seg->ods[0]) * layout.olo_num_comps +
+			    sizeof(*objio_seg->comps) * layout.olo_num_comps +
+			    sizeof(struct caps_buffers) * layout.olo_num_comps,
+			    gfp_flags);
+	if (!objio_seg)
+		return -ENOMEM;
+
+	objio_seg->comps = (void *)(objio_seg->ods + layout.olo_num_comps);
+	cur_comp = objio_seg->comps;
+	caps_p = (void *)(cur_comp + layout.olo_num_comps);
+	while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err))
+		copy_single_comp(cur_comp++, &src_comp, caps_p++);
+	if (unlikely(err))
+		goto err;
+
+	objio_seg->num_comps = layout.olo_num_comps;
+	objio_seg->comps_index = layout.olo_comps_index;
+
+	objio_seg->mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
+	objio_seg->stripe_unit = layout.olo_map.odm_stripe_unit;
+	if (layout.olo_map.odm_group_width) {
+		objio_seg->group_width = layout.olo_map.odm_group_width;
+		objio_seg->group_depth = layout.olo_map.odm_group_depth;
+		objio_seg->group_count = layout.olo_map.odm_num_comps /
+						objio_seg->mirrors_p1 /
+						objio_seg->group_width;
+	} else {
+		objio_seg->group_width = layout.olo_map.odm_num_comps /
+						objio_seg->mirrors_p1;
+		objio_seg->group_depth = -1;
+		objio_seg->group_count = 1;
+	}
+
+	*outp = &objio_seg->lseg;
+	return 0;
+
+err:
+	kfree(objio_seg);
+	dprintk("%s: Error: return %d\n", __func__, err);
+	*outp = NULL;
+	return err;
+}
+
+void objio_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
+
+	kfree(objio_seg);
+}
+
 
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
+
+	.alloc_lseg              = objlayout_alloc_lseg,
+	.free_lseg               = objlayout_free_lseg,
 };
 
 MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
new file mode 100644
index 0000000..9465267
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.c
@@ -0,0 +1,104 @@
+/*
+ *  pNFS Objects layout driver high level definitions
+ *
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <scsi/osd_initiator.h>
+#include "objlayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+/*
+ * Unmarshall layout and store it in pnfslay.
+ */
+struct pnfs_layout_segment *
+objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
+		     struct nfs4_layoutget_res *lgr,
+		     gfp_t gfp_flags)
+{
+	int status = -ENOMEM;
+	struct xdr_stream stream;
+	struct xdr_buf buf = {
+		.pages =  lgr->layoutp->pages,
+		.page_len =  lgr->layoutp->len,
+		.buflen =  lgr->layoutp->len,
+		.len = lgr->layoutp->len,
+	};
+	struct page *scratch;
+	struct pnfs_layout_segment *lseg;
+
+	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
+
+	scratch = alloc_page(gfp_flags);
+	if (!scratch)
+		goto err_nofree;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	status = objio_alloc_lseg(&lseg, pnfslay, &lgr->range, &stream, gfp_flags);
+	if (unlikely(status)) {
+		dprintk("%s: objio_alloc_lseg Return err %d\n", __func__,
+			status);
+		goto err;
+	}
+
+	__free_page(scratch);
+
+	dprintk("%s: Return %p\n", __func__, lseg);
+	return lseg;
+
+err:
+	__free_page(scratch);
+err_nofree:
+	dprintk("%s: Err Return=>%d\n", __func__, status);
+	return ERR_PTR(status);
+}
+
+/*
+ * Free a layout segement
+ */
+void
+objlayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	dprintk("%s: freeing layout segment %p\n", __func__, lseg);
+
+	if (unlikely(!lseg))
+		return;
+
+	objio_free_lseg(lseg);
+}
+
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
new file mode 100644
index 0000000..066280a
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.h
@@ -0,0 +1,67 @@
+/*
+ *  Data types and function declerations for interfacing with the
+ *  pNFS standard object layout driver.
+ *
+ *  Copyright (C) 2007 Panasas Inc. [year of first publication]
+ *  All rights reserved.
+ *
+ *  Benny Halevy <bhalevy@panasas.com>
+ *  Boaz Harrosh <bharrosh@panasas.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2
+ *  See the file COPYING included with this distribution for more details.
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the Panasas company nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _OBJLAYOUT_H
+#define _OBJLAYOUT_H
+
+#include <linux/nfs_fs.h>
+#include <linux/pnfs_osd_xdr.h>
+#include "../pnfs.h"
+
+/*
+ * Raid engine I/O API
+ */
+extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_range *range,
+	struct xdr_stream *xdr,
+	gfp_t gfp_flags);
+extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
+
+/*
+ * exported generic objects function vectors
+ */
+extern struct pnfs_layout_segment *objlayout_alloc_lseg(
+	struct pnfs_layout_hdr *,
+	struct nfs4_layoutget_res *,
+	gfp_t gfp_flags);
+extern void objlayout_free_lseg(struct pnfs_layout_segment *);
+
+#endif /* _OBJLAYOUT_H */
-- 
1.7.2.3

