From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Fri,  5 Feb 2010 17:43:12 -0500
Message-ID: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933950Ab0BEWnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 17:43:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not having an fscache cookie is perfectly valid if the user didn't mount
with the fscache option.

This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---
 fs/nfs/fscache.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index fa58800..534adb8 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -355,11 +355,11 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
 int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
 	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
-	struct fscache_cookie *cookie = nfsi->fscache;
-
-	BUG_ON(!cookie);
 
 	if (PageFsCache(page)) {
+		struct fscache_cookie *cookie = nfsi->fscache;
+
+		BUG_ON(!cookie);
 		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
 			 cookie, page, nfsi);
 
-- 
1.6.6

