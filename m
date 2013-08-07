Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13607 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932350Ab3HGU3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 16:29:19 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: William Dauchy <william@gandi.net>, Pascal Bouchareine <pascal@gandi.net>
Subject: [PATCH v2] NFS: Fix writeback performance issue on cache invalidation
Date: Wed, 7 Aug 2013 16:29:13 -0400
Message-ID: <1375907353-19402-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a cache invalidation is triggered, and we happen to have a lot of
writebacks cached at the time, then the call to invalidate_inode_pages2()
will end up calling ->launder_page() on each and every dirty page in order
to sync its contents to disk, thus defeating write coalescing.
The following patch ensures that we try to sync the inode to disk before
calling invalidate_inode_pages2() so that we do the writeback as efficiently
as possible.

Reported-by: William Dauchy <william@gandi.net>
Reported-by: Pascal Bouchareine <pascal@gandi.net>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Tested-by: William Dauchy <william@gandi.net>
---
v2: Add check for regular file as per Jeff Layton's suggestion.

 fs/nfs/inode.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..46ac6a6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -965,7 +965,14 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 	struct nfs_inode *nfsi = NFS_I(inode);
 	
 	if (mapping->nrpages != 0) {
-		int ret = invalidate_inode_pages2(mapping);
+		int ret;
+		
+		if (S_ISREG(inode->i_mode)) {
+			ret = nfs_sync_mapping(mapping);
+			if (ret < 0)
+				return ret;
+		}
+		ret = invalidate_inode_pages2(mapping);
 		if (ret < 0)
 			return ret;
 	}
-- 
1.8.3.1

