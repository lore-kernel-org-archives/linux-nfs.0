From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfsd41: nfsd4_decode_compound() does not recognize all ops
Date: Fri, 11 Dec 2009 19:10:49 -0800
Message-ID: <1260587449-29538-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762852AbZLLDLJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 22:11:09 -0500
In-Reply-To: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server incorrectly assumes that the operations in the
array start with value 0.  The first operation (OP_ACCESS)
has a value of 3, causing the check in nfsd4_decode_compound
to be off.

Instead of comparing that the operation number is less than
the number of elements in the array, the server should verify
that it is less than the maximum valid operation number
defined by LAST_NFS4_OP.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0fbd50c..b83a24c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1442,7 +1442,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		}
 		op->opnum = ntohl(*argp->p++);
 
-		if (op->opnum >= OP_ACCESS && op->opnum < ops->nops)
+		if (op->opnum >= OP_ACCESS && op->opnum <= LAST_NFS4_OP)
 			op->status = ops->decoders[op->opnum](argp, &op->u);
 		else {
 			op->opnum = OP_ILLEGAL;
-- 
1.5.4.3

