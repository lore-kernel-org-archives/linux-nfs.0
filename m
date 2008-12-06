From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/27] NSM: Remove unused old-style XDR functions
Date: Fri, 05 Dec 2008 19:02:37 -0500
Message-ID: <20081206000237.24075.60905.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:30578 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbYLFAEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:42 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that they are no longer used, remove the old-style XDR encoder and
decoder functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   88 --------------------------------------------------------
 1 files changed, 0 insertions(+), 88 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 67cce9f..81e1cc1 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -193,15 +193,6 @@ nsm_create(void)
  * Status Monitor wire protocol.
  */
 
-static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
-{
-	size_t len = strlen(string);
-
-	if (len > SM_MAXSTRLEN)
-		len = SM_MAXSTRLEN;
-	return xdr_encode_opaque(p, string, len);
-}
-
 static int encode_nsm_string(struct xdr_stream *xdr, const char *string)
 {
 	const u32 len = strlen(string);
@@ -219,11 +210,6 @@ static int encode_nsm_string(struct xdr_stream *xdr, const char *string)
 /*
  * "mon_name" specifies the host to be monitored.
  */
-static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
-{
-	return xdr_encode_nsm_string(p, argp->mon_name);
-}
-
 static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	return encode_nsm_string(xdr, argp->mon_name);
@@ -235,19 +221,6 @@ static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
  * (via the NLMPROC_SM_NOTIFY call) that the state of host "mon_name"
  * has changed.
  */
-static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
-{
-	p = xdr_encode_nsm_string(p, utsname()->nodename);
-	if (!p)
-		return ERR_PTR(-EIO);
-
-	*p++ = htonl(argp->prog);
-	*p++ = htonl(argp->vers);
-	*p++ = htonl(argp->proc);
-
-	return p;
-}
-
 static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	int status;
@@ -269,15 +242,6 @@ static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
  * The "mon_id" argument specifies the non-private arguments
  * of an NSMPROC_MON or NSMPROC_UNMON call.
  */
-static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
-{
-	p = xdr_encode_mon_name(p, argp);
-	if (!p)
-		return ERR_PTR(-EIO);
-
-	return xdr_encode_my_id(p, argp);
-}
-
 static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	int status;
@@ -296,16 +260,6 @@ static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
  * Linux provides the raw IP address of the monitored host,
  * left in network byte order.
  */
-static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
-{
-	*p++ = argp->addr;
-	*p++ = 0;
-	*p++ = 0;
-	*p++ = 0;
-
-	return p;
-}
-
 static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	__be32 *p;
@@ -320,21 +274,6 @@ static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 	return 0;
 }
 
-static int
-xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
-{
-	p = xdr_encode_mon_id(p, argp);
-	if (IS_ERR(p))
-		return PTR_ERR(p);
-
-	p = xdr_encode_priv(p, argp);
-	if (IS_ERR(p))
-		return PTR_ERR(p);
-
-	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
-	return 0;
-}
-
 static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
 		       const struct nsm_args *argp)
 {
@@ -348,16 +287,6 @@ static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
 	return encode_priv(&xdr, argp);
 }
 
-static int
-xdr_encode_unmon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
-{
-	p = xdr_encode_mon_id(p, argp);
-	if (IS_ERR(p))
-		return PTR_ERR(p);
-	rqstp->rq_slen = xdr_adjust_iovec(rqstp->rq_svec, p);
-	return 0;
-}
-
 static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
 			 const struct nsm_args *argp)
 {
@@ -367,16 +296,6 @@ static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
 	return encode_mon_id(&xdr, argp);
 }
 
-static int
-xdr_decode_stat_res(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
-{
-	resp->status = ntohl(*p++);
-	resp->state = ntohl(*p++);
-	dprintk("nsm: xdr_decode_stat_res status %d state %d\n",
-			resp->status, resp->state);
-	return 0;
-}
-
 static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
 			    struct nsm_res *resp)
 {
@@ -394,13 +313,6 @@ static int xdr_dec_stat_res(struct rpc_rqst *rqstp, __be32 *p,
 	return 0;
 }
 
-static int
-xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
-{
-	resp->state = ntohl(*p++);
-	return 0;
-}
-
 static int xdr_dec_stat(struct rpc_rqst *rqstp, __be32 *p,
 			struct nsm_res *resp)
 {

