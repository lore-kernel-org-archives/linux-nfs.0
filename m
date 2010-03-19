From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Prevent another deadlock in nfs_release_page()
Date: Fri, 19 Mar 2010 15:35:10 -0400
Message-ID: <1269027310.10771.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40630 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab0CSTfy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Mar 2010 15:35:54 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o2JJZnRt003399
	for <linux-nfs@vger.kernel.org>; Fri, 19 Mar 2010 12:35:54 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

We should not attempt to free the page if __GFP_FS is not set. Otherwise we
can deadlock as per

  http://bugzilla.kernel.org/show_bug.cgi?id=15578

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index ae8d022..ae0d927 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -491,7 +491,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 {
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
-	if (gfp & __GFP_WAIT)
+	/* Only do I/O if gfp is a superset of GFP_KERNEL */
+	if ((gfp & GFP_KERNEL) == GFP_KERNEL)
 		nfs_wb_page(page->mapping->host, page);
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))

