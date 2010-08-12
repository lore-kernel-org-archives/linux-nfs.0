Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:39218 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab0HLF0p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Aug 2010 01:26:45 -0400
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: lookupcache coherence bugs in WCC update path (revised)
References: <87lj8ckb1e.fsf@patl.com>
CC: linux-kernel@vger.kernel.org
Date: Wed, 11 Aug 2010 22:26:36 -0700
Message-ID: <8762zgmmer.fsf@patl.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(Well, crud.  I screwed up the previous diff and was missing a
close-curly.  This version actually compiles...)

This patch fixes some coherence bugs in the NFS "dentry lookup cache".

The NFS dentry lookup cache provides the nfs_force_lookup_revalidate()
call to invalidate all cached dentries associated with an inode.  In
general, the NFS client uses the ctime and mtime in the inode to detect
when changes are made on the server.

Therefore, to maintain cache coherence, nfs_force_lookup_revalidate()
must be called whenever the ctime or mtime of a directory inode is
updated with fresh data from the server.  There are a few spots in
nfs_wcc_update_inode() where this rule is violated, making it possible
for the lookup cache to return arbitrarily stale data.

This actually bit me in practice.  I have an application where a
negative dentry results in -ENOENT for a file that was created 30+
minutes earlier (despite the "noac" mount option).  Unfortunately I
cannot share my test case, but I believe the following simple patch is
"obviously correct", and I can confirm that it fixes my issue.

CC: stable <stable@kernel.org>
Signed-off-by: Patrick LoPresti <lopresti@gmail.com>

---

--- linux-2.6.35/fs/nfs/inode.c.orig	2010-08-01 15:11:14.000000000 -0700
+++ linux-2.6.35/fs/nfs/inode.c	2010-08-11 22:18:30.000000000 -0700
@@ -819,21 +819,29 @@ static void nfs_wcc_update_inode(struct
 			&& (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			&& nfsi->change_attr == fattr->pre_change_attr) {
 		nfsi->change_attr = fattr->change_attr;
-		if (S_ISDIR(inode->i_mode))
+		if (S_ISDIR(inode->i_mode)) {
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+			nfs_force_lookup_revalidate(inode);
+		}
 	}
 	/* If we have atomic WCC data, we may update some attributes */
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_CTIME)
-			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime))
-			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
+			&& timespec_equal(&inode->i_ctime,
+					  &fattr->pre_ctime)) {
+		if (S_ISDIR(inode->i_mode))
+			nfs_force_lookup_revalidate(inode);
+		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
+	}
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PREMTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			&& timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
 			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-			if (S_ISDIR(inode->i_mode))
+			if (S_ISDIR(inode->i_mode)) {
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+				nfs_force_lookup_revalidate(inode);
+			}
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
 			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
