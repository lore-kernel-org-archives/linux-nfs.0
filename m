From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/12] NFS: Reduce the number of unnecessary COMMIT calls
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.17107.stgit@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab0AYWjJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:09 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the caller is doing a non-blocking flush, and there are still writebacks
pending on the wire, we can usually defer the COMMIT call until those
writes are done.

Also ensure that we honour the wbc->nonblocking flag.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e2e7464..0bc1d5b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1409,12 +1409,23 @@ static int nfs_commit_inode(struct inode *inode, int how)
 
 static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
 {
-	int ret;
+	int flags = FLUSH_SYNC;
+	int ret = 0;
 
-	ret = nfs_commit_inode(inode,
-			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
+	/* Don't commit yet if this is a non-blocking flush and there are
+	 * outstanding writes for this mapping.
+	 */
+	if (wbc->sync_mode != WB_SYNC_ALL &&
+	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
+		    NFS_PAGE_TAG_LOCKED))
+		goto out_mark_dirty;
+
+	if (wbc->nonblocking)
+		flags = 0;
+	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0)
 		return 0;
+out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
 }

