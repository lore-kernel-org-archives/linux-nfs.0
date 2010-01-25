From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/12] NFS: Ensure inode is always marked I_DIRTY_DATASYNC,
 if it has unstable pages
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.26454.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:17544 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab0AYWjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:12 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since nfs_scan_list() doesn't wait for locked pages, we have a race in
which it is possible to end up with an inode that needs to send a COMMIT,
but which does not have the I_DIRTY_DATASYNC flag set.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b0b3890..2d78f08 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -573,11 +573,15 @@ static int
 nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int ret;
 
 	if (!nfs_need_commit(nfsi))
 		return 0;
 
-	return nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
+	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
+	if (nfs_need_commit(NFS_I(inode)))
+		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	return ret;
 }
 #else
 static inline int nfs_need_commit(struct nfs_inode *nfsi)

