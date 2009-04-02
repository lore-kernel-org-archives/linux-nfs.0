From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 07/21] SQUASHME: simplify nfsd4_encode_sequence error handling
Date: Fri,  3 Apr 2009 01:38:06 +0300
Message-ID: <1238711886-22241-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27645 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759861AbZDBWiM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:12 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: sequence operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0084459..e2213cd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3069,7 +3069,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	ENCODE_HEAD;
 
 	if (nfserr)
-		goto out;
+		return nfserr;
 
 	RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 20);
 	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
@@ -3085,8 +3085,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(0);
 
 	ADJUST_ARGS();
-out:
-	return nfserr;
+	return 0;
 }
 #endif /* CONFIG_NFSD_V4_1 */
 
-- 
1.6.2.1

