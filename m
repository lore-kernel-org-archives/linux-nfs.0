Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51300 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab0LNO6d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:58:33 -0500
Received: by yxt3 with SMTP id 3so378916yxt.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:58:33 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/31] NSM: Avoid return code checking in NSM XDR encoder
	functions
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:30 -0500
Message-ID: <20101214145830.2293.36364.stgit@matisse.1015granger.net>
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

Update the NSM XDR encoders to behave this way.

To finish the update, use the new-style be32_to_cpup() and
cpu_to_be32() macros, and compute the buffer sizes using raw integers
instead of sizeof().  This matches the conventions used in other XDR
functions

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/lockd/mon.c |   68 +++++++++++++++++++++-----------------------------------
 1 files changed, 25 insertions(+), 43 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e0c9189..d812818 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -401,26 +401,22 @@ void nsm_release(struct nsm_handle *nsm)
  * Status Monitor wire protocol.
  */
 
-static int encode_nsm_string(struct xdr_stream *xdr, const char *string)
+static void encode_nsm_string(struct xdr_stream *xdr, const char *string)
 {
 	const u32 len = strlen(string);
 	__be32 *p;
 
-	if (unlikely(len > SM_MAXSTRLEN))
-		return -EIO;
-	p = xdr_reserve_space(xdr, sizeof(u32) + len);
-	if (unlikely(p == NULL))
-		return -EIO;
+	BUG_ON(len > SM_MAXSTRLEN);
+	p = xdr_reserve_space(xdr, 4 + len);
 	xdr_encode_opaque(p, string, len);
-	return 0;
 }
 
 /*
  * "mon_name" specifies the host to be monitored.
  */
-static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
-	return encode_nsm_string(xdr, argp->mon_name);
+	encode_nsm_string(xdr, argp->mon_name);
 }
 
 /*
@@ -429,35 +425,25 @@ static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
  * (via the NLMPROC_SM_NOTIFY call) that the state of host "mon_name"
  * has changed.
  */
-static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
-	int status;
 	__be32 *p;
 
-	status = encode_nsm_string(xdr, utsname()->nodename);
-	if (unlikely(status != 0))
-		return status;
-	p = xdr_reserve_space(xdr, 3 * sizeof(u32));
-	if (unlikely(p == NULL))
-		return -EIO;
-	*p++ = htonl(argp->prog);
-	*p++ = htonl(argp->vers);
-	*p++ = htonl(argp->proc);
-	return 0;
+	encode_nsm_string(xdr, utsname()->nodename);
+	p = xdr_reserve_space(xdr, 4 + 4 + 4);
+	*p++ = cpu_to_be32(argp->prog);
+	*p++ = cpu_to_be32(argp->vers);
+	*p = cpu_to_be32(argp->proc);
 }
 
 /*
  * The "mon_id" argument specifies the non-private arguments
  * of an NSMPROC_MON or NSMPROC_UNMON call.
  */
-static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
-	int status;
-
-	status = encode_mon_name(xdr, argp);
-	if (unlikely(status != 0))
-		return status;
-	return encode_my_id(xdr, argp);
+	encode_mon_name(xdr, argp);
+	encode_my_id(xdr, argp);
 }
 
 /*
@@ -465,28 +451,23 @@ static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
  * by the NSMPROC_MON call. This information will be supplied in the
  * NLMPROC_SM_NOTIFY call.
  */
-static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
+static void encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	__be32 *p;
 
 	p = xdr_reserve_space(xdr, SM_PRIV_SIZE);
-	if (unlikely(p == NULL))
-		return -EIO;
 	xdr_encode_opaque_fixed(p, argp->priv->data, SM_PRIV_SIZE);
-	return 0;
 }
 
 static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
 		       const struct nsm_args *argp)
 {
 	struct xdr_stream xdr;
-	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	status = encode_mon_id(&xdr, argp);
-	if (unlikely(status))
-		return status;
-	return encode_priv(&xdr, argp);
+	encode_mon_id(&xdr, argp);
+	encode_priv(&xdr, argp);
+	return 0;
 }
 
 static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
@@ -495,7 +476,8 @@ static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
 	struct xdr_stream xdr;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	return encode_mon_id(&xdr, argp);
+	encode_mon_id(&xdr, argp);
+	return 0;
 }
 
 static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
@@ -504,11 +486,11 @@ static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
 	struct xdr_stream xdr;
 
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	p = xdr_inline_decode(&xdr, 2 * sizeof(u32));
+	p = xdr_inline_decode(&xdr, 4 + 4);
 	if (unlikely(p == NULL))
 		return -EIO;
-	resp->status = ntohl(*p++);
-	resp->state = ntohl(*p);
+	resp->status = be32_to_cpup(p++);
+	resp->state = be32_to_cpup(p);
 
 	dprintk("lockd: xdr_dec_stat_res status %d state %d\n",
 			resp->status, resp->state);
@@ -521,10 +503,10 @@ static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
 	struct xdr_stream xdr;
 
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	p = xdr_inline_decode(&xdr, sizeof(u32));
+	p = xdr_inline_decode(&xdr, 4);
 	if (unlikely(p == NULL))
 		return -EIO;
-	resp->state = ntohl(*p);
+	resp->state = be32_to_cpup(p);
 
 	dprintk("lockd: xdr_dec_stat state %d\n", resp->state);
 	return 0;

