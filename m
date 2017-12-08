Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47142 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753241AbdLHRwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:52:38 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: remove unused offset arg in nfs_pgio_rpcsetup
Date: Fri,  8 Dec 2017 12:52:37 -0500
Message-Id: <f6f41cc8d00aa6309100c8f5bb45605d9b4fe3d5.1512749925.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_pgio_rpcsetup() is always called with an offset of 0, so we should be
able to drop the arguement altogether.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pagelist.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index de9066a92c0d..9c9a785933c4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -566,7 +566,7 @@ EXPORT_SYMBOL_GPL(nfs_pgio_data_destroy);
  * @cinfo: Commit information for the call (writes only)
  */
 static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
-			      unsigned int count, unsigned int offset,
+			      unsigned int count,
 			      int how, struct nfs_commit_info *cinfo)
 {
 	struct nfs_page *req = hdr->req;
@@ -575,10 +575,10 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
 	 * NB: take care not to mess about with hdr->commit et al. */
 
 	hdr->args.fh     = NFS_FH(hdr->inode);
-	hdr->args.offset = req_offset(req) + offset;
+	hdr->args.offset = req_offset(req);
 	/* pnfs_set_layoutcommit needs this */
 	hdr->mds_offset = hdr->args.offset;
-	hdr->args.pgbase = req->wb_pgbase + offset;
+	hdr->args.pgbase = req->wb_pgbase;
 	hdr->args.pages  = hdr->page_array.pagevec;
 	hdr->args.count  = count;
 	hdr->args.context = get_nfs_open_context(req->wb_context);
@@ -837,7 +837,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 	/* Set up the argument struct */
-	nfs_pgio_rpcsetup(hdr, mirror->pg_count, 0, desc->pg_ioflags, &cinfo);
+	nfs_pgio_rpcsetup(hdr, mirror->pg_count, desc->pg_ioflags, &cinfo);
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
-- 
2.9.3

