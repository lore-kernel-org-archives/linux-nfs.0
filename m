Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28644 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab1FMULt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 16:11:49 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Bakeathon 1/2] NFSv4.1: allow zero fh array in filelayout decode layout
Date: Mon, 13 Jun 2011 16:11:45 -0400
Message-Id: <1307995906-4177-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
cc:stable@kernel.org [2.6.39]
---
 fs/nfs/nfs4filelayout.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2cfeaeb..3a8bd92 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -551,13 +551,16 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
 		fl->pattern_offset);
 
-	if (!fl->num_fh)
+	if (fl->num_fh < 0 || fl->num_fh >
+	    max(NFS4_PNFS_MAX_STRIPE_CNT, NFS4_PNFS_MAX_MULTI_CNT))
 		goto out_err;
 
-	fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
-			       gfp_flags);
-	if (!fl->fh_array)
-		goto out_err;
+	if (fl->num_fh > 0) {
+		fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
+				       gfp_flags);
+		if (!fl->fh_array)
+			goto out_err;
+	}
 
 	for (i = 0; i < fl->num_fh; i++) {
 		/* Do we want to use a mempool here? */
-- 
1.7.3.1

