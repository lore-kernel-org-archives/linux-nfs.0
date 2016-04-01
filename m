Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33696 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295AbcDAO3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2016 10:29:12 -0400
Received: by mail-io0-f180.google.com with SMTP id a129so145288576ioe.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2016 07:29:11 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/2] pnfs: set NFS_IOHDR_REDO in pnfs_read_resend_pnfs
Date: Fri,  1 Apr 2016 10:29:02 -0400
Message-Id: <1459520943-5558-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1459520943-5558-1-git-send-email-dros@primarydata.com>
References: <1459520943-5558-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Like other resend paths, mark the (old) hdr as NFS_IOHDR_REDO. This
ensures the hdr completion function will not count the (old) hdr
as good bytes.

Also, vector the error back through the hdr->task.tk_status like other
retry calls.

This fixes a bug with the FlexFiles layout where libaio was reporting more
bytes read than requested.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pnfs.c | 13 ++++++++-----
 fs/nfs/pnfs.h |  2 +-
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fa483e6dbe2..da90d665b01f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2143,12 +2143,15 @@ pnfs_try_to_read_data(struct nfs_pgio_header *hdr,
 }
 
 /* Resend all requests through pnfs. */
-int pnfs_read_resend_pnfs(struct nfs_pgio_header *hdr)
+void pnfs_read_resend_pnfs(struct nfs_pgio_header *hdr)
 {
 	struct nfs_pageio_descriptor pgio;
 
-	nfs_pageio_init_read(&pgio, hdr->inode, false, hdr->completion_ops);
-	return nfs_pageio_resend(&pgio, hdr);
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		nfs_pageio_init_read(&pgio, hdr->inode, false,
+					hdr->completion_ops);
+		hdr->task.tk_status = nfs_pageio_resend(&pgio, hdr);
+	}
 }
 EXPORT_SYMBOL_GPL(pnfs_read_resend_pnfs);
 
@@ -2162,8 +2165,8 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 
 	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
 	if (trypnfs == PNFS_TRY_AGAIN)
-		err = pnfs_read_resend_pnfs(hdr);
-	if (trypnfs == PNFS_NOT_ATTEMPTED || err)
+		pnfs_read_resend_pnfs(hdr);
+	if (trypnfs == PNFS_NOT_ATTEMPTED || hdr->task.tk_status)
 		pnfs_read_through_mds(desc, hdr);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1ac1db5f6dad..7222d3a35439 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -282,7 +282,7 @@ int _pnfs_return_layout(struct inode *);
 int pnfs_commit_and_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_pgio_header *);
 void pnfs_ld_read_done(struct nfs_pgio_header *);
-int pnfs_read_resend_pnfs(struct nfs_pgio_header *);
+void pnfs_read_resend_pnfs(struct nfs_pgio_header *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       struct nfs_open_context *ctx,
 					       loff_t pos,
-- 
2.6.4 (Apple Git-63)

