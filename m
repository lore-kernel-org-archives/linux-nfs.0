Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbaETSIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:31 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 07/12] nfs: merge pnfs_try_to_read_data() and pnfs_do_read()
Date: Tue, 20 May 2014 14:08:14 -0400
Message-ID: <1400609299-32558-8-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes these functions look neater in preparation for combining with
their write equivilents.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 28 +++++++---------------------
 1 file changed, 7 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 355cd41..293e970 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1602,37 +1602,23 @@ EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
  * Call the appropriate parallel I/O subsystem read function.
  */
 static enum pnfs_try_status
-pnfs_try_to_read_data(struct nfs_pgio_header *hdr,
-		       const struct rpc_call_ops *call_ops,
-		       struct pnfs_layout_segment *lseg)
+pnfs_try_to_read_data(struct nfs_pgio_header *hdr)
 {
-	struct inode *inode = hdr->inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	enum pnfs_try_status trypnfs;
-
-	hdr->mds_ops = call_ops;
-
-	dprintk("%s: Reading ino:%lu %u@%llu\n",
-		__func__, inode->i_ino, hdr->args.count, hdr->args.offset);
-
-	trypnfs = nfss->pnfs_curr_ld->read_pagelist(hdr);
-	if (trypnfs != PNFS_NOT_ATTEMPTED)
-		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
-	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
-	return trypnfs;
+	return NFS_SERVER(hdr->inode)->pnfs_curr_ld->read_pagelist(hdr);
 }
 
 static void
 pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
-	enum pnfs_try_status trypnfs;
 
+	hdr->mds_ops = desc->pg_rpc_callops;
 	desc->pg_lseg = NULL;
-	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
-	if (trypnfs == PNFS_NOT_ATTEMPTED)
+
+	if (pnfs_try_to_read_data(hdr) == PNFS_NOT_ATTEMPTED)
 		pnfs_through_mds(desc, hdr);
+	else
+		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_READ);
 	pnfs_put_lseg(lseg);
 }
 
-- 
1.9.2

