From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/27] NSM: Encode the new "priv" cookie for NSMPROC_MON
	requests
Date: Fri, 05 Dec 2008 19:03:24 -0500
Message-ID: <20081206000323.24075.39019.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49595 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586AbYLFAEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:36 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass the new "priv" cookie to NSMPROC_MON's XDR encoder, instead of
creating the "priv" argument in the encoder at call time.

This patch should not cause a behavioral change: the contents of the
cookie remain the same for the time being.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index a6504f4..e0a799d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -31,7 +31,7 @@ enum {
 };
 
 struct nsm_args {
-	__be32			addr;		/* remote address */
+	struct nsm_private	*priv;
 	u32			prog;		/* RPC callback info */
 	u32			vers;
 	u32			proc;
@@ -102,7 +102,7 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	struct rpc_clnt	*clnt;
 	int		status;
 	struct nsm_args args = {
-		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
+		.priv		= &nsm->sm_priv,
 		.prog		= NLM_PROGRAM,
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
@@ -408,9 +408,6 @@ static int encode_mon_id(struct xdr_stream *xdr, const struct nsm_args *argp)
  * The "priv" argument may contain private information required
  * by the NSMPROC_MON call. This information will be supplied in the
  * NLMPROC_SM_NOTIFY call.
- *
- * Linux provides the raw IP address of the monitored host,
- * left in network byte order.
  */
 static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
@@ -419,10 +416,7 @@ static int encode_priv(struct xdr_stream *xdr, const struct nsm_args *argp)
 	p = xdr_reserve_space(xdr, SM_PRIV_SIZE);
 	if (unlikely(p == NULL))
 		return -EIO;
-	*p++ = argp->addr;
-	*p++ = 0;
-	*p++ = 0;
-	*p++ = 0;
+	xdr_encode_opaque_fixed(p, argp->priv->data, SM_PRIV_SIZE);
 	return 0;
 }
 

