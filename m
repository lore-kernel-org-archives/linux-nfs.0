Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34360 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbbLaTLD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Dec 2015 14:11:03 -0500
Received: by mail-io0-f175.google.com with SMTP id 1so53059158ion.1
        for <linux-nfs@vger.kernel.org>; Thu, 31 Dec 2015 11:11:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFS: Relax requirements in nfs_flush_incompatible
Date: Thu, 31 Dec 2015 14:10:26 -0500
Message-Id: <1451589026-50874-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451589026-50874-3-git-send-email-trond.myklebust@primarydata.com>
References: <1451589026-50874-1-git-send-email-trond.myklebust@primarydata.com>
 <1451589026-50874-2-git-send-email-trond.myklebust@primarydata.com>
 <1451589026-50874-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If two processes share the same credentials and NFSv4 open stateid, then
allow them both to dirty the same page, even if their nfs_open_context
differs.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h | 6 ++++++
 fs/nfs/pagelist.c | 6 ------
 fs/nfs/write.c    | 3 ++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 99a2919047e9..870e2ba7ba49 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -264,6 +264,12 @@ static inline bool nfs_pgio_has_mirroring(struct nfs_pageio_descriptor *desc)
 	return desc->pg_mirror_count > 1;
 }
 
+static inline bool nfs_match_open_context(const struct nfs_open_context *ctx1,
+		const struct nfs_open_context *ctx2)
+{
+	return ctx1->cred == ctx2->cred && ctx1->state == ctx2->state;
+}
+
 /* nfs2xdr.c */
 extern struct rpc_procinfo nfs_procedures[];
 extern int nfs2_decode_dirent(struct xdr_stream *,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 452a011ba0d8..c3a78450a239 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -903,12 +903,6 @@ static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
 	pgio->pg_mirrors_dynamic = NULL;
 }
 
-static bool nfs_match_open_context(const struct nfs_open_context *ctx1,
-		const struct nfs_open_context *ctx2)
-{
-	return ctx1->cred == ctx2->cred && ctx1->state == ctx2->state;
-}
-
 static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
 		const struct nfs_lock_context *l2)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9c9d3e7a2452..83348db2fac7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1130,7 +1130,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		if (req == NULL)
 			return 0;
 		l_ctx = req->wb_lock_context;
-		do_flush = req->wb_page != page || req->wb_context != ctx;
+		do_flush = req->wb_page != page ||
+			!nfs_match_open_context(req->wb_context, ctx);
 		/* for now, flush if more than 1 request in page_group */
 		do_flush |= req->wb_this_page != req;
 		if (l_ctx && flctx &&
-- 
2.5.0

