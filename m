Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:51330 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3IZF4S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 01:56:18 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so673222pdj.36
        for <linux-nfs@vger.kernel.org>; Wed, 25 Sep 2013 22:56:18 -0700 (PDT)
From: Olof Johansson <olof@lixom.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Olof Johansson <olof@lixom.net>
Subject: [PATCH] NFS: Don't use debug-printk-only local variables
Date: Wed, 25 Sep 2013 22:56:48 -0700
Message-Id: <1380175008-13090-1-git-send-email-olof@lixom.net>
In-Reply-To: <20130920150927.16220.33305.stgit@warthog.procyon.org.uk>
References: <20130920150927.16220.33305.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Due to commit 996a2493ed5d3a8d5db03b560fcbbf1ca3f10897 (NFS:
Use i_writecount to control whether to get an fscache cookie in
nfs_open(), in two instances a local variable is only used in debug
print statements. Said statements might be compiled out, which results
in unused variable warnings:

fs/nfs/fscache.c: In function 'nfs_fscache_release_page':
fs/nfs/fscache.c:263:21: warning: unused variable 'nfsi' [-Wunused-variable]

fs/nfs/fscache.c: In function '__nfs_fscache_invalidate_page':
fs/nfs/fscache.c:286:20: warning: unused variable 'nfsi' [-Wunused-variable]

Just skip the local variable in these cases.

Signed-off-by: Olof Johansson <olof@lixom.net>
---

David,

This showed up in today's linux-next, seems to have come in through the fscache tree.

Either amend and roll in the fix (after review -- I'm guessing this is the right thing to do), or apply on top please. :)


Thanks!


-Olof

 fs/nfs/fscache.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index a01af20..3ef01f0 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -260,12 +260,11 @@ EXPORT_SYMBOL_GPL(nfs_fscache_open_file);
 int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
 	if (PageFsCache(page)) {
-		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
 		struct fscache_cookie *cookie = nfs_i_fscache(page->mapping->host);
 
 		BUG_ON(!cookie);
 		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
-			 cookie, page, nfsi);
+			 cookie, page, NFS_I(page->mapping->host));
 
 		if (!fscache_maybe_release_page(cookie, page, gfp))
 			return 0;
@@ -283,13 +282,12 @@ int nfs_fscache_release_page(struct page *page, gfp_t gfp)
  */
 void __nfs_fscache_invalidate_page(struct page *page, struct inode *inode)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
 	BUG_ON(!cookie);
 
 	dfprintk(FSCACHE, "NFS: fscache invalidatepage (0x%p/0x%p/0x%p)\n",
-		 cookie, page, nfsi);
+		 cookie, page, NFS_I(inode));
 
 	fscache_wait_on_page_write(cookie, page);
 
-- 
1.7.10.4

