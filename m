Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60512 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab2E0Fdw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2012 01:33:52 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so3356136pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 26 May 2012 22:33:51 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 1/3] NFS41: add pnfs_dio_begin/dio_end
Date: Sun, 27 May 2012 13:32:58 +0800
Message-Id: <1338096780-2763-2-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow layout driver specific preparation for DIO.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/direct.c |   43 +++++++++++++++++++++++++++++++++++++++----
 fs/nfs/pnfs.h   |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index ad2775d..8e9c8e1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -383,6 +383,37 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
+static void nfs_direct_read_init(struct nfs_pageio_descriptor *pgio,
+				 struct inode *inode, const struct iovec *iov,
+				 unsigned long nr_segs, loff_t pos,
+				 struct blk_plug *plug)
+{
+	if (pnfs_dio_begin(inode, iov, nr_segs, pos, plug))
+		pnfs_pageio_init_read(pgio, inode,
+				      &nfs_direct_read_completion_ops);
+	else
+		nfs_pageio_init_read_mds(pgio, inode,
+					 &nfs_direct_read_completion_ops);
+}
+
+static void nfs_direct_write_init(struct nfs_pageio_descriptor *pgio,
+				  struct inode *inode, const struct iovec *iov,
+				  unsigned long nr_segs, loff_t pos,
+				  struct blk_plug *plug)
+{
+	if (pnfs_dio_begin(inode, iov, nr_segs, pos, plug))
+		pnfs_pageio_init_write(pgio, inode, FLUSH_COND_STABLE,
+				       &nfs_direct_write_completion_ops);
+	else
+		nfs_pageio_init_write_mds(pgio, inode, FLUSH_COND_STABLE,
+					  &nfs_direct_write_completion_ops);
+}
+
+static void nfs_dio_end(struct inode *inode, struct blk_plug *plug)
+{
+	pnfs_dio_end(inode, plug);
+}
+
 static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 					      const struct iovec *iov,
 					      unsigned long nr_segs,
@@ -392,9 +423,10 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
+	struct blk_plug plug;
+
+	nfs_direct_read_init(&desc, dreq->inode, iov, nr_segs, pos, &plug);
 
-	nfs_pageio_init_read(&desc, dreq->inode,
-			     &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
 
@@ -410,6 +442,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	}
 
 	nfs_pageio_complete(&desc);
+	nfs_dio_end(dreq->inode, &plug);
 
 	/*
 	 * If no bytes were started, return the error, and let the
@@ -776,9 +809,10 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	unsigned long seg;
+	struct blk_plug plug;
+
+	nfs_direct_write_init(&desc, inode, iov, nr_segs, pos, &plug);
 
-	nfs_pageio_init_write(&desc, inode, FLUSH_COND_STABLE,
-			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
 	atomic_inc(&inode->i_dio_count);
@@ -794,6 +828,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 	nfs_pageio_complete(&desc);
+	nfs_dio_end(inode, &plug);
 	NFS_I(dreq->inode)->write_io += desc.pg_bytes_written;
 
 	/*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 29fd23c..b4c7139 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,6 +32,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/blkdev.h>
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
@@ -110,6 +111,11 @@ struct pnfs_layoutdriver_type {
 			       int how,
 			       struct nfs_commit_info *cinfo);
 
+	bool (*dio_begin) (struct inode *inode, const struct iovec *iov,
+			   unsigned long nr_segs, loff_t pos,
+			   struct blk_plug *plug);
+	void (*dio_end) (struct blk_plug *plug);
+
 	/*
 	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
 	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
@@ -369,6 +375,27 @@ pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 					nfss->pnfs_curr_ld->id == src->l_type);
 }
 
+static inline bool
+pnfs_dio_begin(struct inode *inode, const struct iovec *iov,
+	       unsigned long nr_segs, loff_t pos, struct blk_plug *plug)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+
+	if (ld == NULL)
+		return false;
+	if (ld->dio_begin == NULL)
+		return true;
+	return ld->dio_begin(inode, iov, nr_segs, pos, plug);
+}
+
+static inline void pnfs_dio_end(struct inode *inode, struct blk_plug *plug)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+
+	if (ld != NULL && ld->dio_end != NULL)
+		ld->dio_end(plug);
+}
+
 #ifdef NFS_DEBUG
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 #else
@@ -506,6 +533,17 @@ static inline struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 	return NULL;
 }
 
+static inline bool
+pnfs_dio_begin(struct inode *inode, const struct iovec *iov,
+	       unsigned long nr_segs, loff_t pos, struct blk_plug *plug)
+{
+	return false;
+}
+
+static inline void pnfs_dio_end(struct inode *inode, struct blk_plug *plug)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
-- 
1.7.1.262.g5ef3d

