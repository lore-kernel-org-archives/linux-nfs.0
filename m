Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21264 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332Ab1FJOFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jun 2011 10:05:03 -0400
Date: Fri, 10 Jun 2011 22:04:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
Message-ID: <20110610140459.GA8021@localhost>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It's confusing to return success while redirtying the inode at the
same time in ->write_inode(). Return -EAGAIN to indicate that we've
not finished with this inode.

Impact: it's a cleanup, not bug fix.

CC: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/fs/nfs/write.c	2011-06-10 21:52:34.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-06-10 21:52:37.000000000 +0800
@@ -1521,7 +1521,7 @@ static int nfs_commit_unstable_pages(str
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int flags = FLUSH_SYNC;
-	int ret = 0;
+	int ret = -EAGAIN;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there
