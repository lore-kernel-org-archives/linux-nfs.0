Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34458 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754830Ab2EWNDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 09:03:40 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFSv4.1 test the mdsthreshold hint parameters
Date: Wed, 23 May 2012 05:02:37 -0400
Message-Id: <1337763757-1566-4-git-send-email-andros@netapp.com>
In-Reply-To: <1337763757-1566-1-git-send-email-andros@netapp.com>
References: <1337763757-1566-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6620606..b8323aa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -936,6 +936,81 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 }
 
 /*
+ * Use mdsthreshold hints set at each OPEN to determine if I/O should go
+ * to the MDS or over pNFS
+ *
+ * The nfs_inode read_io and write_io fields are cumulative counters reset
+ * when there are no layout segments. Note that in pnfs_update_layout iomode
+ * is set to IOMODE_READ for a READ request, and set to IOMODE_RW for a
+ * WRITE request.
+ *
+ * A return of true means use MDS I/O.
+ *
+ * From rfc 5661:
+ * If a file's size is smaller than the file size threshold, data accesses
+ * SHOULD be sent to the metadata server.  If an I/O request has a length that
+ * is below the I/O size threshold, the I/O SHOULD be sent to the metadata
+ * server.  If both file size and I/O size are provided, the client SHOULD
+ * reach or exceed  both thresholds before sending its read or write
+ * requests to the data server.
+ */
+static bool pnfs_within_mdsthreshold(struct nfs_open_context *ctx,
+				     struct inode *ino, int iomode)
+{
+	struct nfs4_threshold *t = ctx->mdsthreshold;
+	struct nfs_inode *nfsi = NFS_I(ino);
+	loff_t fsize = i_size_read(ino);
+	bool size = false, size_set = false, io = false, io_set = false, ret = false;
+
+	if (t == NULL)
+		return ret;
+
+	dprintk("%s bm=0x%x rd_sz=%llu wr_sz=%llu rd_io=%llu wr_io=%llu\n",
+		__func__, t->bm, t->rd_sz, t->wr_sz, t->rd_io_sz, t->wr_io_sz);
+
+	switch (iomode) {
+	case IOMODE_READ:
+		if (t->bm & THRESHOLD_RD) {
+			dprintk("%s fsize %llu\n", __func__, fsize);
+			size_set = true;
+			if (fsize < t->rd_sz)
+				size = true;
+		}
+		if (t->bm & THRESHOLD_RD_IO) {
+			dprintk("%s nfsi->read_io %llu\n", __func__,
+				nfsi->read_io);
+			io_set = true;
+			if (nfsi->read_io < t->rd_io_sz)
+				io = true;
+		}
+		break;
+	case IOMODE_RW:
+		if (t->bm & THRESHOLD_WR) {
+			dprintk("%s fsize %llu\n", __func__, fsize);
+			size_set = true;
+			if (fsize < t->wr_sz)
+				size = true;
+		}
+		if (t->bm & THRESHOLD_WR_IO) {
+			dprintk("%s nfsi->write_io %llu\n", __func__,
+				nfsi->write_io);
+			io_set = true;
+			if (nfsi->write_io < t->wr_io_sz)
+				io = true;
+		}
+		break;
+	}
+	if (size_set && io_set) {
+		if (size && io)
+			ret = true;
+	} else if (size || io)
+		ret = true;
+
+	dprintk("<-- %s size %d io %d ret %d\n", __func__, size, io, ret);
+	return ret;
+}
+
+/*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
@@ -962,6 +1037,10 @@ pnfs_update_layout(struct inode *ino,
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
+
+	if (pnfs_within_mdsthreshold(ctx, ino, iomode))
+		return NULL;
+
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
-- 
1.7.7.6

