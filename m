Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51550 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab1JLO5w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Oct 2011 10:57:52 -0400
Received: by vws1 with SMTP id 1so370570vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2011 07:57:51 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: aarcange@redhat.com, harshula@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't try to migrate pages with active requests
Date: Wed, 12 Oct 2011 10:57:42 -0400
Message-Id: <1318431462-8811-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_find_and_lock_request will take a reference to the nfs_page and
will then put it if the req is already locked. It's possible though
that the reference will be the last one. That put then can kick off
a whole series of reference puts:

nfs_page
   nfs_open_context
      dentry
          inode

If the inode ends up being deleted, then the VFS will call
truncate_inode_pages. That function will try to take the page lock, but
it was already locked when migrate_page was called. The code
deadlocks.

Fix this by simply refusing the migration request if PagePrivate is
already set, indicating that the page is already associated with an
active read or write request.

We've had a customer test a backported version of this patch and
the preliminary results seem good.

Cc: stable@kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Harshula Jayasuriya <harshula@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |   36 +++++++++++-------------------------
 1 files changed, 11 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ad6551d..62e6b01 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1690,34 +1690,20 @@ out_error:
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 		struct page *page)
 {
-	struct nfs_page *req;
-	int ret;
+	/*
+	 * If PagePrivate is set, then the page is currently associated with
+	 * an in-progress read or write request. Don't try to migrate it.
+	 *
+	 * FIXME: we could do this in principle, but we'll need a way to ensure
+	 *        that we can safely release the inode reference while holding
+	 *        the page lock.
+	 */
+	if (PagePrivate(page))
+		return -EBUSY;
 
 	nfs_fscache_release_page(page, GFP_KERNEL);
 
-	req = nfs_find_and_lock_request(page, false);
-	ret = PTR_ERR(req);
-	if (IS_ERR(req))
-		goto out;
-
-	ret = migrate_page(mapping, newpage, page);
-	if (!req)
-		goto out;
-	if (ret)
-		goto out_unlock;
-	page_cache_get(newpage);
-	spin_lock(&mapping->host->i_lock);
-	req->wb_page = newpage;
-	SetPagePrivate(newpage);
-	set_page_private(newpage, (unsigned long)req);
-	ClearPagePrivate(page);
-	set_page_private(page, 0);
-	spin_unlock(&mapping->host->i_lock);
-	page_cache_release(page);
-out_unlock:
-	nfs_clear_page_tag_locked(req);
-out:
-	return ret;
+	return migrate_page(mapping, newpage, page);
 }
 #endif
 
-- 
1.7.6.4

