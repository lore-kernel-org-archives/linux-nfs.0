Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:46962 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932069AbeE3SGW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:22 -0400
Received: by mail-io0-f174.google.com with SMTP id d22-v6so8134801iof.13
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:21 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:20 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/19] pnfs: refactor send_layoutget
Date: Wed, 30 May 2018 14:05:39 -0400
Message-Id: <20180530180553.38769-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-5-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Pull out the alloc/init part for eventual reuse by OPEN.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ee723aa153a3..2c955c389ecf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -915,18 +915,12 @@ pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo)
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 }
 
-/*
- * Get layout from server.
- *    for now, assume that whole file layouts are requested.
- *    arg->offset: 0
- *    arg->length: all ones
- */
-static struct pnfs_layout_segment *
-send_layoutget(struct pnfs_layout_hdr *lo,
+static struct nfs4_layoutget *
+pnfs_alloc_init_layoutget_args(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
 	   nfs4_stateid *stateid,
 	   const struct pnfs_layout_range *range,
-	   long *timeout, gfp_t gfp_flags)
+	   gfp_t gfp_flags)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -935,14 +929,9 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 
-	/*
-	 * Synchronously retrieve layout information from server and
-	 * store in lseg. If we race with a concurrent seqid morphing
-	 * op, then re-send the LAYOUTGET.
-	 */
 	lgp = kzalloc(sizeof(*lgp), gfp_flags);
 	if (lgp == NULL)
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 
 	i_size = i_size_read(ino);
 
@@ -963,8 +952,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_stateid_copy(&lgp->args.stateid, stateid);
 	lgp->gfp_flags = gfp_flags;
 	lgp->cred = lo->plh_lc_cred;
-
-	return nfs4_proc_layoutget(lgp, timeout, gfp_flags);
+	return lgp;
 }
 
 static void pnfs_clear_layoutcommit(struct inode *inode,
@@ -1694,6 +1682,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo = NULL;
 	struct pnfs_layout_segment *lseg = NULL;
+	struct nfs4_layoutget *lgp;
 	nfs4_stateid stateid;
 	long timeout = 0;
 	unsigned long giveup = jiffies + (clp->cl_lease_time << 1);
@@ -1838,7 +1827,15 @@ pnfs_update_layout(struct inode *ino,
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lseg = send_layoutget(lo, ctx, &stateid, &arg, &timeout, gfp_flags);
+	lgp = pnfs_alloc_init_layoutget_args(lo, ctx, &stateid, &arg, gfp_flags);
+	if (!lgp) {
+		trace_pnfs_update_layout(ino, pos, count, iomode, lo, NULL,
+					 PNFS_UPDATE_LAYOUT_NOMEM);
+		atomic_dec(&lo->plh_outstanding);
+		goto out_put_layout_hdr;
+	}
+
+	lseg = nfs4_proc_layoutget(lgp, &timeout, gfp_flags);
 	trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET);
 	atomic_dec(&lo->plh_outstanding);
-- 
2.17.0

