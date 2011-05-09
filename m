Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37979 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab1EIRIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:08:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 12/29] pnfs-obj: decode layout, alloc/free lseg
Date: Mon,  9 May 2011 20:08:37 +0300
Message-Id: <1304960917-4233-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

objlayout_alloc_lseg allocates space for and decodes the pnfs-obj layout payload.

objlayout_free_lseg frees the allocated space.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/Kbuild             |    2 +-
 fs/nfs/objlayout/objio_osd.c        |   34 ++++++++++-
 fs/nfs/objlayout/objlayout.c        |  121 +++++++++++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h        |   75 +++++++++++++++++++++
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   33 ++++++++++
 5 files changed, 263 insertions(+), 2 deletions(-)
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
index 379595f..c5f69c6 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -38,11 +38,43 @@
  */
 
 #include <linux/module.h>
-#include "../pnfs.h"
+
+#include "objlayout.h"
+
+struct objio_segment {
+	struct pnfs_osd_layout *layout;
+};
+
+int objio_alloc_lseg(void **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_segment *lseg,
+	struct pnfs_osd_layout *layout)
+{
+	struct objio_segment *objio_seg;
+
+	objio_seg = kzalloc(sizeof(*objio_seg), GFP_KERNEL);
+	if (!objio_seg)
+		return -ENOMEM;
+
+	objio_seg->layout = layout;
+
+	*outp = objio_seg;
+	return 0;
+}
+
+void objio_free_lseg(void *p)
+{
+	struct objio_segment *objio_seg = p;
+
+	kfree(objio_seg);
+}
 
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
index 0000000..7401dd3
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.c
@@ -0,0 +1,121 @@
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
+#include "objlayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+struct pnfs_client_operations *pnfs_client_ops;
+
+/*
+ * Unmarshall layout and store it in pnfslay.
+ */
+struct pnfs_layout_segment *
+objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
+		     struct nfs4_layoutget_res *lgr)
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
+	__be32 *p;
+	struct objlayout_segment *objlseg = NULL;
+	struct pnfs_osd_layout *pnfs_osd_layout;
+
+	dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
+
+	scratch = alloc_page(GFP_KERNEL);
+	if (!scratch)
+		goto err_nofree;
+
+	xdr_init_decode(&stream, &buf, NULL);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	p = xdr_inline_decode(&stream, pnfs_osd_data_map_xdr_sz() << 2);
+	if (unlikely(!p))
+		goto err;
+
+	objlseg = kzalloc(sizeof(*objlseg) +
+			  pnfs_osd_layout_incore_sz(p), GFP_KERNEL);
+	if (!objlseg)
+		goto err;
+
+	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
+	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, p);
+
+	objlseg->lseg.pls_range = lgr->range;
+	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
+				  pnfs_osd_layout);
+	if (status)
+		goto err;
+
+	__free_page(scratch);
+
+	dprintk("%s: Return %p\n", __func__, &objlseg->lseg);
+	return &objlseg->lseg;
+
+err:
+	kfree(objlseg);
+	__free_page(scratch);
+err_nofree:
+	return ERR_PTR(status);
+}
+
+/*
+ * Free a layout segement
+ */
+void
+objlayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct objlayout_segment *objlseg;
+
+	dprintk("%s: freeing layout segment %p\n", __func__, lseg);
+
+	if (unlikely(!lseg))
+		return;
+
+	objlseg = container_of(lseg, struct objlayout_segment, lseg);
+	objio_free_lseg(objlseg->internal);
+	kfree(objlseg);
+}
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
new file mode 100644
index 0000000..8c0fb1c
--- /dev/null
+++ b/fs/nfs/objlayout/objlayout.h
@@ -0,0 +1,75 @@
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
+ * in-core layout segment
+ */
+struct objlayout_segment {
+	struct pnfs_layout_segment lseg;
+	void *internal;    /* for provider internal use */
+	u8 pnfs_osd_layout[];
+};
+
+/*
+ * Raid engine I/O API
+ */
+extern int objio_alloc_lseg(void **outp,
+	struct pnfs_layout_hdr *pnfslay,
+	struct pnfs_layout_segment *lseg,
+	struct pnfs_osd_layout *layout);
+extern void objio_free_lseg(void *p);
+
+/*
+ * exported generic objects function vectors
+ */
+
+extern struct pnfs_layout_segment *objlayout_alloc_lseg(
+	struct pnfs_layout_hdr *,
+	struct nfs4_layoutget_res *);
+extern void objlayout_free_lseg(struct pnfs_layout_segment *);
+
+#endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index 19228f8..a2a2e91 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -130,3 +130,36 @@ pnfs_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
 		data_map->odm_raid_algorithm);
 	return p;
 }
+
+struct pnfs_osd_layout *
+pnfs_osd_xdr_decode_layout(struct pnfs_osd_layout *layout, __be32 *p)
+{
+	int i;
+	__be32 *start = p;
+	struct pnfs_osd_object_cred *comp;
+	u8 *cred;
+
+	p = pnfs_osd_xdr_decode_data_map(p, &layout->olo_map);
+	READ32(layout->olo_comps_index);
+	READ32(layout->olo_num_comps);
+	layout->olo_comps = (struct pnfs_osd_object_cred *)(layout + 1);
+	comp = layout->olo_comps;
+	cred = (u8 *)(comp + layout->olo_num_comps);
+	dprintk("%s: comps_index=%u num_comps=%u\n",
+		__func__, layout->olo_comps_index, layout->olo_num_comps);
+	for (i = 0; i < layout->olo_num_comps; i++) {
+		p = pnfs_osd_xdr_decode_object_cred(p, comp, &cred);
+		dprintk("%s: comp[%d]=dev(%llx:%llx) par=0x%llx obj=0x%llx "
+			"key_len=%u cap_len=%u\n",
+			__func__, i,
+			_DEVID_LO(&comp->oc_object_id.oid_device_id),
+			_DEVID_HI(&comp->oc_object_id.oid_device_id),
+			comp->oc_object_id.oid_partition_id,
+			comp->oc_object_id.oid_object_id,
+			comp->oc_cap_key.cred_len, comp->oc_cap.cred_len);
+		comp++;
+	}
+	dprintk("%s: xdr_size=%Zd end=%p in_core_size=%Zd\n", __func__,
+	       (char *)p - (char *)start, cred, (char *)cred - (char *)layout);
+	return layout;
+}
-- 
1.7.3.4

