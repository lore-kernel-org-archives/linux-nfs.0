From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 08/21] SQUASHME: simplify nfsd4_encode_create_session error handling
Date: Fri,  3 Apr 2009 01:38:11 +0300
Message-ID: <1238711891-22272-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25203 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761503AbZDBWiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:16 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As per Bruce's review comment.

squash into "nfsd41: create_session operation"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e2213cd..9462876 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3012,7 +3012,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
 	ENCODE_HEAD;
 
 	if (nfserr)
-		goto out;
+		return nfserr;
 
 	RESERVE_SPACE(24);
 	WRITEMEM(sess->sessionid.data, NFS4_MAX_SESSIONID_LEN);
@@ -3051,8 +3051,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
 		WRITE32(sess->back_channel.rdma_attrs);
 		ADJUST_ARGS();
 	}
-out:
-	return nfserr;
+	return 0;
 }
 
 static __be32
-- 
1.6.2.1

