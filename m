From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 12/21] SQUASHME: nfsd41: return nfserr_serverfault for spa_how == SP4_MACH_CRED
Date: Fri,  3 Apr 2009 01:38:27 +0300
Message-ID: <1238711907-22396-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27349 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760514AbZDBWid (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:33 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment, we cannot return nfserr_encr_alg_unsupp
for SP4_MACH_CRED.

squash into "nfsd41: exchange_id operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9cf7d01..c3d555d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1227,8 +1227,16 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_inval;
 
 	/* Currently only support SP4_NONE */
-	if (exid->spa_how != SP4_NONE)
+	switch (exid->spa_how) {
+	case SP4_NONE:
+		break;
+	case SP4_SSV:
 		return nfserr_encr_alg_unsupp;
+	default:
+		BUG();				/* checked by xdr code */
+	case SP4_MACH_CRED:
+		return nfserr_serverfault;	/* no excuse :-/ */
+	}
 
 	status = nfs4_make_rec_clidname(dname, &exid->clname);
 
-- 
1.6.2.1

