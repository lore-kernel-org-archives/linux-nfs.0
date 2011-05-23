Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9112 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325Ab1EWQiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:38:02 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 18/26] pnfs-obj: define per-inode private structure
Date: Mon, 23 May 2011 19:37:53 +0300
Message-Id: <1306168673-11613-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

allocate and deallocate per-inode private pnfs_layout_hdr
in preparation for I/O implementation.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |    3 +++
 fs/nfs/objlayout/objlayout.c |   26 ++++++++++++++++++++++++++
 fs/nfs/objlayout/objlayout.h |   17 +++++++++++++++++
 3 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index a4201d8..a71f58e 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -352,6 +352,9 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
 
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
 	.alloc_lseg              = objlayout_alloc_lseg,
 	.free_lseg               = objlayout_free_lseg,
 
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 10e5fca..f14b4da 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -42,6 +42,32 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 /*
+ * Create a objlayout layout structure for the given inode and return it.
+ */
+struct pnfs_layout_hdr *
+objlayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
+{
+	struct objlayout *objlay;
+
+	objlay = kzalloc(sizeof(struct objlayout), gfp_flags);
+	dprintk("%s: Return %p\n", __func__, objlay);
+	return &objlay->pnfs_layout;
+}
+
+/*
+ * Free an objlayout layout structure
+ */
+void
+objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct objlayout *objlay = OBJLAYOUT(lo);
+
+	dprintk("%s: objlay %p\n", __func__, objlay);
+
+	kfree(objlay);
+}
+
+/*
  * Unmarshall layout and store it in pnfslay.
  */
 struct pnfs_layout_segment *
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 0814271..fa02621 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -46,6 +46,19 @@
 #include "../pnfs.h"
 
 /*
+ * per-inode layout
+ */
+struct objlayout {
+	struct pnfs_layout_hdr pnfs_layout;
+};
+
+static inline struct objlayout *
+OBJLAYOUT(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct objlayout, pnfs_layout);
+}
+
+/*
  * Raid engine I/O API
  */
 extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
@@ -66,6 +79,10 @@ extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
 /*
  * exported generic objects function vectors
  */
+
+extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *, gfp_t gfp_flags);
+extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
+
 extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct pnfs_layout_hdr *,
 	struct nfs4_layoutget_res *,
-- 
1.7.3.4

