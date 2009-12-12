From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH] nfsd4: Use FIRST_NFS4_OP in nfsd4_decode_compound()
Date: Fri, 11 Dec 2009 20:03:27 -0800
Message-ID: <1260590607-9905-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34110 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735AbZLLEDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 23:03:35 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we're checking for LAST_NFS4_OP, use FIRST_NFS4_OP to be consistent.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b83a24c..3fe0a00 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1442,7 +1442,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		}
 		op->opnum = ntohl(*argp->p++);
 
-		if (op->opnum >= OP_ACCESS && op->opnum <= LAST_NFS4_OP)
+		if (op->opnum >= FIRST_NFS4_OP && op->opnum <= LAST_NFS4_OP)
 			op->status = ops->decoders[op->opnum](argp, &op->u);
 		else {
 			op->opnum = OP_ILLEGAL;
-- 
1.5.4.3

