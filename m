From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd-exofs: Change layoutget return codes
Date: Wed, 10 Feb 2010 10:24:46 +0200
Message-ID: <4B726D4E.1000601@panasas.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25023 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752878Ab0BJIYz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 03:24:55 -0500
In-Reply-To: <1265737357-9405-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dependent on patch from Andy:
	[PATCH 1/6] pnfsd: fix file system API layout_get error codes

Change codes to nfs4.1 codes

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index be3d54e..7a59614 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -95,13 +95,13 @@ static int exofs_layout_get(
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
-		err = -E2BIG;
+		err = nfserr_toosmall;
 		goto err;
 	}
 
 	creds = kcalloc(el->s_numdevs, sizeof(*creds), GFP_KERNEL);
 	if (!creds) {
-		err = -ENOMEM;
+		err = nfserr_layouttrylater;
 		goto err;
 	}
 
@@ -134,8 +134,10 @@ static int exofs_layout_get(
 	layout.olo_comps = creds;
 
 	err = pnfs_osd_xdr_encode_layout(xdr, &layout);
-	if (err)
+	if (err) {
+		err = nfserr_toosmall; /*FIXME: Change osd_xdr error codes */
 		goto err;
+	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
 
@@ -146,7 +148,7 @@ static int exofs_layout_get(
 	spin_unlock(&oi->i_layout_lock);
 
 	if (in_recall)
-		err = -EAGAIN;
+		err = nfserr_layouttrylater;
 
 err:
 	kfree(creds);
-- 
1.6.6


