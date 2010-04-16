From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFSv4: Allow attribute caching with 'noac' mounts if client holds a delegation
Date: Fri, 16 Apr 2010 16:47:50 -0400
Message-ID: <1271450871-10777-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271450871-10777-4-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932524Ab0DPUry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:54 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp91008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:54 -0700 (PDT)
In-Reply-To: <1271450871-10777-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server has given us a delegation on a file, we _know_ that we can
cache the attribute information even when the user has specified 'noac'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c  |   15 +++++++++------
 fs/nfs/inode.c |   12 +++++++++---
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8d965bd..cac96bc 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -161,14 +161,17 @@ static int nfs_revalidate_file_size(struct inode *inode, struct file *filp)
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if (server->flags & NFS_MOUNT_NOAC)
-		goto force_reval;
+	if (nfs_have_delegated_attributes(inode))
+		goto out_noreval;
+
 	if (filp->f_flags & O_DIRECT)
 		goto force_reval;
-	if (nfsi->npages != 0)
-		return 0;
-	if (!(nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE) && !nfs_attribute_timeout(inode))
-		return 0;
+	if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
+		goto force_reval;
+	if (nfs_attribute_timeout(inode))
+		goto force_reval;
+out_noreval:
+	return 0;
 force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 50a56ed..69da585 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -730,9 +730,14 @@ int nfs_attribute_timeout(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
+	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
+}
+
+static int nfs_attribute_cache_expired(struct inode *inode)
+{
 	if (nfs_have_delegated_attributes(inode))
 		return 0;
-	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
+	return nfs_attribute_timeout(inode);
 }
 
 /**
@@ -745,7 +750,7 @@ int nfs_attribute_timeout(struct inode *inode)
 int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
 	if (!(NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATTR)
-			&& !nfs_attribute_timeout(inode))
+			&& !nfs_attribute_cache_expired(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
@@ -782,7 +787,8 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 	int ret = 0;
 
 	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-			|| nfs_attribute_timeout(inode) || NFS_STALE(inode)) {
+			|| nfs_attribute_cache_expired(inode)
+			|| NFS_STALE(inode)) {
 		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 		if (ret < 0)
 			goto out;
-- 
1.6.6.1

