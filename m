Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:40818 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172AbaEOP5Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:57:25 -0400
Received: by mail-ig0-f176.google.com with SMTP id hl10so8102870igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2014 08:57:24 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 11/18] nfs: allow coalescing of subpage requests
Date: Thu, 15 May 2014 11:56:50 -0400
Message-Id: <1400169417-28245-12-git-send-email-dros@primarydata.com>
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove check that the request covers a whole page.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ce3faad..44aef5a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -922,10 +922,6 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
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

