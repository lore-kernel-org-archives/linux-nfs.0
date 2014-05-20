Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaETSIc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 08/12] nfs: create a common pnfs_do_rw() function
Date: Tue, 20 May 2014 14:08:15 -0400
Message-ID: <1400609299-32558-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The read and write code looks almost identical, so use a simple function
pointer to decide between read_pagelist() and write_pagelist().

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 45 +++++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 293e970..69751d4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1481,6 +1481,24 @@ pnfs_through_mds(struct nfs_pageio_descriptor *desc,
 	nfs_generic_pgio_reset(hdr);
 }
 
+static bool
+pnfs_do_rw(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr,
+	   enum pnfs_try_status (*try_rw)(struct nfs_pgio_header *, int))
+{
+	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+	bool ret = true;
+
+	hdr->mds_ops = desc->pg_rpc_callops;
+	desc->pg_lseg = NULL;
+
+	if (try_rw(hdr, desc->pg_ioflags) == PNFS_NOT_ATTEMPTED) {
+		pnfs_through_mds(desc, hdr);
+		ret = false;
+	}
+	pnfs_put_lseg(lseg);
+	return ret;
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1517,19 +1535,10 @@ pnfs_try_to_write_data(struct nfs_pgio_header *hdr, int how)
 }
 
 static void
-pnfs_do_write(struct nfs_pageio_descriptor *desc,
-	      struct nfs_pgio_header *hdr, int how)
+pnfs_do_write(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
-
-	hdr->mds_ops = desc->pg_rpc_callops;
-	desc->pg_lseg = NULL;
-
-	if (pnfs_try_to_write_data(hdr, how) == PNFS_NOT_ATTEMPTED)
-		pnfs_through_mds(desc, hdr);
-	else
+	if (pnfs_do_rw(desc, hdr, pnfs_try_to_write_data))
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_WRITE);
-	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
@@ -1559,7 +1568,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 	} else
-		pnfs_do_write(desc, hdr, desc->pg_ioflags);
+		pnfs_do_write(desc, hdr);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
@@ -1602,7 +1611,7 @@ EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
  * Call the appropriate parallel I/O subsystem read function.
  */
 static enum pnfs_try_status
-pnfs_try_to_read_data(struct nfs_pgio_header *hdr)
+pnfs_try_to_read_data(struct nfs_pgio_header *hdr, int how)
 {
 	return NFS_SERVER(hdr->inode)->pnfs_curr_ld->read_pagelist(hdr);
 }
@@ -1610,16 +1619,8 @@ pnfs_try_to_read_data(struct nfs_pgio_header *hdr)
 static void
 pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
-	struct pnfs_layout_segment *lseg = desc->pg_lseg;
-
-	hdr->mds_ops = desc->pg_rpc_callops;
-	desc->pg_lseg = NULL;
-
-	if (pnfs_try_to_read_data(hdr) == PNFS_NOT_ATTEMPTED)
-		pnfs_through_mds(desc, hdr);
-	else
+	if (pnfs_do_rw(desc, hdr, pnfs_try_to_read_data))
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_READ);
-	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
-- 
1.9.2

