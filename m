Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4815 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752726Ab0BJKrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 05:47:21 -0500
Message-ID: <4B728EB6.9010703@panasas.com>
Date: Wed, 10 Feb 2010 12:47:18 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: andros@netapp.com, Benny Halevy <bhalevy@panasas.com>
CC: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
Subject: [PATCH version2] SQUASHME: pnfsd-exofs: Change layoutget return codes
References: <1265737357-9405-1-git-send-email-andros@netapp.com> <4B726D4E.1000601@panasas.com>
In-Reply-To: <4B726D4E.1000601@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Dependent on patch from Andy:
	[PATCH 1/6] pnfsd: fix file system API layout_get error codes

Change codes to nfs4.1 codes

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index be3d54e..4a4e3a0 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -95,13 +95,13 @@ static int exofs_layout_get(
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
-		err = -E2BIG;
+		err = NFS4ERR_TOOSMALL;
 		goto err;
 	}
 
 	creds = kcalloc(el->s_numdevs, sizeof(*creds), GFP_KERNEL);
 	if (!creds) {
-		err = -ENOMEM;
+		err = NFS4ERR_LAYOUTTRYLATER;
 		goto err;
 	}
 
@@ -134,8 +134,10 @@ static int exofs_layout_get(
 	layout.olo_comps = creds;
 
 	err = pnfs_osd_xdr_encode_layout(xdr, &layout);
-	if (err)
+	if (err) {
+		err = NFS4ERR_TOOSMALL; /*FIXME: Change osd_xdr error codes */
 		goto err;
+	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
 
@@ -146,7 +148,7 @@ static int exofs_layout_get(
 	spin_unlock(&oi->i_layout_lock);
 
 	if (in_recall)
-		err = -EAGAIN;
+		err = NFS4ERR_LAYOUTTRYLATER;
 
 err:
 	kfree(creds);
-- 
1.6.6

