From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] nfsv3: Use inode posix acl cache
Date: Wed,  2 Sep 2009 17:29:48 +0530
Message-ID: <1251892788-497-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:52416 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbZIBL7y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 07:59:54 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82BxsQM008033
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:29:54 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82Bxs1M1970230
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:29:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82Bxrbl006210
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 21:59:54 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch update nfs3 acl caching to use struct inode acl cache.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/inode.c         |    4 --
 fs/nfs/nfs3acl.c       |   82 +++++++++---------------------------------------
 include/linux/nfs_fs.h |    4 --
 3 files changed, 15 insertions(+), 75 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bd7938e..714ed5e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1346,10 +1346,6 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 		return NULL;
 	nfsi->flags = 0UL;
 	nfsi->cache_validity = 0UL;
-#ifdef CONFIG_NFS_V3_ACL
-	nfsi->acl_access = ERR_PTR(-EAGAIN);
-	nfsi->acl_default = ERR_PTR(-EAGAIN);
-#endif
 #ifdef CONFIG_NFS_V4
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index bac6051..8271b3c 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -115,70 +115,13 @@ int nfs3_removexattr(struct dentry *dentry, const char *name)
 	return nfs3_proc_setacl(inode, type, NULL);
 }
 
-static void __nfs3_forget_cached_acls(struct nfs_inode *nfsi)
-{
-	if (!IS_ERR(nfsi->acl_access)) {
-		posix_acl_release(nfsi->acl_access);
-		nfsi->acl_access = ERR_PTR(-EAGAIN);
-	}
-	if (!IS_ERR(nfsi->acl_default)) {
-		posix_acl_release(nfsi->acl_default);
-		nfsi->acl_default = ERR_PTR(-EAGAIN);
-	}
-}
-
 void nfs3_forget_cached_acls(struct inode *inode)
 {
-	dprintk("NFS: nfs3_forget_cached_acls(%s/%ld)\n", inode->i_sb->s_id,
-		inode->i_ino);
-	spin_lock(&inode->i_lock);
-	__nfs3_forget_cached_acls(NFS_I(inode));
-	spin_unlock(&inode->i_lock);
-}
+       dprintk("NFS: nfs3_forget_cached_acls(%s/%ld)\n", inode->i_sb->s_id,
+	       inode->i_ino);
+       forget_cached_acl(inode, ACL_TYPE_DEFAULT);
+       forget_cached_acl(inode, ACL_TYPE_ACCESS);
 
-static struct posix_acl *nfs3_get_cached_acl(struct inode *inode, int type)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct posix_acl *acl = ERR_PTR(-EINVAL);
-
-	spin_lock(&inode->i_lock);
-	switch(type) {
-		case ACL_TYPE_ACCESS:
-			acl = nfsi->acl_access;
-			break;
-
-		case ACL_TYPE_DEFAULT:
-			acl = nfsi->acl_default;
-			break;
-
-		default:
-			goto out;
-	}
-	if (IS_ERR(acl))
-		acl = ERR_PTR(-EAGAIN);
-	else
-		acl = posix_acl_dup(acl);
-out:
-	spin_unlock(&inode->i_lock);
-	dprintk("NFS: nfs3_get_cached_acl(%s/%ld, %d) = %p\n", inode->i_sb->s_id,
-		inode->i_ino, type, acl);
-	return acl;
-}
-
-static void nfs3_cache_acls(struct inode *inode, struct posix_acl *acl,
-		    struct posix_acl *dfacl)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	dprintk("nfs3_cache_acls(%s/%ld, %p, %p)\n", inode->i_sb->s_id,
-		inode->i_ino, acl, dfacl);
-	spin_lock(&inode->i_lock);
-	__nfs3_forget_cached_acls(NFS_I(inode));
-	if (!IS_ERR(acl))
-		nfsi->acl_access = posix_acl_dup(acl);
-	if (!IS_ERR(dfacl))
-		nfsi->acl_default = posix_acl_dup(dfacl);
-	spin_unlock(&inode->i_lock);
 }
 
 struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
@@ -207,8 +150,8 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 	status = nfs_revalidate_inode(server, inode);
 	if (status < 0)
 		return ERR_PTR(status);
-	acl = nfs3_get_cached_acl(inode, type);
-	if (acl != ERR_PTR(-EAGAIN))
+	acl = get_cached_acl(inode, type);
+	if (acl != ACL_NOT_CACHED)
 		return acl;
 	acl = NULL;
 
@@ -259,9 +202,11 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 			res.acl_access = NULL;
 		}
 	}
-	nfs3_cache_acls(inode,
-		(res.mask & NFS_ACL)   ? res.acl_access  : ERR_PTR(-EINVAL),
-		(res.mask & NFS_DFACL) ? res.acl_default : ERR_PTR(-EINVAL));
+
+	if (res.mask & NFS_ACL)
+		set_cached_acl(inode, type, res.acl_access);
+	if (res.mask & NFS_DFACL)
+		set_cached_acl(inode, type, res.acl_default);
 
 	switch(type) {
 		case ACL_TYPE_ACCESS:
@@ -344,7 +289,10 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, &fattr);
-			nfs3_cache_acls(inode, acl, dfacl);
+			if (!IS_ERR(dfacl))
+				set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
+			if (!IS_ERR(acl))
+				set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
 			break;
 		case -EPFNOSUPPORT:
 		case -EPROTONOSUPPORT:
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f6b9024..738758f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -150,10 +150,6 @@ struct nfs_inode {
 	struct rb_root		access_cache;
 	struct list_head	access_cache_entry_lru;
 	struct list_head	access_cache_inode_lru;
-#ifdef CONFIG_NFS_V3_ACL
-	struct posix_acl	*acl_access;
-	struct posix_acl	*acl_default;
-#endif
 
 	/*
 	 * This is the cookie verifier used for NFSv3 readdir
-- 
1.6.4.2.253.g0b1fac

