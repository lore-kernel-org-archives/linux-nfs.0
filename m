Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33748 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953766AbdDYUeu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 16:34:50 -0400
Received: by mail-io0-f196.google.com with SMTP id k87so54868471ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 13:34:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: Fix use after free issues in pnfs_do_read()
Date: Tue, 25 Apr 2017 16:34:43 -0400
Message-Id: <20170425203443.37006-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170425203443.37006-2-trond.myklebust@primarydata.com>
References: <20170425203443.37006-1-trond.myklebust@primarydata.com>
 <20170425203443.37006-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The assumption should be that if the caller returns PNFS_ATTEMPTED, then hdr
has been consumed, and so we should not be testing hdr->task.tk_status.
If the caller returns PNFS_TRY_AGAIN, then we need to recoalesce and
free hdr.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 634adb3f8524..eff266ea813c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2419,10 +2419,20 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 	enum pnfs_try_status trypnfs;
 
 	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
-	if (trypnfs == PNFS_TRY_AGAIN)
-		pnfs_read_resend_pnfs(hdr);
-	if (trypnfs == PNFS_NOT_ATTEMPTED || hdr->task.tk_status)
+	switch (trypnfs) {
+	case PNFS_NOT_ATTEMPTED:
 		pnfs_read_through_mds(desc, hdr);
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
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
-- 
2.9.3

