Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34650 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953563AbdDYUf1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 16:35:27 -0400
Received: by mail-it0-f66.google.com with SMTP id c26so15147946itd.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 13:35:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't write back further requests if there is a pending write error
Date: Tue, 25 Apr 2017 16:35:23 -0400
Message-Id: <20170425203523.37118-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server has already returned a fatal write error that the user
has not yet received on this file, then don't write back the other pages.
Instead, act as if they have been sent, and have returned with the same
error.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 95ac001b6fdf..2e654940478f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -569,6 +569,18 @@ static void nfs_write_error_remove_page(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
+static bool
+nfs_error_is_fatal_on_server(int err)
+{
+	switch (err) {
+	case 0:
+	case -ERESTARTSYS:
+	case -EINTR:
+		return false;
+	}
+	return nfs_error_is_fatal(err);
+}
+
 /*
  * Find an associated nfs write request, and prepare to flush it out
  * May return an error if the user signalled nfs_wait_on_request().
@@ -591,6 +603,10 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
 
 	ret = 0;
+	/* If there is a fatal error that covers this write, just exit */
+	if (nfs_error_is_fatal_on_server(req->wb_context->error))
+		goto out_launder;
+
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
 		/*
@@ -600,10 +616,8 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 		 */
 		if (nfs_error_is_fatal(ret)) {
 			nfs_context_set_write_error(req->wb_context, ret);
-			if (launder) {
-				nfs_write_error_remove_page(req);
-				goto out;
-			}
+			if (launder)
+				goto out_launder;
 		}
 		nfs_redirty_request(req);
 		ret = -EAGAIN;
@@ -612,6 +626,9 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				NFSIOS_WRITEPAGES, 1);
 out:
 	return ret;
+out_launder:
+	nfs_write_error_remove_page(req);
+	return ret;
 }
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
-- 
2.9.3

