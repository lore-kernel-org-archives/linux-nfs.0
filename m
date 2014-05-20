Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaETSI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:27 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 04/12] nfs: Create a common pnfs_ld_rw_done()
Date: Tue, 20 May 2014 14:08:11 -0400
Message-ID: <1400609299-32558-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The read and write paths run mostly the same code, so it makes sense to
combine them.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4eaf74a..5976b87 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1457,6 +1457,18 @@ static void pnfs_ld_handle_rw_error(struct nfs_pgio_header *hdr,
 		hdr->task.tk_status = resend_to_mds(hdr);
 }
 
+static void pnfs_ld_rw_done(struct nfs_pgio_header *hdr,
+			    void (*cb)(struct nfs_pgio_header *),
+			    int (*resend_to_mds)(struct nfs_pgio_header *))
+{
+	if (!hdr->pnfs_error) {
+		cb(hdr);
+		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
+	} else
+		pnfs_ld_handle_rw_error(hdr, resend_to_mds);
+	hdr->mds_ops->rpc_release(hdr);
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1482,12 +1494,7 @@ EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
 void pnfs_ld_write_done(struct nfs_pgio_header *hdr)
 {
 	trace_nfs4_pnfs_write(hdr, hdr->pnfs_error);
-	if (!hdr->pnfs_error) {
-		pnfs_set_layoutcommit(hdr);
-		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
-	} else
-		pnfs_ld_handle_rw_error(hdr, pnfs_write_done_resend_to_mds);
-	hdr->mds_ops->rpc_release(hdr);
+	pnfs_ld_rw_done(hdr, pnfs_set_layoutcommit, pnfs_write_done_resend_to_mds);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
 
@@ -1601,12 +1608,7 @@ EXPORT_SYMBOL_GPL(pnfs_read_done_resend_to_mds);
 void pnfs_ld_read_done(struct nfs_pgio_header *hdr)
 {
 	trace_nfs4_pnfs_read(hdr, hdr->pnfs_error);
-	if (likely(!hdr->pnfs_error)) {
-		__nfs4_read_done_cb(hdr);
-		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
-	} else
-		pnfs_ld_handle_rw_error(hdr, pnfs_read_done_resend_to_mds);
-	hdr->mds_ops->rpc_release(hdr);
+	pnfs_ld_rw_done(hdr, __nfs4_read_done_cb, pnfs_read_done_resend_to_mds);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
 
-- 
1.9.2

