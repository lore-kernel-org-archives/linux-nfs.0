From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/12] NFS: Run COMMIT as an asynchronous RPC call when
 wbc->for_background is set
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.29827.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:17541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab0AYWjJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:09 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---

 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9feafab..b0b3890 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1420,7 +1420,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 		    NFS_PAGE_TAG_LOCKED))
 		goto out_mark_dirty;
 
-	if (wbc->nonblocking)
+	if (wbc->nonblocking || wbc->for_background)
 		flags = 0;
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0)

