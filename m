Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34118 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcLAWGh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:06:37 -0500
Received: by mail-io0-f193.google.com with SMTP id r94so3851382ioe.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:06:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Don't request a GETATTR on open_downgrade.
Date: Thu,  1 Dec 2016 17:06:30 -0500
Message-Id: <20161201220632.12754-4-trond.myklebust@primarydata.com>
In-Reply-To: <20161201220632.12754-3-trond.myklebust@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
 <20161201220632.12754-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're not closing the file completely, there is no need to request
close-to-open attributes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc89e5ed07ee..c37473721230 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -499,14 +499,12 @@ static int nfs4_stat_to_errno(int);
 				(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
-				 encode_open_downgrade_maxsz + \
-				 encode_getattr_maxsz)
+				 encode_open_downgrade_maxsz)
 #define NFS4_dec_open_downgrade_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
-				 decode_open_downgrade_maxsz + \
-				 decode_getattr_maxsz)
+				 decode_open_downgrade_maxsz)
 #define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
@@ -2328,7 +2326,6 @@ static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open_downgrade(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6115,9 +6112,6 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_open_downgrade(xdr, res);
-	if (status != 0)
-		goto out;
-	decode_getfattr(xdr, res->fattr, res->server);
 out:
 	return status;
 }
-- 
2.9.3

