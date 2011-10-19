Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab1JSUui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:38 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] NFS: Use the inode->i_version to cache NFSv4 change attribute information
Date: Wed, 19 Oct 2011 13:50:10 -0700
Message-Id: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c    |    2 +-
 fs/nfs/fscache-index.c |    4 ++--
 fs/nfs/inode.c         |   16 ++++++++--------
 fs/nfs/nfs4proc.c      |    4 ++--
 fs/nfs/write.c         |    2 +-
 include/linux/nfs_fs.h |    1 -
 6 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 321a66b..7f26540 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -240,7 +240,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 			sizeof(delegation->stateid.data));
 	delegation->type = res->delegation_type;
 	delegation->maxsize = res->maxsize;
-	delegation->change_attr = nfsi->change_attr;
+	delegation->change_attr = inode->i_version;
 	delegation->cred = get_rpccred(cred);
 	delegation->inode = inode;
 	delegation->flags = 1<<NFS_DELEGATION_REFERENCED;
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 5b10064..7cf2c46 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -212,7 +212,7 @@ static uint16_t nfs_fscache_inode_get_aux(const void *cookie_netfs_data,
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 
 	if (NFS_SERVER(&nfsi->vfs_inode)->nfs_client->rpc_ops->version == 4)
-		auxdata.change_attr = nfsi->change_attr;
+		auxdata.change_attr = nfsi->vfs_inode.i_version;
 
 	if (bufmax > sizeof(auxdata))
 		bufmax = sizeof(auxdata);
@@ -244,7 +244,7 @@ enum fscache_checkaux nfs_fscache_inode_check_aux(void *cookie_netfs_data,
 	auxdata.ctime = nfsi->vfs_inode.i_ctime;
 
 	if (NFS_SERVER(&nfsi->vfs_inode)->nfs_client->rpc_ops->version == 4)
-		auxdata.change_attr = nfsi->change_attr;
+		auxdata.change_attr = nfsi->vfs_inode.i_version;
 
 	if (memcmp(data, &auxdata, datalen) != 0)
 		return FSCACHE_CHECKAUX_OBSOLETE;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..4dc6d07 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -318,7 +318,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		memset(&inode->i_atime, 0, sizeof(inode->i_atime));
 		memset(&inode->i_mtime, 0, sizeof(inode->i_mtime));
 		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
-		nfsi->change_attr = 0;
+		inode->i_version = 0;
 		inode->i_size = 0;
 		inode->i_nlink = 0;
 		inode->i_uid = -2;
@@ -344,7 +344,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 				| NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL;
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
-			nfsi->change_attr = fattr->change_attr;
+			inode->i_version = fattr->change_attr;
 		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
 			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
 				| NFS_INO_INVALID_DATA;
@@ -897,8 +897,8 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECHANGE)
 			&& (fattr->valid & NFS_ATTR_FATTR_CHANGE)
-			&& nfsi->change_attr == fattr->pre_change_attr) {
-		nfsi->change_attr = fattr->change_attr;
+			&& inode->i_version == fattr->pre_change_attr) {
+		inode->i_version = fattr->change_attr;
 		if (S_ISDIR(inode->i_mode))
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		ret |= NFS_INO_INVALID_ATTR;
@@ -952,7 +952,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 		return -EIO;
 
 	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
-			nfsi->change_attr != fattr->change_attr)
+			inode->i_version != fattr->change_attr)
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
 
 	/* Verify a few of the more important attributes */
@@ -1163,7 +1163,7 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
 			(fattr->valid & NFS_ATTR_FATTR_PRECHANGE) == 0) {
-		fattr->pre_change_attr = NFS_I(inode)->change_attr;
+		fattr->pre_change_attr = inode->i_version;
 		fattr->valid |= NFS_ATTR_FATTR_PRECHANGE;
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_CTIME) != 0 &&
@@ -1244,13 +1244,13 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	/* More cache consistency checks */
 	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
-		if (nfsi->change_attr != fattr->change_attr) {
+		if (inode->i_version != fattr->change_attr) {
 			dprintk("NFS: change_attr change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			if (S_ISDIR(inode->i_mode))
 				nfs_force_lookup_revalidate(inode);
-			nfsi->change_attr = fattr->change_attr;
+			inode->i_version = fattr->change_attr;
 		}
 	} else if (server->caps & NFS_CAP_CHANGE_ATTR)
 		invalid |= save_cache_validity;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..0f0b607 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -753,9 +753,9 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 
 	spin_lock(&dir->i_lock);
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_DATA;
-	if (!cinfo->atomic || cinfo->before != nfsi->change_attr)
+	if (!cinfo->atomic || cinfo->before != dir->i_version)
 		nfs_force_lookup_revalidate(dir);
-	nfsi->change_attr = cinfo->after;
+	dir->i_version = cinfo->after;
 	spin_unlock(&dir->i_lock);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 106fd06..2084a64 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -390,7 +390,7 @@ static int nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	error = radix_tree_insert(&nfsi->nfs_page_tree, req->wb_index, req);
 	BUG_ON(error);
 	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
-		nfsi->change_attr++;
+		inode->i_version++;
 	set_bit(PG_MAPPED, &req->wb_flags);
 	SetPagePrivate(req->wb_page);
 	set_page_private(req->wb_page, (unsigned long)req);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index eaac770..60a137b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -149,7 +149,6 @@ struct nfs_inode {
 	unsigned long		read_cache_jiffies;
 	unsigned long		attrtimeo;
 	unsigned long		attrtimeo_timestamp;
-	__u64			change_attr;		/* v4 only */
 
 	unsigned long		attr_gencount;
 	/* "Generation counter" for the attribute cache. This is
-- 
1.7.6.4

