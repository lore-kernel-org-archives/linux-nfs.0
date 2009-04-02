From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 09/21] SQUASHME: simplify nfsd4_encode_exchange_id error handling
Date: Fri,  3 Apr 2009 01:38:15 +0300
Message-ID: <1238711895-22303-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28104 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762077AbZDBWiU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:20 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: exchange_id operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9462876..527fadb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2961,7 +2961,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 	uint64_t minor_id = 0;
 
 	if (nfserr)
-		goto out;
+		return nfserr;
 
 	major_id = utsname()->nodename;
 	major_id_sz = strlen(major_id);
@@ -3001,8 +3001,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 	/* Implementation id */
 	WRITE32(0);	/* zero length nfs_impl_id4 array */
 	ADJUST_ARGS();
-out:
-	return nfserr;
+	return 0;
 }
 
 static __be32
-- 
1.6.2.1

