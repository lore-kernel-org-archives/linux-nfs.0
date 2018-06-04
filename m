Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:39992 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbeFDWb6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:58 -0400
Received: by mail-it0-f65.google.com with SMTP id j186-v6so984014ita.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:58 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:56 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] NFS: fix up nfs_setattr_update_inode
Date: Mon,  4 Jun 2018 18:31:25 -0400
Message-Id: <20180604223129.121477-7-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-6-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
 <20180604223129.121477-4-trond.myklebust@hammerspace.com>
 <20180604223129.121477-5-trond.myklebust@hammerspace.com>
 <20180604223129.121477-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Always try to set the attributes, even if we don't have a valid struct
nfs_fattr.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 48 ++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 42 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a720427e5aa3..2b7edd011d86 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -671,9 +671,13 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 
 	spin_lock(&inode->i_lock);
 	NFS_I(inode)->attr_gencount = fattr->gencount;
-	nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE
-			| NFS_INO_INVALID_CTIME);
+	if ((attr->ia_valid & ATTR_SIZE) != 0) {
+		nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
+		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
+		nfs_vmtruncate(inode, attr->ia_size);
+	}
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0) {
+		NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_CTIME;
 		if ((attr->ia_valid & ATTR_MODE) != 0) {
 			int mode = attr->ia_mode & S_IALLUGO;
 			mode |= inode->i_mode & ~S_IALLUGO;
@@ -683,13 +687,45 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 			inode->i_uid = attr->ia_uid;
 		if ((attr->ia_valid & ATTR_GID) != 0)
 			inode->i_gid = attr->ia_gid;
+		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
+			inode->i_ctime = fattr->ctime;
+		else
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE
+					| NFS_INO_INVALID_CTIME);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_ACCESS
 				| NFS_INO_INVALID_ACL);
 	}
-	if ((attr->ia_valid & ATTR_SIZE) != 0) {
-		nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
-		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
-		nfs_vmtruncate(inode, attr->ia_size);
+	if (attr->ia_valid & (ATTR_ATIME_SET|ATTR_ATIME)) {
+		NFS_I(inode)->cache_validity &= ~(NFS_INO_INVALID_ATIME
+				| NFS_INO_INVALID_CTIME);
+		if (fattr->valid & NFS_ATTR_FATTR_ATIME)
+			inode->i_atime = fattr->atime;
+		else if (attr->ia_valid & ATTR_ATIME_SET)
+			inode->i_atime = attr->ia_atime;
+		else
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATIME);
+
+		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
+			inode->i_ctime = fattr->ctime;
+		else
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE
+					| NFS_INO_INVALID_CTIME);
+	}
+	if (attr->ia_valid & (ATTR_MTIME_SET|ATTR_MTIME)) {
+		NFS_I(inode)->cache_validity &= ~(NFS_INO_INVALID_MTIME
+				| NFS_INO_INVALID_CTIME);
+		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
+			inode->i_mtime = fattr->mtime;
+		else if (attr->ia_valid & ATTR_MTIME_SET)
+			inode->i_mtime = attr->ia_mtime;
+		else
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
+
+		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
+			inode->i_ctime = fattr->ctime;
+		else
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_CHANGE
+					| NFS_INO_INVALID_CTIME);
 	}
 	if (fattr->valid)
 		nfs_update_inode(inode, fattr);
-- 
2.17.1

