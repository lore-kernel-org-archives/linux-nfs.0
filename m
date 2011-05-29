Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51059 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758Ab1E2SaR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:30:17 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 32/32] pnfs-obj: pg_test check for max_io_size
Date: Sun, 29 May 2011 21:30:06 +0300
Message-Id: <1306693806-8608-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implement pg_test vector to test for max IO sizes. We calculate
a max_io_size member only once, and cache it in lseg so to not
do so on every page insert.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[simplify logic]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 3b10d09..9cf208d 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -128,6 +128,8 @@ struct objio_segment {
 	u64 group_depth;
 	unsigned group_count;
 
+	unsigned max_io_size;
+
 	unsigned comps_index;
 	unsigned num_comps;
 	/* variable length */
@@ -365,6 +367,11 @@ int objio_alloc_lseg(struct pnfs_layout_segment **outp,
 		objio_seg->group_count = 1;
 	}
 
+	/* Cache this calculation it will hit for every page */
+	objio_seg->max_io_size = (BIO_MAX_PAGES_KMALLOC * PAGE_SIZE -
+				  objio_seg->stripe_unit) *
+				 objio_seg->group_width;
+
 	*outp = &objio_seg->lseg;
 	return 0;
 
@@ -988,6 +995,16 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 	return _write_exec(ios);
 }
 
+static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
+			  struct nfs_page *prev, struct nfs_page *req)
+{
+	if (!pnfs_generic_pg_test(pgio, prev, req))
+		return false;
+
+	return pgio->pg_count + req->wb_bytes <=
+			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
+}
+
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
@@ -1001,7 +1018,7 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
-	.pg_test                 = pnfs_generic_pg_test,
+	.pg_test                 = objio_pg_test,
 
 	.free_deviceid_node	 = objio_free_deviceid_node,
 
-- 
1.7.2.3

