From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/30] NFS: Convert __nfs_revalidate_inode() to use
	nfs_refresh_inode()
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.42678.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755928AbYJGWcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:51 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkw4026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:47 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the case where there are parallel RPC calls to the same inode, we may
receive stale metadata due to the lack of ordering, hence the sanity
checking of metadata in nfs_refresh_inode().
Currently, __nfs_revalidate_inode() is calling nfs_update_inode() directly,
without any further sanity checks, and hence may end up setting the inode
up with stale metadata.

Fix is to use nfs_refresh_inode() instead of nfs_update_inode().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 610d022..697157c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -724,16 +724,13 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 	}
 
-	spin_lock(&inode->i_lock);
-	status = nfs_update_inode(inode, &fattr);
+	status = nfs_refresh_inode(inode, &fattr);
 	if (status) {
-		spin_unlock(&inode->i_lock);
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
 		goto out;
 	}
-	spin_unlock(&inode->i_lock);
 
 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);

