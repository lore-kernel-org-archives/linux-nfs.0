Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f65.google.com ([209.85.166.65]:42164 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727769AbeI0V7v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2018 17:59:51 -0400
Received: by mail-io1-f65.google.com with SMTP id n18-v6so2239519ioa.9
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2018 08:41:00 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id d11-v6sm689072iok.77.2018.09.27.08.40.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Sep 2018 08:40:59 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFS: Remove private spinlock in struct nfs_pgio_header
Date: Thu, 27 Sep 2018 11:40:03 -0400
Message-Id: <20180927154003.11825-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180927154003.11825-2-trond.myklebust@hammerspace.com>
References: <20180927154003.11825-1-trond.myklebust@hammerspace.com>
 <20180927154003.11825-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that each struct nfs_pgio_header corresponds to one RPC call, we
only have one writer to the struct nfs_pgio_header.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pagelist.c       | 13 ++++++-------
 fs/nfs/read.c           | 10 ++++------
 include/linux/nfs_xdr.h |  5 ++---
 3 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index bb5476a6d264..f97c455f5734 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -63,14 +63,14 @@ EXPORT_SYMBOL_GPL(nfs_pgheader_init);
 
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos)
 {
-	spin_lock(&hdr->lock);
-	if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags)
-	    || pos < hdr->io_start + hdr->good_bytes) {
+	unsigned int new = pos - hdr->io_start;
+
+	if (hdr->good_bytes > new) {
+		hdr->good_bytes = new;
 		clear_bit(NFS_IOHDR_EOF, &hdr->flags);
-		hdr->good_bytes = pos - hdr->io_start;
-		hdr->error = error;
+		if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags))
+			hdr->error = error;
 	}
-	spin_unlock(&hdr->lock);
 }
 
 static inline struct nfs_page *
@@ -494,7 +494,6 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *ops)
 
 	if (hdr) {
 		INIT_LIST_HEAD(&hdr->pages);
-		spin_lock_init(&hdr->lock);
 		hdr->rw_ops = ops;
 	}
 	return hdr;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 48d7277c60a9..f9f19784db82 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -276,16 +276,14 @@ static void nfs_readpage_result(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
 	if (hdr->res.eof) {
-		loff_t bound;
+		loff_t pos = hdr->args.offset + hdr->res.count;
+		unsigned int new = pos - hdr->io_start;
 
-		bound = hdr->args.offset + hdr->res.count;
-		spin_lock(&hdr->lock);
-		if (bound < hdr->io_start + hdr->good_bytes) {
+		if (hdr->good_bytes > new) {
+			hdr->good_bytes = new;
 			set_bit(NFS_IOHDR_EOF, &hdr->flags);
 			clear_bit(NFS_IOHDR_ERROR, &hdr->flags);
-			hdr->good_bytes = bound - hdr->io_start;
 		}
-		spin_unlock(&hdr->lock);
 	} else if (hdr->res.count < hdr->args.count)
 		nfs_readpage_retry(task, hdr);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 343e44166346..0e016252cfc6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1482,11 +1482,10 @@ struct nfs_pgio_header {
 	const struct nfs_rw_ops	*rw_ops;
 	struct nfs_io_completion *io_completion;
 	struct nfs_direct_req	*dreq;
-	spinlock_t		lock;
-	/* fields protected by lock */
+
 	int			pnfs_error;
 	int			error;		/* merge with pnfs_error */
-	unsigned long		good_bytes;	/* boundary of good data */
+	unsigned int		good_bytes;	/* boundary of good data */
 	unsigned long		flags;
 
 	/*
-- 
2.17.1
