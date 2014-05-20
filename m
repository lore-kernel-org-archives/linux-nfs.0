Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53894 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbaETSI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:29 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 05/12] nfs: Create a common pnfs_through_mds() function
Date: Tue, 20 May 2014 14:08:12 -0400
Message-ID: <1400609299-32558-6-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 40 ++++++++++++++--------------------------
 1 file changed, 14 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5976b87..a0eee54 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1469,6 +1469,18 @@ static void pnfs_ld_rw_done(struct nfs_pgio_header *hdr,
 	hdr->mds_ops->rpc_release(hdr);
 }
 
+static void
+pnfs_through_mds(struct nfs_pageio_descriptor *desc,
+		 struct nfs_pgio_header *hdr)
+{
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		list_splice_tail_init(&hdr->pages, &desc->pg_list);
+		pnfs_pageio_reset_mds(desc);
+		desc->pg_recoalesce = 1;
+	}
+	nfs_generic_pgio_reset(hdr);
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1498,18 +1510,6 @@ void pnfs_ld_write_done(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
 
-static void
-pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
-		struct nfs_pgio_header *hdr)
-{
-	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
-		list_splice_tail_init(&hdr->pages, &desc->pg_list);
-		pnfs_pageio_reset_mds(desc);
-		desc->pg_recoalesce = 1;
-	}
-	nfs_generic_pgio_reset(hdr);
-}
-
 static enum pnfs_try_status
 pnfs_try_to_write_data(struct nfs_pgio_header *hdr,
 			const struct rpc_call_ops *call_ops,
@@ -1542,7 +1542,7 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 	desc->pg_lseg = NULL;
 	trypnfs = pnfs_try_to_write_data(hdr, call_ops, lseg, how);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
-		pnfs_write_through_mds(desc, hdr);
+		pnfs_through_mds(desc, hdr);
 	pnfs_put_lseg(lseg);
 }
 
@@ -1612,18 +1612,6 @@ void pnfs_ld_read_done(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
 
-static void
-pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
-		struct nfs_pgio_header *hdr)
-{
-	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
-		list_splice_tail_init(&hdr->pages, &desc->pg_list);
-		pnfs_pageio_reset_mds(desc);
-		desc->pg_recoalesce = 1;
-	}
-	nfs_generic_pgio_reset(hdr);
-}
-
 /*
  * Call the appropriate parallel I/O subsystem read function.
  */
@@ -1658,7 +1646,7 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 	desc->pg_lseg = NULL;
 	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
-		pnfs_read_through_mds(desc, hdr);
+		pnfs_through_mds(desc, hdr);
 	pnfs_put_lseg(lseg);
 }
 
-- 
1.9.2

