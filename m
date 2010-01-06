From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/6] NFS: Run COMMIT as an asynchronous RPC call when
 wbc->for_background is set
Date: Wed, 06 Jan 2010 15:51:10 -0500
Message-ID: <20100106205110.22547.31434.stgit@localhost.localdomain>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:46744 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932830Ab0AFU7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 15:59:34 -0500
In-Reply-To: <20100106205110.22547.85345.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

