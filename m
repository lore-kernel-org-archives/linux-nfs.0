Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61929 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756239Ab2EXROt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 13:14:49 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] NFSv4.1 add nfs_inode book keeping for mdsthreshold
Date: Thu, 24 May 2012 13:13:24 -0400
Message-Id: <1337879604-24940-2-git-send-email-andros@netapp.com>
In-Reply-To: <1337879604-24940-1-git-send-email-andros@netapp.com>
References: <1337879604-24940-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Keep track of the number of bytes read or written via buffered, direct, and
mem-mapped i/o for use by mdsthreshold size_io hints.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/direct.c        |    2 ++
 fs/nfs/file.c          |    1 +
 fs/nfs/inode.c         |    2 ++
 fs/nfs/pnfs.c          |    3 +++
 fs/nfs/read.c          |    2 ++
 include/linux/nfs_fs.h |    3 +++
 6 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c47a46e..23d170b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -447,6 +447,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
+	NFS_I(inode)->read_io += result;
 out_release:
 	nfs_direct_req_release(dreq);
 out:
@@ -785,6 +786,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 	nfs_pageio_complete(&desc);
+	NFS_I(dreq->inode)->write_io += desc.pg_bytes_written;
 
 	/*
 	 * If no bytes were started, return the error, and let the
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8eda8a6..56311ca 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -424,6 +424,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 	if (status < 0)
 		return status;
+	NFS_I(mapping->host)->write_io += copied;
 	return copied;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 889f7e5..a6f5fbb 100644
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
index cbcb6ae..6620606 100644
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
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2cfdd77..86ced78 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -152,6 +152,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
 	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
+	NFS_I(inode)->read_io += pgio.pg_bytes_written;
 	return 0;
 }
 
@@ -656,6 +657,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
 	nfs_pageio_complete(&pgio);
+	NFS_I(inode)->read_io += pgio.pg_bytes_written;
 	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index ca4a707..9d44860 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -202,6 +202,9 @@ struct nfs_inode {
 	/* pNFS layout information */
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
+	/* how many bytes have been written/read and how many bytes queued up */
+	__u64 write_io;
+	__u64 read_io;
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
 #endif
-- 
1.7.7.6

