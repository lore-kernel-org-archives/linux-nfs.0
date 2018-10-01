Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:54897 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729497AbeJAVUj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:39 -0400
Received: by mail-it1-f194.google.com with SMTP id l191-v6so6018553ita.4
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:30 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 12/15] knfsd: Remove dead code from nfsd_cache_lookup
Date: Mon,  1 Oct 2018 10:41:54 -0400
Message-Id: <20181001144157.3515-13-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-12-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
 <20181001144157.3515-11-trond.myklebust@hammerspace.com>
 <20181001144157.3515-12-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The preallocated cache entry is always set to type RC_NOCACHE, and that
type isn't changed until we later call nfsd_cache_update().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/nfscache.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index dbdeb9d6af03..cef4686f87ef 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -446,14 +446,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp->c_csum = csum;
 
 	lru_put_end(b, rp);
-
-	/* release any buffer */
-	if (rp->c_type == RC_REPLBUFF) {
-		drc_mem_usage -= rp->c_replvec.iov_len;
-		kfree(rp->c_replvec.iov_base);
-		rp->c_replvec.iov_base = NULL;
-	}
-	rp->c_type = RC_NOCACHE;
  out:
 	spin_unlock(&b->cache_lock);
 	return rtn;
-- 
2.17.1
