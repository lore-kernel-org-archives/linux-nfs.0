Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57620 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab2HCN3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Aug 2012 09:29:16 -0400
Received: by yenl2 with SMTP id l2so818694yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 03 Aug 2012 06:29:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: makc@redhat.com
Subject: [PATCH RFC] nfs: allow coalescing of read/write requests under more circumstances
Date: Fri,  3 Aug 2012 09:29:10 -0400
Message-Id: <1344000550-25356-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is an RFC for dealing with a regression in write performance
when there are multiple processes doing I/O to the same pages on the
same machine. Earlier this week, I outlined the problem here:

    http://www.spinics.net/lists/linux-nfs/msg31728.html

This patch seems to resolve the problem, but I still haven't quite
convinced myself that this approach is race-free. Thoughts?

-------------------[snip]------------------

Currently, we don't allow adjacent read or write requests to be
coalesced when I/O is being done on the file by different lockowners.
When there is no locking involved however or on v2/3 mounts, I don't
see any reason not to allow it.

With v4 and no locks, the I/O will be done using the same stateid
regardless of the lockowner. With v2/3 there is no stateid to worry
about so the lockowner shouldn't make any difference.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/pagelist.c | 15 ++++++++++-----
 fs/nfs/write.c    | 31 ++++++++++++++++++++++++++-----
 2 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 1a6732e..cf2913d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -286,11 +286,9 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 				      struct nfs_page *req,
 				      struct nfs_pageio_descriptor *pgio)
 {
-	if (req->wb_context->cred != prev->wb_context->cred)
-		return false;
-	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
-		return false;
-	if (req->wb_context->state != prev->wb_context->state)
+	struct nfs_open_context *ctx = req->wb_context;
+
+	if (ctx->cred != prev->wb_context->cred)
 		return false;
 	if (req->wb_pgbase != 0)
 		return false;
@@ -298,6 +296,13 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		return false;
 	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 		return false;
+	if (ctx->state != prev->wb_context->state)
+		return false;
+	if (!ctx->state || list_empty(&ctx->state->lock_states))
+		goto out;
+	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
+		return false;
+out:
 	return pgio->pg_ops->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3b5537..8175cfa 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -843,11 +843,34 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 	return 0;
 }
 
-int nfs_flush_incompatible(struct file *file, struct page *page)
+/*
+ * Decide whether a pending write to an existing dirty page is incompatible
+ * with what's already there.
+ */
+static bool
+should_flush(struct file *file, struct page *page, struct nfs_page *req)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
+
+	if (req->wb_page != page)
+		return true;
+	if (req->wb_context != ctx)
+		return true;
+	if (!ctx->state || list_empty(&ctx->state->lock_states))
+		return false;
+	if (req->wb_lock_context->lockowner != current->files)
+		return true;
+	if (req->wb_lock_context->pid != current->tgid)
+		return true;
+
+	return false;
+}
+
+int nfs_flush_incompatible(struct file *file, struct page *page)
+{
 	struct nfs_page	*req;
-	int do_flush, status;
+	int status;
+	bool do_flush;
 	/*
 	 * Look for a request corresponding to this page. If there
 	 * is one, and it belongs to another file, we flush it out
@@ -860,9 +883,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx ||
-			req->wb_lock_context->lockowner != current->files ||
-			req->wb_lock_context->pid != current->tgid;
+		do_flush = should_flush(file, page, req);
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-- 
1.7.11.2

