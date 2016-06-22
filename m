Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36800 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbcFVUs0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 16:48:26 -0400
Received: by mail-io0-f193.google.com with SMTP id s63so9104460ioi.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2016 13:48:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/13] NFS: Don't call COMMIT in ->releasepage()
Date: Wed, 22 Jun 2016 16:47:42 -0400
Message-Id: <1466628468-3958-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466628468-3958-6-git-send-email-trond.myklebust@primarydata.com>
References: <1466628468-3958-1-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-2-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-3-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-4-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-5-git-send-email-trond.myklebust@primarydata.com>
 <1466628468-3958-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While COMMIT has the potential to free up a lot of memory that is being
taken by unstable writes, it isn't guaranteed to free up this particular
page. Also, calling fsync() on the server is expensive and so we want to
do it in a more controlled fashion, rather than have it triggered at
random by the VM.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c | 23 -----------------------
 1 file changed, 23 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 249262b6bcbe..df4dd8e7e62e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -460,31 +460,8 @@ static void nfs_invalidate_page(struct page *page, unsigned int offset,
  */
 static int nfs_release_page(struct page *page, gfp_t gfp)
 {
-	struct address_space *mapping = page->mapping;
-
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
-	/* Always try to initiate a 'commit' if relevant, but only
-	 * wait for it if the caller allows blocking.  Even then,
-	 * only wait 1 second and only if the 'bdi' is not congested.
-	 * Waiting indefinitely can cause deadlocks when the NFS
-	 * server is on this machine, when a new TCP connection is
-	 * needed and in other rare cases.  There is no particular
-	 * need to wait extensively here.  A short wait has the
-	 * benefit that someone else can worry about the freezer.
-	 */
-	if (mapping) {
-		struct nfs_server *nfss = NFS_SERVER(mapping->host);
-		nfs_commit_inode(mapping->host, 0);
-		if (gfpflags_allow_blocking(gfp) &&
-		    !bdi_write_congested(&nfss->backing_dev_info)) {
-			wait_on_page_bit_killable_timeout(page, PG_private,
-							  HZ);
-			if (PagePrivate(page))
-				set_bdi_congested(&nfss->backing_dev_info,
-						  BLK_RW_ASYNC);
-		}
-	}
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
 		return 0;
-- 
2.7.4

