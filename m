Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:37566 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329AbaDXSPx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:53 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so2632983iec.8
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:53 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 11/18 v2] nfs: allow coalescing of subpage requests
Date: Thu, 24 Apr 2014 14:15:21 -0400
Message-Id: <1398363328-7100-12-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove check that the request covers a whole page.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d57d675..6257f31 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -530,10 +530,6 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		    !nfs_match_lock_context(req->wb_lock_context,
 					    prev->wb_lock_context))
 			return false;
-		if (req->wb_pgbase != 0)
-			return false;
-		if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
-			return false;
 		if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 			return false;
 	}
-- 
1.8.5.2 (Apple Git-48)

