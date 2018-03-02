Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:48838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1946608AbeCBQAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Mar 2018 11:00:39 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode has outstanding requests
Date: Fri,  2 Mar 2018 11:00:38 -0500
Message-Id: <20180302160038.1598-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems that nfs_commit_inode can be called where the nfs_inode has
outstanding requests and the commit lists are empty.  That can lead to
invalidate_complete_page2 failing due to the associated page having
private data which in turn leads to invalidate_inode_pages2_range
returning -EBUSY.

Instead of having nfs_commit_inode exit early when the commit lists are
empty, only do so if nrequests is also 0.

Fixes: dc4fd9ab01 ("nfs: don't wait on commit in nfs_commit_inode() if there were no commit requests")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7428a66..0268bd1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1890,7 +1890,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 	if (res)
 		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
 	nfs_commit_end(cinfo.mds);
-	if (res == 0)
+	if (res == 0 && !nfs_have_writebacks(inode))
 		return res;
 	if (error < 0)
 		goto out_error;
-- 
2.9.5

