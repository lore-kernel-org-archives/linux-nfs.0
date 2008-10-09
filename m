From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/4] NFS: Fix attribute updates
Date: Thu, 09 Oct 2008 15:00:32 -0400
Message-ID: <20081009190032.18388.28735.stgit@localhost.localdomain>
References: <20081009190031.18388.95039.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27367 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760757AbYJITEi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 15:04:38 -0400
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m99J4Y9i007125
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 12:04:37 -0700 (PDT)
In-Reply-To: <20081009190031.18388.95039.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes a regression seen when running the Connectathon testsuite
against an ext3 filesystem. The reason was that the inode was constantly
being marked as 'just updated' by the jiffy wraparound test.
This again meant that newer GETATTR calls were failing to pass the
nfs_inode_attrs_need_update() test unless the changes caused a ctime update
on the server, since they were perceived as having been started before the
latest inode update.

Given that nfs_inode_attrs_need_update() already checks for wraparound
of nfsi->last_updated, we can drop the buggy "protection" in
nfs_update_inode().

Also make a slight micro-optimisation of nfs_inode_attrs_need_update(): we
are more often going to see time_after(fattr->time_start, nfsi->last_updated)
be true, rather than seeing an update of ctime/size, so put that test
first to ensure that we optimise away the ctime/size tests.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e25009f..6554281 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -933,10 +933,10 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 {
 	const struct nfs_inode *nfsi = NFS_I(inode);
 
-	return nfs_ctime_need_update(inode, fattr) ||
-			nfs_size_need_update(inode, fattr) ||
-			time_after(fattr->time_start, nfsi->last_updated) ||
-			time_after(nfsi->last_updated, jiffies);
+	return time_after(fattr->time_start, nfsi->last_updated) ||
+		nfs_ctime_need_update(inode, fattr) ||
+		nfs_size_need_update(inode, fattr) ||
+		time_after(nfsi->last_updated, jiffies);
 }
 
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
@@ -1167,11 +1167,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
 			nfsi->attrtimeo_timestamp = now;
 		}
-		/*
-		 * Avoid jiffy wraparound issues with nfsi->last_updated
-		 */
-		if (!time_in_range(nfsi->last_updated, nfsi->read_cache_jiffies, now))
-			nfsi->last_updated = nfsi->read_cache_jiffies;
 	}
 	invalid &= ~NFS_INO_INVALID_ATTR;
 	/* Don't invalidate the data if we were to blame */

