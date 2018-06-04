Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55226 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751699AbeFDWcA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:32:00 -0400
Received: by mail-it0-f66.google.com with SMTP id 76-v6so999795itx.4
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:59 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.57
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:57 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] NFS: Fix attribute revalidation
Date: Mon,  4 Jun 2018 18:31:26 -0400
Message-Id: <20180604223129.121477-8-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-7-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
 <20180604223129.121477-6-trond.myklebust@hammerspace.com>
 <20180604223129.121477-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't mark attributes as invalid just because they have changed. Instead,
for the purposes of adjusting the attribute cache timeout, keep a
separate variable that tracks whether or not a change occurred.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2b7edd011d86..f35c5eb09cc9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1788,6 +1788,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long save_cache_validity;
 	bool have_writers = nfs_file_has_buffered_writers(nfsi);
 	bool cache_revalidated = true;
+	bool attr_changed = false;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
@@ -1848,8 +1849,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					inode->i_sb->s_id, inode->i_ino);
 			/* Could it be a race with writeback? */
 			if (!have_writers) {
-				invalid |= NFS_INO_INVALID_CHANGE
-					| NFS_INO_INVALID_DATA
+				invalid |= NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL;
 				/* Force revalidate of all attributes */
@@ -1861,6 +1861,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 					nfs_force_lookup_revalidate(inode);
 			}
 			inode_set_iversion_raw(inode, fattr->change_attr);
+			attr_changed = true;
 		}
 	} else {
 		nfsi->cache_validity |= save_cache_validity &
@@ -1899,6 +1900,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				i_size_write(inode, new_isize);
 				if (!have_writers)
 					invalid |= NFS_INO_INVALID_DATA;
+				attr_changed = true;
 			}
 			dprintk("NFS: isize change on server for file %s/%ld "
 					"(%Ld to %Ld)\n",
@@ -1931,14 +1933,12 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			newmode |= fattr->mode & S_IALLUGO;
 			inode->i_mode = newmode;
 			invalid |= NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER;
+				| NFS_INO_INVALID_ACL;
+			attr_changed = true;
 		}
 	} else if (server->caps & NFS_CAP_MODE) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER
+				(NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
@@ -1946,15 +1946,13 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (fattr->valid & NFS_ATTR_FATTR_OWNER) {
 		if (!uid_eq(inode->i_uid, fattr->uid)) {
 			invalid |= NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER;
+				| NFS_INO_INVALID_ACL;
 			inode->i_uid = fattr->uid;
+			attr_changed = true;
 		}
 	} else if (server->caps & NFS_CAP_OWNER) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER
+				(NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
@@ -1962,25 +1960,23 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (fattr->valid & NFS_ATTR_FATTR_GROUP) {
 		if (!gid_eq(inode->i_gid, fattr->gid)) {
 			invalid |= NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER;
+				| NFS_INO_INVALID_ACL;
 			inode->i_gid = fattr->gid;
+			attr_changed = true;
 		}
 	} else if (server->caps & NFS_CAP_OWNER_GROUP) {
 		nfsi->cache_validity |= save_cache_validity &
-				(NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL
-				| NFS_INO_INVALID_OTHER
+				(NFS_INO_INVALID_OTHER
 				| NFS_INO_REVAL_FORCED);
 		cache_revalidated = false;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_NLINK) {
 		if (inode->i_nlink != fattr->nlink) {
-			invalid |= NFS_INO_INVALID_OTHER;
 			if (S_ISDIR(inode->i_mode))
 				invalid |= NFS_INO_INVALID_DATA;
 			set_nlink(inode, fattr->nlink);
+			attr_changed = true;
 		}
 	} else if (server->caps & NFS_CAP_NLINK) {
 		nfsi->cache_validity |= save_cache_validity &
@@ -2000,7 +1996,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 
 	/* Update attrtimeo value if we're out of the unstable period */
-	if (invalid & NFS_INO_INVALID_ATTR) {
+	if (attr_changed) {
 		invalid &= ~NFS_INO_INVALID_ATTR;
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
-- 
2.17.1

