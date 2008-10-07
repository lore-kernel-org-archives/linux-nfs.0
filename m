From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/30] NFS: Don't clear nfsi->cache_validity in
	nfs_check_inode_attributes()
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.59407.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkwC026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're merely checking the inode attributes because we suspect that the
'updated' attributes returned by the RPC call are stale, then we shouldn't
be doing weak cache consistency updates or clearing the cache_validity
flags.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 697157c..a2f5415 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -905,9 +905,6 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		return -EIO;
 	}
 
-	/* Do atomic weak cache consistency updates */
-	nfs_wcc_update_inode(inode, fattr);
-
 	if ((fattr->valid & NFS_ATTR_FATTR_V4) != 0 &&
 			nfsi->change_attr != fattr->change_attr)
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
@@ -936,10 +933,6 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 
 	if (invalid != 0)
 		nfsi->cache_validity |= invalid;
-	else
-		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ATIME
-				| NFS_INO_REVAL_PAGECACHE);
 
 	nfsi->read_cache_jiffies = fattr->time_start;
 	return 0;

