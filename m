From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/5] NFS: Run COMMIT as an asynchronous RPC call when
 wbc->for_background is set
Date: Wed, 06 Jan 2010 23:53:31 -0500
Message-ID: <20100107045331.5986.67844.stgit@localhost.localdomain>
References: <20100107045330.5986.55090.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51398 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab0AGFAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 00:00:44 -0500
In-Reply-To: <20100107045330.5986.55090.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 978de7f..d6d8048 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1423,7 +1423,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
 		mark_inode_unstable_pages(inode);
 		return 0;
 	}
-	if (wbc->nonblocking)
+	if (wbc->nonblocking || wbc->for_background)
 		flags = 0;
 	ret = nfs_commit_inode(inode, flags);
 	if (ret > 0)

