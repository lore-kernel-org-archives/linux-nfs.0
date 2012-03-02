Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:40766 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758615Ab2CBV7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:59:50 -0500
Received: by yhmm54 with SMTP id m54so1040528yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 13:59:49 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/12] NFS: Simplify arguments of encode_renew()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 16:59:48 -0500
Message-ID: <20120302215948.12758.51890.stgit@degas.1015granger.net>
In-Reply-To: <20120302215559.12758.39526.stgit@degas.1015granger.net>
References: <20120302215559.12758.39526.stgit@degas.1015granger.net>
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
index ea01e31..d53c21e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1619,13 +1619,14 @@ static void encode_rename(struct xdr_stream *xdr, const struct qstr *oldname, co
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
@@ -2650,7 +2651,7 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
 	};
 
 	encode_compound_hdr(xdr, req, &hdr);
-	encode_renew(xdr, clp, &hdr);
+	encode_renew(xdr, clp->cl_clientid, &hdr);
 	encode_nops(&hdr);
 }
 

