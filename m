Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59197 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756658Ab2CGC6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 21:58:22 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: add fh_crc to debug output
Date: Tue,  6 Mar 2012 21:58:20 -0500
Message-Id: <1331089100-22297-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Print the filehandle crc in two debug messages

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/inode.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3919ceb..5dc6425 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -390,9 +390,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		unlock_new_inode(inode);
 	} else
 		nfs_refresh_inode(inode, fattr);
-	dprintk("NFS: nfs_fhget(%s/%Ld ct=%d)\n",
+	dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
+		nfs_display_fhandle_hash(fh),
 		atomic_read(&inode->i_count));
 
 out:
@@ -1274,8 +1275,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
 
-	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
+	dfprintk(VFS, "NFS: %s(%s/%ld fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
+			nfs_display_fhandle_hash(NFS_FH(inode)),
 			atomic_read(&inode->i_count), fattr->valid);
 
 	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
-- 
1.7.4.4

