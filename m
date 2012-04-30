Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:52742 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab2D3PeI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 11:34:08 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 30 Apr 2012 09:34:06 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 48C1F1FF004A
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 09:33:34 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3UFXMwA131972
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 09:33:22 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3UFXKPD019541
	for <linux-nfs@vger.kernel.org>; Mon, 30 Apr 2012 09:33:20 -0600
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Matthew Treinish <treinish@linux.vnet.ibm.com>
Subject: [PATCH] Fixed goto readability in nfs_update_inode.
Date: Mon, 30 Apr 2012 11:32:57 -0400
Message-Id: <1335799977-5587-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplified error gotos to make it slightly easier to read,
it doesn't affect the functionality of the routine.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/inode.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8bbfa5..943d1d0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1279,14 +1279,26 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			nfs_display_fhandle_hash(NFS_FH(inode)),
 			atomic_read(&inode->i_count), fattr->valid);
 
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
-		goto out_fileid;
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid) {
+		printk(KERN_ERR "NFS: server %s error: fileid changed\n"
+			"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
+			NFS_SERVER(inode)->nfs_client->cl_hostname,
+			inode->i_sb->s_id, (long long)nfsi->fileid,
+			(long long)fattr->fileid);
+		goto out_err;
+	}
 
 	/*
 	 * Make sure the inode's type hasn't changed.
 	 */
-	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
-		goto out_changed;
+	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT)) {
+		/*
+		* Big trouble! The inode has become a different object.
+		*/
+		printk(KERN_DEBUG "NFS: %s: inode %ld mode changed, %07o to %07o\n",
+				__func__, inode->i_ino, inode->i_mode, fattr->mode);
+		goto out_err;
+	}
 
 	server = NFS_SERVER(inode);
 	/* Update the fsid? */
@@ -1466,12 +1479,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		nfsi->cache_validity |= invalid;
 
 	return 0;
- out_changed:
-	/*
-	 * Big trouble! The inode has become a different object.
-	 */
-	printk(KERN_DEBUG "NFS: %s: inode %ld mode changed, %07o to %07o\n",
-			__func__, inode->i_ino, inode->i_mode, fattr->mode);
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
@@ -1480,13 +1487,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	 */
 	nfs_invalidate_inode(inode);
 	return -ESTALE;
-
- out_fileid:
-	printk(KERN_ERR "NFS: server %s error: fileid changed\n"
-		"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
-		NFS_SERVER(inode)->nfs_client->cl_hostname, inode->i_sb->s_id,
-		(long long)nfsi->fileid, (long long)fattr->fileid);
-	goto out_err;
 }
 
 
-- 
1.7.7.6

