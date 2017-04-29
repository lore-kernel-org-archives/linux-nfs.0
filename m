Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35299 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031957AbdD2Ssu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Apr 2017 14:48:50 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so16014520iof.2
        for <linux-nfs@vger.kernel.org>; Sat, 29 Apr 2017 11:48:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] pNFS/flexfiles: Fix up the ff_layout_write_pagelist failure path
Date: Sat, 29 Apr 2017 14:48:43 -0400
Message-Id: <20170429184845.58057-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170429184845.58057-1-trond.myklebust@primarydata.com>
References: <20170429184845.58057-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the attempt to write through pNFS fails, we need to use the same
failure semantics as for the read path: If the FF_FLAGS_NO_IO_THRU_MDS
flag is set or we have sufficient valid DSes, then we must retry through
pNFS

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 11 ++++++++---
 fs/nfs/pnfs.c                          | 14 +++++++++++++-
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f23b63eb356e..4e8bf02a62f9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1802,16 +1802,16 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 
 	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
 	if (!ds)
-		return PNFS_NOT_ATTEMPTED;
+		goto out_failed;
 
 	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
 						   hdr->inode);
 	if (IS_ERR(ds_clnt))
-		return PNFS_NOT_ATTEMPTED;
+		goto out_failed;
 
 	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
 	if (!ds_cred)
-		return PNFS_NOT_ATTEMPTED;
+		goto out_failed;
 
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
 
@@ -1841,6 +1841,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 			  sync, RPC_TASK_SOFTCONN);
 	put_rpccred(ds_cred);
 	return PNFS_ATTEMPTED;
+
+out_failed:
+	if (ff_layout_avoid_mds_available_ds(lseg))
+		return PNFS_TRY_AGAIN;
+	return PNFS_NOT_ATTEMPTED;
 }
 
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e45b3ffeda08..6c2e4c73684c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2292,8 +2292,20 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 	enum pnfs_try_status trypnfs;
 
 	trypnfs = pnfs_try_to_write_data(hdr, call_ops, lseg, how);
-	if (trypnfs == PNFS_NOT_ATTEMPTED)
+	switch (trypnfs) {
+	case PNFS_NOT_ATTEMPTED:
 		pnfs_write_through_mds(desc, hdr);
+	case PNFS_ATTEMPTED:
+		break;
+	case PNFS_TRY_AGAIN:
+		/* cleanup hdr and prepare to redo pnfs */
+		if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+			struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
+			list_splice_init(&hdr->pages, &mirror->pg_list);
+			mirror->pg_recoalesce = 1;
+		}
+		hdr->mds_ops->rpc_release(hdr);
+	}
 }
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
-- 
2.9.3

