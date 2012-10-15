Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22096 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:11 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/13] NFSv4.1: Remove unused function last_byte_offset
Date: Mon, 15 Oct 2012 17:30:58 -0400
Message-Id: <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/objlayout/objlayout.c | 11 -----------
 fs/nfs/pnfs.c                | 11 -----------
 2 files changed, 22 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 8746135..a9ebd81 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -148,17 +148,6 @@ end_offset(u64 start, u64 len)
 	return end >= start ? end : NFS4_MAX_UINT64;
 }
 
-/* last octet in a range */
-static inline u64
-last_byte_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	BUG_ON(!len);
-	end = start + len;
-	return end > start ? end - 1 : NFS4_MAX_UINT64;
-}
-
 static void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
 			   struct page ***p_pages, unsigned *p_pgbase,
 			   u64 offset, unsigned long count)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fe624c9..43e4ad8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -369,17 +369,6 @@ end_offset(u64 start, u64 len)
 	return end >= start ? end : NFS4_MAX_UINT64;
 }
 
-/* last octet in a range */
-static inline u64
-last_byte_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	BUG_ON(!len);
-	end = start + len;
-	return end > start ? end - 1 : NFS4_MAX_UINT64;
-}
-
 /*
  * is l2 fully contained in l1?
  *   start1                             end1
-- 
1.7.11.7

