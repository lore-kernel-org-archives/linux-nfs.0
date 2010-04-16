From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/24] NFS: Reduce stack footprint of nfs_revalidate_inode()
Date: Fri, 16 Apr 2010 16:31:09 -0400
Message-ID: <1271449882-8580-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab0DPUba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:30 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl6026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:29 -0700 (PDT)
In-Reply-To: <1271449882-8580-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6e257c3..e20acdd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -682,7 +682,7 @@ int
 __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
 	int		 status = -ESTALE;
-	struct nfs_fattr fattr;
+	struct nfs_fattr *fattr = NULL;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
@@ -693,8 +693,13 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	if (NFS_STALE(inode))
 		goto out;
 
+	status = -ENOMEM;
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		goto out;
+
 	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
-	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr);
+	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -707,7 +712,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 	}
 
-	status = nfs_refresh_inode(inode, &fattr);
+	status = nfs_refresh_inode(inode, fattr);
 	if (status) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
@@ -723,6 +728,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		(long long)NFS_FILEID(inode));
 
  out:
+	nfs_free_fattr(fattr);
 	return status;
 }
 
-- 
1.6.6.1

