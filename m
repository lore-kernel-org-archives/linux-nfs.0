From: James Morris <jmorris@namei.org>
Subject: [PATCH] nfs: remove unnecessary NFS_INO_INVALID_ACL checks
Date: Tue, 7 Apr 2009 13:23:20 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0904071319500.16376@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:3859 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbZDGDXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Apr 2009 23:23:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unless I'm mistaken, NFS_INO_INVALID_ACL is being checked twice during 
getacl calls (i.e. first via nfs_revalidate_inode() and then by each all 
site).

---

Remove unnecessary checks for NFS_INO_INVALID_ACL in the NFS v3 & v4
ACL client code, because this is already checked by nfs_revalidate_inode()
which is always called just before these points.
    
Signed-off-by: James Morris <jmorris@namei.org>

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 6bbf0e6..bac6051 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -207,8 +207,6 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 	status = nfs_revalidate_inode(server, inode);
 	if (status < 0)
 		return ERR_PTR(status);
-	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
-		nfs_zap_acl_cache(inode);
 	acl = nfs3_get_cached_acl(inode, type);
 	if (acl != ERR_PTR(-EAGAIN))
 		return acl;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a4d2426..d1c390e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2813,8 +2813,6 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
 	ret = nfs_revalidate_inode(server, inode);
 	if (ret < 0)
 		return ret;
-	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
-		nfs_zap_acl_cache(inode);
 	ret = nfs4_read_cached_acl(inode, buf, buflen);
 	if (ret != -ENOENT)
 		return ret;


-- 
James Morris
<jmorris@namei.org>
