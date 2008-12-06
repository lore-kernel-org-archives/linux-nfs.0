From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/27] NSM: Add xdr_stream-based XDR encoders
Date: Fri, 05 Dec 2008 19:02:15 -0500
Message-ID: <20081206000214.24075.58074.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:65389 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbYLFACc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:02:32 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce xdr_stream-based XDR encoder functions.  These are more
careful about preventing RPC buffer overflows.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   82 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 0fc9836..cf85c0f 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -202,6 +202,20 @@ static __be32 *xdr_encode_nsm_string(__be32 *p, char *string)
 	return xdr_encode_opaque(p, string, len);
 }
 
+static int encode_nsm_string(struct xdr_stream *xdr, const char *string)
+{
+	const u32 len = strlen(string);
+	__be32 *p;
+
+	if (unlikely(len > SM_MAXSTRLEN))
+		return -EIO;
+	p = xdr_reserve_space(xdr, sizeof(u32) + len);
+	if (unlikely(p == NULL))
+		return -EIO;
+	xdr_encode_opaque(p, string, len);
+	return 0;
+}
+
 /*
  * "mon_name" specifies the host to be monitored.
  */
@@ -210,6 +224,11 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 	return xdr_encode_nsm_string(p, argp->mon_name);
 }
 
+static int encode_mon_name(struct xdr_stream *xdr, const struct nsm_args *argp)
+{
+	return encode_nsm_string(xdr, argp->mon_name);
+}
+
 /*
  * The "my_id" argument specifies the hostname and RPC procedure
  * to be called when the status manager receives notification
@@ -229,6 +248,23 @@ static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
 	return p;
 }
 
+static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+{
+	int status;
+	__be32 *p;
+
+	status = encode_nsm_string(xdr, utsname()->nodename);
+	if (unlikely(status != 0))
+		return status;
+	p = xdr_reserve_space(xdr, 3 * sizeof(u32));
+	if (unlikely(p == NULL))
+		return -EIO;
+	*p++ = htonl(argp->prog);
+	*p++ = htonl(argp->vers);
+	*p++ = htonl(argp->proc);
+	return 0;
+}
+
 /*
  * The "mon_id" argument specifies the non-private arguments
  * of an NSMPROC_MON or NSMPROC_UNMON call.
@@ -242,6 +278,16 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 	return xdr_encode_my_id(p, argp);
 }
 
+static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
+{
+	int status;
+
+	status = encode_mon_name(xdr, argp);
+	if (unlikely(status != 0))
+		return status;
+	return encode_my_id(xdr, argp);
+}
+
 /*
  * The "priv" argument may contain private information required
  * by the NSMPROC_MON call. This information will be supplied in the
@@ -260,6 +306,20 @@ static __be32 *xdr_encode_priv(__be32 *p, struct nsm_args *argp)
 	return p;
 }
 
+static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, SM_PRIV_SIZE);
+	if (unlikely(p == NULL))
+		return -EIO;
+	*p++ = argp->addr;
+	*p++ = 0;
+	*p++ = 0;
+	*p++ = 0;
+	return 0;
+}
+
 static int
 xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
@@ -275,6 +335,19 @@ xdr_encode_mon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 	return 0;
 }
 
+static int xdr_enc_mon(struct rpc_rqst *req, __be32 *p,
+		       const struct nsm_args *argp)
+{
+	struct xdr_stream xdr;
+	int status;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	status = encode_mon_id(&xdr, argp);
+	if (unlikely(status))
+		return status;
+	return encode_priv(&xdr, argp);
+}
+
 static int
 xdr_encode_unmon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 {
@@ -285,6 +358,15 @@ xdr_encode_unmon(struct rpc_rqst *rqstp, __be32 *p, struct nsm_args *argp)
 	return 0;
 }
 
+static int xdr_enc_unmon(struct rpc_rqst *req, __be32 *p,
+			 const struct nsm_args *argp)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	return encode_mon_id(&xdr, argp);
+}
+
 static int
 xdr_decode_stat_res(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 {

