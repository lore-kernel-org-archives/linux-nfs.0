From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/32] NFSv4: Add 'server capability' flags for NFSv4
 recommended attributes
Date: Wed, 19 Aug 2009 19:38:26 -0400
Message-ID: <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028AbZHSXkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:51 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNdxmq001600
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:37 -0700 (PDT)
In-Reply-To: <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the NFSv4 server doesn't support a POSIX attribute, the generic NFS code
needs to know that, so that it don't keep trying to poll for it.

However, by the same count, if the NFSv4 server does support that
attribute, then we should ensure that the inode metadata is appropriately
labelled as being untrusted. For instance, if we don't know the correct
value of the file's uid, we should certainly not be caching ACLs or ACCESS
results.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           |    7 ++-
 fs/nfs/inode.c            |   92 ++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/nfs4proc.c         |   22 +++++++++++
 include/linux/nfs_fs_sb.h |    9 ++++
 4 files changed, 114 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8d25ccb..8f34fd8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -809,6 +809,9 @@ static int nfs_init_server(struct nfs_server *server,
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
 	server->options = data->options;
+	server->caps |= NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
+		NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|NFS_CAP_OWNER_GROUP|
+		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
@@ -1274,7 +1277,7 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN;
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
 	server->options = data->options;
 
 	/* Get a client record */
@@ -1400,7 +1403,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Initialise the client representation from the parent server */
 	nfs_server_copy_userdata(server, parent_server);
-	server->caps |= NFS_CAP_ATOMIC_OPEN;
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bd7938e..fe5a8b4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -286,6 +286,11 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		/* We can't support update_atime(), since the server will reset it */
 		inode->i_flags |= S_NOATIME|S_NOCMTIME;
 		inode->i_mode = fattr->mode;
+		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
+				&& nfs_server_capable(inode, NFS_CAP_MODE))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL;
 		/* Why so? Because we want revalidate for devices/FIFOs, and
 		 * that's precisely what we have in nfs_file_inode_operations.
 		 */
@@ -330,20 +335,46 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		nfsi->attr_gencount = fattr->gencount;
 		if (fattr->valid & NFS_ATTR_FATTR_ATIME)
 			inode->i_atime = fattr->atime;
+		else if (nfs_server_capable(inode, NFS_CAP_ATIME))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			inode->i_mtime = fattr->mtime;
+		else if (nfs_server_capable(inode, NFS_CAP_MTIME))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_DATA;
 		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
 			inode->i_ctime = fattr->ctime;
+		else if (nfs_server_capable(inode, NFS_CAP_CTIME))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL;
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			nfsi->change_attr = fattr->change_attr;
+		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_DATA;
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			inode->i_size = nfs_size_to_loff_t(fattr->size);
+		else
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_DATA
+				| NFS_INO_REVAL_PAGECACHE;
 		if (fattr->valid & NFS_ATTR_FATTR_NLINK)
 			inode->i_nlink = fattr->nlink;
+		else if (nfs_server_capable(inode, NFS_CAP_NLINK))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_OWNER)
 			inode->i_uid = fattr->uid;
+		else if (nfs_server_capable(inode, NFS_CAP_OWNER))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL;
 		if (fattr->valid & NFS_ATTR_FATTR_GROUP)
 			inode->i_gid = fattr->gid;
+		else if (nfs_server_capable(inode, NFS_CAP_OWNER_GROUP))
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL;
 		if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
 			inode->i_blocks = fattr->du.nfs2.blocks;
 		if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
@@ -1145,6 +1176,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	loff_t cur_isize, new_isize;
 	unsigned long invalid = 0;
 	unsigned long now = jiffies;
+	unsigned long save_cache_validity;
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
@@ -1171,10 +1203,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	 */
 	nfsi->read_cache_jiffies = fattr->time_start;
 
-	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) || (fattr->valid & (NFS_ATTR_FATTR_MTIME|NFS_ATTR_FATTR_CTIME)))
-	    nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR
-		    | NFS_INO_INVALID_ATIME
-		    | NFS_INO_REVAL_PAGECACHE);
+	save_cache_validity = nfsi->cache_validity;
+	nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR
+			| NFS_INO_INVALID_ATIME
+			| NFS_INO_REVAL_FORCED
+			| NFS_INO_REVAL_PAGECACHE);
 
 	/* Do atomic weak cache consistency updates */
 	nfs_wcc_update_inode(inode, fattr);
@@ -1189,7 +1222,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 			nfsi->change_attr = fattr->change_attr;
 		}
-	}
+	} else if (server->caps & NFS_CAP_CHANGE_ATTR)
+		invalid |= save_cache_validity;
 
 	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
 		/* NFSv2/v3: Check if the mtime agrees */
