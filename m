Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762055Ab2ERBX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 21:23:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 3/4] NFSv4.1 add nfs_inode book keeping for mdsthreshold
Date: Thu, 17 May 2012 15:48:21 -0400
Message-Id: <1337284102-3372-3-git-send-email-andros@netapp.com>
In-Reply-To: <1337284102-3372-1-git-send-email-andros@netapp.com>
References: <1337284102-3372-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Keep track of the number of bytes read or written, including those queued
up to be flushed. For use by mdsthreshold i/o size hints.

No locking needed as this is used as hint information.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c          |    8 ++++++--
 fs/nfs/inode.c         |    2 ++
 fs/nfs/pnfs.c          |    3 +++
 include/linux/nfs_fs.h |    3 +++
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8eda8a6..c4cc096 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -203,8 +203,10 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
 	if (!result) {
 		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
-		if (result > 0)
+		if (result > 0) {
+			NFS_I(inode)->read_io += result;
 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
+		}
 	}
 	return result;
 }
@@ -613,8 +615,10 @@ static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 		if (err < 0)
 			result = err;
 	}
-	if (result > 0)
+	if (result > 0) {
+		NFS_I(inode)->write_io += written;
 		nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, written);
+	}
 out:
 	return result;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 850d158..cc5ee55 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -323,6 +323,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		inode->i_gid = -2;
 		inode->i_blocks = 0;
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
+		nfsi->write_io = 0;
+		nfsi->read_io = 0;
 
 		nfsi->read_cache_jiffies = fattr->time_start;
 		nfsi->attr_gencount = fattr->gencount;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5d78a90..924dce1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -395,6 +395,9 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	if (list_empty(&lo->plh_segs)) {
+		/* Reset MDS Threshold I/O counters */
+		NFS_I(lo->plh_inode)->write_io = 0;
+		NFS_I(lo->plh_inode)->read_io = 0;
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
 			put_layout_hdr_locked(lo);
 		return 0;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index ca4a707..c6954ac 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -201,6 +201,9 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct pnfs_layout_hdr *layout;
+	/* how many bytes have been written/read and how many bytes queued up */
+	__u64 write_io;
+	__u64 read_io;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
-- 
1.7.7.6

