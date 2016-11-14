Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33790 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932755AbcKNUzo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 15:55:44 -0500
Received: by mail-it0-f65.google.com with SMTP id c20so14364394itb.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 12:55:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/5] NFSv4: Don't request a GETATTR on open_downgrade.
Date: Mon, 14 Nov 2016 15:55:33 -0500
Message-Id: <1479156935-34479-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1479156935-34479-3-git-send-email-trond.myklebust@primarydata.com>
References: <1479156935-34479-1-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-2-git-send-email-trond.myklebust@primarydata.com>
 <1479156935-34479-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're not closing the file completely, there is no need to request
close-to-open attributes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc89e5ed07ee..43cc989b5c06 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2328,7 +2328,6 @@ static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open_downgrade(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6115,9 +6114,6 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
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
2.7.4