@@ -1201,7 +1235,12 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 		}
-	}
+	} else if (server->caps & NFS_CAP_MTIME)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_DATA
+				| NFS_INO_REVAL_PAGECACHE
+				| NFS_INO_REVAL_FORCED);
+
 	if (fattr->valid & NFS_ATTR_FATTR_CTIME) {
 		/* If ctime has changed we should definitely clear access+acl caches */
 		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
@@ -1215,7 +1254,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			}
 			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 		}
-	}
+	} else if (server->caps & NFS_CAP_CTIME)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_REVAL_FORCED);
 
 	/* Check if our cached file size is stale */
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
@@ -1231,30 +1274,50 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			dprintk("NFS: isize change on server for file %s/%ld\n",
 					inode->i_sb->s_id, inode->i_ino);
 		}
-	}
+	} else
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_PAGECACHE
+				| NFS_INO_REVAL_FORCED);
 
 
 	if (fattr->valid & NFS_ATTR_FATTR_ATIME)
 		memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
+	else if (server->caps & NFS_CAP_ATIME)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATIME
+				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
 		if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_mode = fattr->mode;
 		}
-	}
+	} else if (server->caps & NFS_CAP_MODE)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_REVAL_FORCED);
+
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
 		if (inode->i_uid != fattr->uid) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_uid = fattr->uid;
 		}
-	}
+	} else if (server->caps & NFS_CAP_OWNER)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_REVAL_FORCED);
+
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
 		if (inode->i_gid != fattr->gid) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 			inode->i_gid = fattr->gid;
 		}
-	}
+	} else if (server->caps & NFS_CAP_OWNER_GROUP)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_INVALID_ACCESS
+				| NFS_INO_INVALID_ACL
+				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
@@ -1263,7 +1326,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				invalid |= NFS_INO_INVALID_DATA;
 			inode->i_nlink = fattr->nlink;
 		}
-	}
+	} else if (server->caps & NFS_CAP_NLINK)
+		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_FORCED);
 
 	if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
 		/*
@@ -1293,9 +1358,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &= ~NFS_INO_INVALID_DATA;
 	if (!nfs_have_delegation(inode, FMODE_READ) ||
-			(nfsi->cache_validity & NFS_INO_REVAL_FORCED))
+			(save_cache_validity & NFS_INO_REVAL_FORCED))
 		nfsi->cache_validity |= invalid;
-	nfsi->cache_validity &= ~NFS_INO_REVAL_FORCED;
 
 	return 0;
  out_changed:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d95f7f9..be6544a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2003,12 +2003,34 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
+		server->caps &= ~(NFS_CAP_ACLS|NFS_CAP_HARDLINKS|
+				NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
+				NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
+				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
+				NFS_CAP_CTIME|NFS_CAP_MTIME);
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
 			server->caps |= NFS_CAP_ACLS;
 		if (res.has_links != 0)
 			server->caps |= NFS_CAP_HARDLINKS;
 		if (res.has_symlinks != 0)
 			server->caps |= NFS_CAP_SYMLINKS;
+		if (res.attr_bitmask[0] & FATTR4_WORD0_FILEID)
+			server->caps |= NFS_CAP_FILEID;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_MODE)
+			server->caps |= NFS_CAP_MODE;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_NUMLINKS)
+			server->caps |= NFS_CAP_NLINK;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_OWNER)
+			server->caps |= NFS_CAP_OWNER;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_OWNER_GROUP)
+			server->caps |= NFS_CAP_OWNER_GROUP;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_ACCESS)
+			server->caps |= NFS_CAP_ATIME;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_METADATA)
+			server->caps |= NFS_CAP_CTIME;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
+			server->caps |= NFS_CAP_MTIME;
+
 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 19fe15d..320569e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -167,6 +167,15 @@ struct nfs_server {
 #define NFS_CAP_SYMLINKS	(1U << 2)
 #define NFS_CAP_ACLS		(1U << 3)
 #define NFS_CAP_ATOMIC_OPEN	(1U << 4)
+#define NFS_CAP_CHANGE_ATTR	(1U << 5)
+#define NFS_CAP_FILEID		(1U << 6)
+#define NFS_CAP_MODE		(1U << 7)
+#define NFS_CAP_NLINK		(1U << 8)
+#define NFS_CAP_OWNER		(1U << 9)
+#define NFS_CAP_OWNER_GROUP	(1U << 10)
+#define NFS_CAP_ATIME		(1U << 11)
+#define NFS_CAP_CTIME		(1U << 12)
+#define NFS_CAP_MTIME		(1U << 13)
 
 
 /* maximum number of slots to use */
-- 
1.6.0.4
