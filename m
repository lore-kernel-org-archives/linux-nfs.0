From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/8] NFS: Try to commit unstable writes in
 nfs_release_page()
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.66278.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164Ab0AYWEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:09 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM48vc004867
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:08 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If someone calls nfs_release_page(), we presumably already know that the
page is clean, however it may be holding an unstable write.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---

 fs/nfs/file.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..63f2071 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -486,6 +486,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 {
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
+	if (gfp & __GFP_WAIT)
+		nfs_wb_page(page->mapping->host, page);
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
 		return 0;

