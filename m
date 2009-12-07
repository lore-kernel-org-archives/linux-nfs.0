From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 20/35] pnfsd: LAYOUTGET layout stateid processing
Date: Mon,  7 Dec 2009 11:34:12 +0200
Message-ID: <1260178452-15371-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1219 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934886AbZLGJdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:33:16 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: clean up layoutget export API]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |    5 +++++
 fs/nfsd/nfs4xdr.c   |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index a72fe19..9543e96 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -443,6 +443,11 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 	if (!fp || !clp)
 		goto out;
 
+	/* Check decoded layout stateid */
+	status = nfs4_process_layout_stateid(clp, fp, &lgp->lg_sid, &ls);
+	if (status)
+		goto out;
+
 	/* pre-alloc layout in case we can't merge after we call
 	 * the file system
 	 */
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 949e92d..2760564 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3369,7 +3369,7 @@ nfsd4_encode_layoutget(struct nfsd4_compoundres *resp,
 	if (xdr.end - xdr.p > exp_xdr_qwords(maxcount & ~3))
 		xdr.end = xdr.p + exp_xdr_qwords(maxcount & ~3);
 
-	/* Retrieve, encode, and merge layout */
+	/* Retrieve, encode, and merge layout; process stateid */
 	nfserr = nfs4_pnfs_get_layout(lgp, &xdr);
 	if (nfserr)
 		goto err;
-- 
1.6.5.1

