Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:63603 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0LNO7C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:59:02 -0500
Received: by gwb20 with SMTP id 20so543664gwb.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:59:02 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 28/31] SUNRPC: Avoid return code checking in rpcbind XDR
	encoder functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:59 -0500
Message-ID: <20101214145859.2293.84240.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The trend in the other XDR encoder functions is to BUG() when encoding
problems occur, since a problem here is always due to a local coding
error.  Then, instead of a status, zero is unconditionally returned.

Update the rpcbind XDR encoders to behave this way.

To finish the update, use the new-style be32_to_cpup() and
cpu_to_be32() macros, and compute the buffer sizes using raw integers
instead of sizeof().  This matches the conventions used in other XDR
functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 net/sunrpc/rpcb_clnt.c |   60 +++++++++++++++++-------------------------------
 1 files changed, 21 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index fa6d7ca..d2a2ea0 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -705,14 +705,11 @@ static int rpcb_enc_mapping(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 
-	p = xdr_reserve_space(&xdr, sizeof(__be32) * RPCB_mappingargs_sz);
-	if (unlikely(p == NULL))
-		return -EIO;
-
-	*p++ = htonl(rpcb->r_prog);
-	*p++ = htonl(rpcb->r_vers);
-	*p++ = htonl(rpcb->r_prot);
-	*p   = htonl(rpcb->r_port);
+	p = xdr_reserve_space(&xdr, RPCB_mappingargs_sz << 2);
+	*p++ = cpu_to_be32(rpcb->r_prog);
+	*p++ = cpu_to_be32(rpcb->r_vers);
+	*p++ = cpu_to_be32(rpcb->r_prot);
+	*p   = cpu_to_be32(rpcb->r_port);
 
 	return 0;
 }
@@ -728,11 +725,11 @@ static int rpcb_dec_getport(struct rpc_rqst *req, __be32 *p,
 
 	rpcb->r_port = 0;
 
-	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	p = xdr_inline_decode(&xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 
-	port = ntohl(*p);
+	port = be32_to_cpup(p);
 	dprintk("RPC: %5u PMAP_%s result: %lu\n", task->tk_pid,
 			task->tk_msg.rpc_proc->p_name, port);
 	if (unlikely(port > USHRT_MAX))
@@ -750,7 +747,7 @@ static int rpcb_dec_set(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 
-	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	p = xdr_inline_decode(&xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
 
@@ -764,24 +761,16 @@ static int rpcb_dec_set(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
-static int encode_rpcb_string(struct xdr_stream *xdr, const char *string,
-				const u32 maxstrlen)
+static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
+			       const u32 maxstrlen)
 {
-	u32 len;
 	__be32 *p;
+	u32 len;
 
-	if (unlikely(string == NULL))
-		return -EIO;
 	len = strlen(string);
-	if (unlikely(len > maxstrlen))
-		return -EIO;
-
-	p = xdr_reserve_space(xdr, sizeof(__be32) + len);
-	if (unlikely(p == NULL))
-		return -EIO;
+	BUG_ON(len > maxstrlen);
+	p = xdr_reserve_space(xdr, 4 + len);
 	xdr_encode_opaque(p, string, len);
-
-	return 0;
 }
 
 static int rpcb_enc_getaddr(struct rpc_rqst *req, __be32 *p,
@@ -797,20 +786,13 @@ static int rpcb_enc_getaddr(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 
-	p = xdr_reserve_space(&xdr,
-			sizeof(__be32) * (RPCB_program_sz + RPCB_version_sz));
-	if (unlikely(p == NULL))
-		return -EIO;
-	*p++ = htonl(rpcb->r_prog);
-	*p = htonl(rpcb->r_vers);
-
-	if (encode_rpcb_string(&xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN))
-		return -EIO;
-	if (encode_rpcb_string(&xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN))
-		return -EIO;
-	if (encode_rpcb_string(&xdr, rpcb->r_owner, RPCB_MAXOWNERLEN))
-		return -EIO;
+	p = xdr_reserve_space(&xdr, (RPCB_program_sz + RPCB_version_sz) << 2);
+	*p++ = cpu_to_be32(rpcb->r_prog);
+	*p = cpu_to_be32(rpcb->r_vers);
 
+	encode_rpcb_string(&xdr, rpcb->r_netid, RPCBIND_MAXNETIDLEN);
+	encode_rpcb_string(&xdr, rpcb->r_addr, RPCBIND_MAXUADDRLEN);
+	encode_rpcb_string(&xdr, rpcb->r_owner, RPCB_MAXOWNERLEN);
 	return 0;
 }
 
@@ -827,10 +809,10 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, __be32 *p,
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
 
-	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	p = xdr_inline_decode(&xdr, 4);
 	if (unlikely(p == NULL))
 		goto out_fail;
-	len = ntohl(*p);
+	len = be32_to_cpup(p);
 
 	/*
 	 * If the returned universal address is a null string,

