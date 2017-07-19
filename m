Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36421 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755520AbdGSWKN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:13 -0400
Received: by mail-it0-f68.google.com with SMTP id r9so27547ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 11/20] NFS: Remove page group limit in nfs_flush_incompatible()
Date: Wed, 19 Jul 2017 18:09:46 -0400
Message-Id: <20170719220955.58210-12-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-11-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
 <20170719220955.58210-8-trond.myklebust@primarydata.com>
 <20170719220955.58210-9-trond.myklebust@primarydata.com>
 <20170719220955.58210-10-trond.myklebust@primarydata.com>
 <20170719220955.58210-11-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_try_to_update_request() should be able to cope now.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b4d1ef168e0..08c1ce968cce 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1205,8 +1205,6 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		l_ctx = req->wb_lock_context;
 		do_flush = req->wb_page != page ||
 			!nfs_match_open_context(req->wb_context, ctx);
-		/* for now, flush if more than 1 request in page_group */
-		do_flush |= req->wb_this_page != req;
 		if (l_ctx && flctx &&
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock))) {
-- 
2.13.3

