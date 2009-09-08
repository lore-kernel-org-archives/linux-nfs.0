From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 08 Sep 2009 18:05:08 -0400
Message-ID: <20090908220230.7590.69833.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:52948
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751651AbZIHWFJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 18:05:09 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't dive into memory reclaim in the NFS direct I/O paths, otherwise
we can deadlock.

Reported by: Wengang Wang <wen.gang.wang@oracle.com>
Fix-suggested-by: Zach Brown <zach.brown@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Trond-

Thoughts?

 fs/nfs/direct.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e4e089a..00f06b8 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -149,7 +149,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 {
 	struct nfs_direct_req *dreq;
 
-	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_KERNEL);
+	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_NOFS);
 	if (!dreq)
 		return NULL;
 

