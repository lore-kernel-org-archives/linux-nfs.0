Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727048AbeJRACB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Oct 2018 20:02:01 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: remove redundant call to nfs_context_set_write_error()
Date: Wed, 17 Oct 2018 12:05:37 -0400
Message-Id: <da793f7920f4d263d4a4f47f7f524f3c1eaf59b4.1539792123.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need to call this in the direct, read, or pnfs resend paths and
the only other caller is the write path in nfs_page_async_flush() which
already checks and sets the pg_error on the context.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 67d19cd92e44..cd3bc41ab68d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1168,11 +1168,6 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		struct nfs_pgio_mirror *mirror;
 		void (*func)(struct list_head *);
 
-		/* remember fatal errors */
-		if (nfs_error_is_fatal(desc->pg_error))
-			nfs_context_set_write_error(req->wb_context,
-						    desc->pg_error);
-
 		func = desc->pg_completion_ops->error_cleanup;
 		for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 			mirror = &desc->pg_mirrors[midx];
-- 
2.14.3
