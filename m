From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Mon, 08 Feb 2010 09:59:42 -0500
Message-ID: <20100208145942.17581.83842.stgit@localhost.localdomain>
References: <20100208145942.17581.81775.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: David Howells <dhowells@redhat.com>,
	Suresh Jayaraman <sjayaraman@suse.de>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588Ab0BHPCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 10:02:25 -0500
In-Reply-To: <20100208145942.17581.81775.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not having an fscache cookie is perfectly valid if the user didn't mount
with the fscache option.

This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>
Cc: stable@kernel.org
---

 fs/nfs/fscache.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index fa58800..237874f 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -354,12 +354,11 @@ void nfs_fscache_reset_inode_cookie(struct inode *inode)
  */
 int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
-	struct nfs_inode *nfsi = NFS_I(page->mapping->host);
-	struct fscache_cookie *cookie = nfsi->fscache;
-
-	BUG_ON(!cookie);
-
 	if (PageFsCache(page)) {
+		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
+		struct fscache_cookie *cookie = nfsi->fscache;
+
+		BUG_ON(!cookie);
 		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
 			 cookie, page, nfsi);
 

