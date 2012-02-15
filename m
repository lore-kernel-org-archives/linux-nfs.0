Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:55973 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab2BOVgT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:36:19 -0500
Received: by ggnh1 with SMTP id h1so960565ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:36:19 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/13] NFS: Simplify arguments of encode_renew()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:36:17 -0500
Message-ID: <20120215213617.3254.57995.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: pass just the piece of data that is needed to encode_renew()
to enable it to be used by callers who might not have an nfs_client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2fb129d..16ee1cf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1622,13 +1622,13 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	hdr->replen += decode_rename_maxsz;
 }
 
-static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
+static void encode_renew(struct xdr_stream *xdr, clientid4 clid, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_RENEW);
-	xdr_encode_hyper(p, client_stateid->cl_clientid);
+	xdr_encode_hyper(p, clid);
 	hdr->nops++;
 	hdr->replen += decode_renew_maxsz;
 }
@@ -2651,7 +2651,7 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
 	};
 
 	encode_compound_hdr(xdr, req, &hdr);
-	encode_renew(xdr, clp, &hdr);
+	encode_renew(xdr, clp->cl_clientid, &hdr);
 	encode_nops(&hdr);
 }
 

