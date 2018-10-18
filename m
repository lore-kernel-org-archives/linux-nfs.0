Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726424AbeJSDEN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Oct 2018 23:04:13 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2 v2] nfs: Fix a missed page unlock after pg_doio()
Date: Thu, 18 Oct 2018 15:01:48 -0400
Message-Id: <1da7a5e6280feaf3fe24673cbcf8138571e26fa4.1539889215.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must check pg_error and call error_cleanup after any call to pg_doio.
Currently, we are skipping the unlock of a page if we encounter an error in
nfs_pageio_complete() before handing off the work to the RPC layer.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/pagelist.c | 40 +++++++++++++++++++++-------------------
 1 file changed, 21 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 67d19cd92e44..7e6425791388 100644
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
@@ -1160,25 +1174,11 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
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
-		/* remember fatal errors */
-		if (nfs_error_is_fatal(desc->pg_error))
-			nfs_context_set_write_error(req->wb_context,
-						    desc->pg_error);
-
-		func = desc->pg_completion_ops->error_cleanup;
-		for (midx = 0; midx < desc->pg_mirror_count; midx++) {
-			mirror = &desc->pg_mirrors[midx];
-			func(&mirror->pg_list);
-		}
-	}
+	/* remember fatal errors */
+	if (nfs_error_is_fatal(desc->pg_error))
+		nfs_context_set_write_error(req->wb_context,
+						desc->pg_error);
+	nfs_pageio_error_cleanup(desc);
 	return 0;
 }
 
@@ -1250,6 +1250,8 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 	for (midx = 0; midx < desc->pg_mirror_count; midx++)
 		nfs_pageio_complete_mirror(desc, midx);
 
+	if (desc->pg_error < 0)
+		nfs_pageio_error_cleanup(desc);
 	if (desc->pg_ops->pg_cleanup)
 		desc->pg_ops->pg_cleanup(desc);
 	nfs_pageio_cleanup_mirroring(desc);
-- 
2.14.3
