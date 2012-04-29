Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55610 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab2D2Uu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Apr 2012 16:50:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 06/15] NFS: Always trust the PageUptodate flag when we have a delegation
Date: Sun, 29 Apr 2012 16:50:11 -0400
Message-Id: <1335732620-10445-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1335732620-10445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1335732620-10445-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can always use the optimal full page write if we know that we
hold a delegation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/write.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3636191..2be1823 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -839,10 +839,14 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
  * the PageUptodate() flag. In this case, we will need to turn off
  * write optimisations that depend on the page contents being correct.
  */
-static int nfs_write_pageuptodate(struct page *page, struct inode *inode)
+static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 {
-	return PageUptodate(page) &&
-		!(NFS_I(inode)->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA));
+	if (nfs_have_delegated_attributes(inode))
+		goto out;
+	if (NFS_I(inode)->cache_validity & NFS_INO_REVAL_PAGECACHE)
+		return false;
+out:
+	return PageUptodate(page) != 0;
 }
 
 /*
-- 
1.7.7.6

