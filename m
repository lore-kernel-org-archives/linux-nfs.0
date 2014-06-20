Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966820AbaFTMop (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jun 2014 08:44:45 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Fix cache_validity check in nfs_write_pageuptodate()
Date: Fri, 20 Jun 2014 08:44:42 -0400
Message-Id: <1403268282-29610-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_INO_INVALID_DATA cannot be ignored, even if we have a delegation.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/write.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3ee5af4..98ff061 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -934,12 +934,14 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 
 	if (nfs_have_delegated_attributes(inode))
 		goto out;
-	if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
+	if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
 		return false;
 	smp_rmb();
 	if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
 		return false;
 out:
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+		return false;
 	return PageUptodate(page) != 0;
 }
 
-- 
1.9.3

