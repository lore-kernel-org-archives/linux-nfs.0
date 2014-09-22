Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:48231 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128AbaIVSBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 14:01:21 -0400
Date: Mon, 22 Sep 2014 20:01:18 +0200
From: Christoph Hellwig <hch@lst.de>
To: Mel Gorman <mgorman@suse.de>, Jens Axboe <axboe@kernel.dk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs: cleanup REQ_KERNEL leftovers
Message-ID: <20140922180118.GA374@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No more need for any of this now that we have ->write_iter.  The read
path for swap over nfs which directly readpages into non-owned pages
still looks scary as hell to me and might benefit from a rewrite over
an updated ->read_iter..

Signed-off-by: Christoph Hellwig <hch@lst.de>

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 65ef6e0..9e5bc7f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -221,12 +221,11 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter, loff_t
 	return -EINVAL;
 #else
 	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
+	VM_BUG_ON(!(rw & ITER_BVEC));
 
-	if (rw == READ || rw == KERNEL_READ)
-		return nfs_file_direct_read(iocb, iter, pos,
-				rw == READ ? true : false);
-	return nfs_file_direct_write(iocb, iter, pos,
-				rw == WRITE ? true : false);
+	if (rw == READ)
+		return nfs_file_direct_read(iocb, iter, pos, true);
+	return nfs_file_direct_write(iocb, iter, pos, true);
 #endif /* CONFIG_NFS_SWAP */
 }
 
@@ -512,7 +511,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
  * cache.
  */
 ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
-				loff_t pos, bool uio)
+				loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
@@ -893,7 +892,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
 ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
-				loff_t pos, bool uio)
+				loff_t pos)
 {
 	ssize_t result = -EINVAL;
 	struct file *file = iocb->ki_filp;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80..3b42cb8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -171,7 +171,7 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t result;
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, to, iocb->ki_pos, true);
+		return nfs_file_direct_read(iocb, to, iocb->ki_pos);
 
 	dprintk("NFS: read(%pD2, %zu@%lu)\n",
 		iocb->ki_filp,
@@ -648,7 +648,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 		return result;
 
 	if (file->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, from, pos, true);
+		return nfs_file_direct_write(iocb, from, pos);
 
 	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
 		file, count, (long long) pos);
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 66c2167..fbb1ef6 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -186,7 +186,6 @@ enum rq_flag_bits {
 	__REQ_FLUSH_SEQ,	/* request for flush sequence */
 	__REQ_IO_STAT,		/* account I/O stat */
 	__REQ_MIXED_MERGE,	/* merge of different types, fail separately */
-	__REQ_KERNEL, 		/* direct IO to kernel pages */
 	__REQ_PM,		/* runtime pm request */
 	__REQ_END,		/* last of chain of requests */
 	__REQ_HASHED,		/* on IO scheduler merge hash */
@@ -240,7 +239,6 @@ enum rq_flag_bits {
 #define REQ_IO_STAT		(1ULL << __REQ_IO_STAT)
 #define REQ_MIXED_MERGE		(1ULL << __REQ_MIXED_MERGE)
 #define REQ_SECURE		(1ULL << __REQ_SECURE)
-#define REQ_KERNEL		(1ULL << __REQ_KERNEL)
 #define REQ_PM			(1ULL << __REQ_PM)
 #define REQ_END			(1ULL << __REQ_END)
 #define REQ_HASHED		(1ULL << __REQ_HASHED)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9418772..9b5bc1c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -192,8 +192,6 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define READ			0
 #define WRITE			RW_MASK
 #define READA			RWA_MASK
-#define KERNEL_READ		(READ|REQ_KERNEL)
-#define KERNEL_WRITE		(WRITE|REQ_KERNEL)
 
 #define READ_SYNC		(READ | REQ_SYNC)
 #define WRITE_SYNC		(WRITE | REQ_SYNC | REQ_NOIDLE)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5180a7e..1d67b55 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -463,11 +463,9 @@ extern int nfs3_removexattr (struct dentry *, const char *name);
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t);
 extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
-			struct iov_iter *iter,
-			loff_t pos, bool uio);
+			struct iov_iter *iter, loff_t pos);
 extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
-			struct iov_iter *iter,
-			loff_t pos, bool uio);
+			struct iov_iter *iter, loff_t pos);
 
 /*
  * linux/fs/nfs/dir.c
