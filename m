Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62181 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab1JYQSH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 12:18:07 -0400
Received: by mail-yw0-f46.google.com with SMTP id 3so650637ywm.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 Oct 2011 09:18:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFS: Remove no-op less-than-zero checks on unsigned
 variables.
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 25 Oct 2011 12:18:03 -0400
Message-ID: <20111025161803.5996.75238.stgit@seurat.1015granger.net>
In-Reply-To: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
References: <20111025161631.5996.30680.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduced by commit 16b374ca "NFSv4.1: pnfs: filelayout: add driver's
LAYOUTGET and GETDEVICEINFO infrastructure" (October 20, 2010).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4filelayout.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e8915d4..bbc5a21 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -468,9 +468,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 
 	fl->dsaddr = dsaddr;
 
-	if (fl->first_stripe_index < 0 ||
-	    fl->first_stripe_index >= dsaddr->stripe_count) {
-		dprintk("%s Bad first_stripe_index %d\n",
+	if (fl->first_stripe_index >= dsaddr->stripe_count) {
+		dprintk("%s Bad first_stripe_index %u\n",
 				__func__, fl->first_stripe_index);
 		goto out_put;
 	}
@@ -571,7 +570,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 
 	/* Note that a zero value for num_fh is legal for STRIPE_SPARSE.
 	 * Futher checking is done in filelayout_check_layout */
-	if (fl->num_fh < 0 || fl->num_fh >
+	if (fl->num_fh >
 	    max(NFS4_PNFS_MAX_STRIPE_CNT, NFS4_PNFS_MAX_MULTI_CNT))
 		goto out_err;
 

