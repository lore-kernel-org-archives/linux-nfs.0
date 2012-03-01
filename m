Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51202 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab2CAWBu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:01:50 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389945iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:01:49 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] NFS: Simplify arguments of encode_renew()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:01:48 -0500
Message-ID: <20120301220148.2138.59190.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: pass just the clientid4 to encode_renew().  This enables it
to be used by callers who might not have an full nfs_client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d1b7914d..8cb35f2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1622,13 +1622,14 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
 	hdr->replen += decode_rename_maxsz;
 }
 
-static void encode_renew(struct xdr_stream *xdr, const struct nfs_client *client_stateid, struct compound_hdr *hdr)
+static void encode_renew(struct xdr_stream *xdr, clientid4 clid,
+			 struct compound_hdr *hdr)
 {
 	__be32 *p;
 
 	p = reserve_space(xdr, 12);
 	*p++ = cpu_to_be32(OP_RENEW);
-	xdr_encode_hyper(p, client_stateid->cl_clientid);
+	xdr_encode_hyper(p, clid);
 	hdr->nops++;
 	hdr->replen += decode_renew_maxsz;
 }
@@ -2653,7 +2654,7 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
 	};
 
 	encode_compound_hdr(xdr, req, &hdr);
-	encode_renew(xdr, clp, &hdr);
+	encode_renew(xdr, clp->cl_clientid, &hdr);
 	encode_nops(&hdr);
 }
 

