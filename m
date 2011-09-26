Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:63026 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1IZPaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 11:30:15 -0400
Received: by mail-yi0-f46.google.com with SMTP id 18so4308853yib.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 08:30:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFS: Remove no-op less-than-zero checks on unsigned
 variables.
To: linux-nfs@vger.kernel.org
Cc: bjschuma@netapp.com, andros@netapp.com
Date: Mon, 26 Sep 2011 11:30:13 -0400
Message-ID: <20110926153013.8595.41253.stgit@degas.1015granger.net>
In-Reply-To: <20110926152657.8595.6375.stgit@degas.1015granger.net>
References: <20110926152657.8595.6375.stgit@degas.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
 

