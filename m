From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: fix pointer dereference in dprintk of write verifiers
Date: Tue, 29 Jun 2010 15:49:12 +0300
Message-ID: <1277815752-14948-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63034 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752229Ab0F2MtP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:49:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 225023c..8b41a9d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2552,8 +2552,8 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 		RESERVE_SPACE(8);
 		WRITEMEM(commit->co_verf.data, 8);
 		dprintk("NFSD: nfsd4_encode_commit: verifier %x:%x\n",
-			*(u32 *)(&commit->co_verf.data)[0],
-			*(u32 *)(&commit->co_verf.data)[1]);
+			((u32 *)(&commit->co_verf.data))[0],
+			((u32 *)(&commit->co_verf.data))[1]);
 
 		ADJUST_ARGS();
 	}
@@ -3127,8 +3127,8 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 		WRITE32(write->wr_how_written);
 		WRITEMEM(write->wr_verifier.data, 8);
 		dprintk("NFSD: nfsd4_encode_write: verifier %x:%x\n",
-			*(u32 *)(&write->wr_verifier.data)[0],
-			*(u32 *)(&write->wr_verifier.data)[1]);
+			((u32 *)(&write->wr_verifier.data))[0],
+			((u32 *)(&write->wr_verifier.data))[1]);
 		ADJUST_ARGS();
 	}
 	return nfserr;
-- 
1.6.6.1

