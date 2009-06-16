From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 23/44] nfsd41: rename nfsd4_enc_uncached_replay
Date: Tue, 16 Jun 2009 04:20:18 +0300
Message-ID: <1245115218-7559-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2386
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756165AbZFPBUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This function is only used for SEQUENCE replay.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index da7c49a..59a7194 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -865,7 +865,7 @@ static const char *nfsd4_op_name(unsigned opnum);
  * encode the uncache rep error on the next operation.
  */
 static __be32
-nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
+nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 			 struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_op *op;
@@ -1000,7 +1000,7 @@ encode_op:
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
 			if (nfsd4_not_cached(resp))
-				status = nfsd4_enc_uncached_replay(args, resp);
+				status = nfsd4_enc_sequence_replay(args, resp);
 			else
 				status = op->status;
 			goto out;
-- 
1.6.3

