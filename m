Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5178 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727245AbeJRACB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Oct 2018 20:02:01 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: Fix a missed page unlock after pg_doio()
Date: Wed, 17 Oct 2018 12:05:38 -0400
Message-Id: <63d8e14cfc732a5224bfd7ecb662f2da4d708ad0.1539792123.git.bcodding@redhat.com>
In-Reply-To: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
References: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
In-Reply-To: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
References: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must check pg_error and call error_cleanup after any call to pg_doio.
Currently, we are skipping the unlock of a page if we encounter an error in
nfs_pageio_complete() before handing off the work to the RPC layer.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index cd3bc41ab68d..54c2bfc45a57 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1110,6 +1110,20 @@ static int nfs_pageio_add_request_mirror(struct nfs_pageio_descriptor *desc,
 	return ret;
 }
 
+static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
+{
+	u32 midx;
+	struct nfs_pgio_mirror *mirror;
+
+	if (!desc->pg_error)
+		return;
+
+	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
+		mirror = &desc->pg_mirrors[midx];
+		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
+	}
+}
+
 int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *req)
 {
@@ -1160,20 +1174,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	return 1;
 
 out_failed:
-	/*
-	 * We might have failed before sending any reqs over wire.
-	 * Clean up rest of the reqs in mirror pg_list.
-	 */
-	if (desc->pg_error) {
-		struct nfs_pgio_mirror *mirror;
-		void (*func)(struct list_head *);
-
-		func = desc->pg_completion_ops->error_cleanup;
-		for (midx = 0; midx < desc->pg_mirror_count; midx++) {
-			mirror = &desc->pg_mirrors[midx];
-			func(&mirror->pg_list);
-		}
-	}
+	nfs_pageio_error_cleanup(desc);
 	return 0;
 }
 
@@ -1245,7 +1246,9 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 	for (midx = 0; midx < desc->pg_mirror_count; midx++)
 		nfs_pageio_complete_mirror(desc, midx);
 
-	if (desc->pg_ops->pg_cleanup)
+	if (desc->pg_error < 0)
+		nfs_pageio_error_cleanup(desc);
+	else if (desc->pg_ops->pg_cleanup)
 		desc->pg_ops->pg_cleanup(desc);
 	nfs_pageio_cleanup_mirroring(desc);
 }
-- 
2.14.3
