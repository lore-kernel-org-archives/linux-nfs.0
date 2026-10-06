Received: from mail-pj1-f69.google.com (mail-pj1-f69.google.com [209.85.216.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00F674F93B9
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 23:33:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.69
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791329595; cv=none; b=XAhOfGmb8twHSCJQm8FmfZPaMjuKKpyoA10vmGcQ0MXdZ1k3bx+8WKzx+kD89uUZQYjmHkgubnOBjgulWSLB8Fajjw4geD6DVduA3RbvdCsq19xvgn8roIHqX8/GVXVbyUZw9C8QLW01sPEKWKOO8gSTssmxPm43RcVUufQuU3o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791329595; c=relaxed/simple;
	bh=0qjvB8OdXfnw5dOGUw3YkdBEmSXrOae8HI2nVPtSxvc=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=Uj0MIoLxWDw52+GTSLjF+TQGWq57ZJrg0JO8WCROSWXc/FEaVbHXKAHfcH3cLqKH8i5bf+uCY+AhsZXyVo6Te7cfgkdFCYgNHZVhtVSNzIFRSuaIQrXwN/zV6oaYtmwYYGs6QLR3BeHE4OadHszRa1NT1P3WrBj7ESUX895adAU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=UxwH3VsE; arc=none smtp.client-ip=209.85.216.69
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UxwH3VsE"
Received: by mail-pj1-f69.google.com with SMTP id 98e67ed59e1d1-3a0be20102fso3253401a91.0
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2026 16:33:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1791329593; x=1791934393; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Em2Xu7zpFNZOw/PR0iHa6bG/S6aI6uTipNSUQ/VAeRI=;
        b=UxwH3VsEMrPeoqLzAb/AWVZ2YqCdDLmtrQw0snxOBhdnACAY00GYYBF/X/JcLz3Ij4
         DwRcdRcL5nWPqRK8X9dy4Xq6tevdjcqO/GLXXZdYfabld/pENtQjBMDYDvb8P/xnM5xW
         DCLBRwwL8Esp6blMKhqFu4RFstpp8R1pfzMKZIUXpJhEVpLgLABqBNpLDw5Nawzbi28H
         Tc/jCCTjKX9sAj5V6OvP9sXafYkPbX4OYkCHEowzaJMN6eHSYWpMrHVzDkS/EK94WL9D
         1+0heEI1si7UQ9+feeCw6XXU8GEADdknaTDO8neeT+WJdJuWGF3m1c8qz8LrHJSIEW/W
         L+SQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791329593; x=1791934393;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Em2Xu7zpFNZOw/PR0iHa6bG/S6aI6uTipNSUQ/VAeRI=;
        b=y0v5+07E83hbta6+0jA3REQmwe5VEGza1Vta0Bpqhk/6+/yErvQY24ORv+xn7/9qOu
         0Bm9165ACiPVdtAH/prDOdA+Bpd9Gd7h1Hfzm20QS9IlR0/hTJJqJ+4Acj0F9JUhVeWx
         XWlw9TV/KMb+zhVoYnf8zjFXMaMdhsvclB+TdB6tTgsnV2hb+HGquji1c0x/wBjFkzNG
         GgYiyVjYSkItDJgJUggJUoIDFKnObwoy1IOxnC/rN9d+xyRs7ZMqEddYrUiDOiY7OVCt
         AWcwvSmLxtT7tOeTWnhLtMI4GolLb053rmVYXYrgJKujGHk/kTZtrQ/NboWt+fzUr8ng
         vqMw==
X-Gm-Message-State: AFq9FYJzYDMPnpx6MBhKlY/99ibKYx9QgcGmjUyiCPPVtSxtXngUjVsc
	qYihW/a5bIMoI9xoH3LNotEWgdAdVj4ITQr7KY8sPblLwP0p7qd6cg/+wsrIxrLBFoQZAnz5LYw
	SAlfri/OwW/rTZQSxTtGaZ3JmaM+OvSYlQPA9kCTMgpv6lV+UAwnrajP8ouJGvowmZlOgux3rn0
	W1jpRSpdwsPQUQ5cmFVLMZSon6nEHP9HMK+9Y=
X-Received: from pgkc15.prod.google.com ([2002:a63:ef4f:0:b0:ccc:5e44:a6cc])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:90a:da87:b0:3a8:80f4:98a7
 with SMTP id 98e67ed59e1d1-3a8a1bd661fmr445058a91.24.1791329593068; Tue, 06
 Oct 2026 16:33:13 -0700 (PDT)
Date: Tue,  6 Oct 2026 23:32:47 +0000
In-Reply-To: <20261006233248.705086-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20261006233248.705086-1-praan@google.com>
X-Mailer: git-send-email 2.56.0.rc1.315.gc6ed9934b7-goog
Message-ID: <20261006233248.705086-8-praan@google.com>
Subject: [RFC PATCH v1 7/8] nfs: allow LOCALIO for P2PDMA pages only as
 aligned direct I/O
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Tom Talpey <tom@talpey.com>, 
	Leon Romanovsky <leon@kernel.org>, Unnati Sachan <unnatisachan@google.com>, 
	Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

LOCALIO hands READs and WRITEs to the local filesystem, which can take
P2PDMA pages only if its disk can DMA to them. Use LOCALIO for such I/O
only if the filesystem's block device supports P2PDMA. Otherwise send a
regular READ or WRITE RPC, as if LOCALIO were off.

When the I/O is not a single DIO-aligned segment, LOCALIO falls back to
buffered I/O, which copies the payload through the page cache via CPU
accesses. Fail such I/O with -EINVAL instead.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/internal.h |  8 ++++++++
 fs/nfs/localio.c  | 40 ++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pagelist.c |  3 +++
 3 files changed, 51 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d6ea41a3f9b4..9338b5e0896a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -476,6 +476,7 @@ extern struct nfsd_file *nfs_local_open_fh(struct nfs_client *,
 					   struct nfs_fh *,
 					   struct nfs_file_localio *,
 					   const fmode_t);
+struct nfsd_file *nfs_local_p2pdma_check(struct nfsd_file *localio);
 extern int nfs_local_doio(struct nfs_client *,
 			  struct nfsd_file *,
 			  struct nfs_pgio_header *,
@@ -495,6 +496,13 @@ nfs_local_open_fh(struct nfs_client *clp, const struct cred *cred,
 {
 	return NULL;
 }
+
+static inline struct nfsd_file *
+nfs_local_p2pdma_check(struct nfsd_file *localio)
+{
+	return NULL;
+}
+
 static inline int nfs_local_doio(struct nfs_client *clp,
 				 struct nfsd_file *localio,
 				 struct nfs_pgio_header *hdr,
diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index f42b6112a613..6c8f2d393c35 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -19,6 +19,7 @@
 #include <linux/nfs_common.h>
 #include <linux/nfslocalio.h>
 #include <linux/bvec.h>
+#include <linux/blkdev.h>
 
 #include <linux/nfs.h>
 #include <linux/nfs_fs.h>
@@ -290,6 +291,22 @@ nfs_local_open_fh(struct nfs_client *clp, const struct cred *cred,
 }
 EXPORT_SYMBOL_GPL(nfs_local_open_fh);
 
+/*
+ * LOCALIO moves P2PDMA pages only by DMA to and from the local disk.
+ * If that disk cannot do P2PDMA, put @localio and return NULL so the
+ * I/O is sent as a regular RPC instead.
+ */
+struct nfsd_file *nfs_local_p2pdma_check(struct nfsd_file *localio)
+{
+	struct file *file = nfs_to->nfsd_file_file(localio);
+	struct block_device *bdev = file_inode(file)->i_sb->s_bdev;
+
+	if (bdev && blk_queue_pci_p2pdma(bdev_get_queue(bdev)))
+		return localio;
+	nfs_local_file_put(localio);
+	return NULL;
+}
+
 /*
  * Ensure all page cache allocations are done from GFP_NOFS context to
  * prevent direct reclaim recursion back into NFS via nfs_writepages.
@@ -511,6 +528,17 @@ nfs_local_iters_init(struct nfs_local_kiocb *iocb, int rw)
 	iov_iter_bvec(&iocb->iters[0], rw, iocb->bvec, v, len);
 }
 
+/*
+ * P2PDMA payloads move only by DMA, never through the page cache, so the
+ * whole I/O must be a single DIO-aligned segment.
+ */
+static bool nfs_local_p2pdma_misaligned(struct nfs_local_kiocb *iocb)
+{
+	return iocb->hdr->args.p2pdma &&
+	       (atomic_read(&iocb->n_iters) != 1 ||
+		!iocb->iter_is_dio_aligned[0]);
+}
+
 static void
 nfs_local_hdr_release(struct nfs_pgio_header *hdr,
 		const struct rpc_call_ops *call_ops)
@@ -732,6 +760,12 @@ static void nfs_local_do_read(struct nfs_local_kiocb *iocb,
 	nfs_local_pgio_init(hdr, call_ops);
 	hdr->res.eof = false;
 
+	if (nfs_local_p2pdma_misaligned(iocb)) {
+		nfs_local_pgio_done(iocb, -EINVAL);
+		nfs_local_pgio_release(iocb);
+		return;
+	}
+
 	INIT_WORK(&iocb->work, nfs_local_call_read);
 	if (nfs_local_defer_io())
 		queue_work(nfslocaliod_workqueue, &iocb->work);
@@ -953,6 +987,12 @@ static void nfs_local_do_write(struct nfs_local_kiocb *iocb,
 
 	nfs_set_local_verifier(hdr->inode, hdr->res.verf, hdr->args.stable);
 
+	if (nfs_local_p2pdma_misaligned(iocb)) {
+		nfs_local_pgio_done(iocb, -EINVAL);
+		nfs_local_pgio_release(iocb);
+		return;
+	}
+
 	INIT_WORK(&iocb->work, nfs_local_call_write);
 	if (nfs_local_defer_io())
 		queue_work(nfslocaliod_workqueue, &iocb->work);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ec535ed3051d..2d1d07c460fd 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1023,6 +1023,9 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 					  &hdr->args.context->nfl,
 					  hdr->args.context->mode);
 
+		if (localio && hdr->args.p2pdma)
+			localio = nfs_local_p2pdma_check(localio);
+
 		if (NFS_SERVER(hdr->inode)->nfs_client->cl_minorversion)
 			task_flags = RPC_TASK_MOVEABLE;
 		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
-- 
2.56.0.rc1.315.gc6ed9934b7-goog

