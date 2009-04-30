From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 12/39] nfs41: Refactor svc_process()
Date: Fri,  1 May 2009 02:21:04 +0300
Message-ID: <1241133664-688-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4046 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753797AbZD3XVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:21:16 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

net/sunrpc/svc.c:svc_process() is used by the NFSv4 callback service
to process RPC requests arriving over connections initiated by the
server.  NFSv4.1 supports callbacks over the backchannel on connections
initiated by the client.  This patch refactors svc_process() so that
common code can also be used by the backchannel.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/svc.c |   80 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 50 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8847add..bfda66d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -970,20 +970,18 @@ svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 }
 
 /*
- * Process the RPC request.
+ * Common routine for processing the RPC request.
  */
-int
-svc_process(struct svc_rqst *rqstp)
+static int
+svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 {
 	struct svc_program	*progp;
 	struct svc_version	*versp = NULL;	/* compiler food */
 	struct svc_procedure	*procp = NULL;
-	struct kvec *		argv = &rqstp->rq_arg.head[0];
-	struct kvec *		resv = &rqstp->rq_res.head[0];
 	struct svc_serv		*serv = rqstp->rq_server;
 	kxdrproc_t		xdr;
 	__be32			*statp;
-	u32			dir, prog, vers, proc;
+	u32			prog, vers, proc;
 	__be32			auth_stat, rpc_stat;
 	int			auth_res;
 	__be32			*reply_statp;
@@ -993,19 +991,6 @@ svc_process(struct svc_rqst *rqstp)
 	if (argv->iov_len < 6*4)
 		goto err_short_len;
 
-	/* setup response xdr_buf.
-	 * Initially it has just one page
-	 */
-	rqstp->rq_resused = 1;
-	resv->iov_base = page_address(rqstp->rq_respages[0]);
-	resv->iov_len = 0;
-	rqstp->rq_res.pages = rqstp->rq_respages + 1;
-	rqstp->rq_res.len = 0;
-	rqstp->rq_res.page_base = 0;
-	rqstp->rq_res.page_len = 0;
-	rqstp->rq_res.buflen = PAGE_SIZE;
-	rqstp->rq_res.tail[0].iov_base = NULL;
-	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
 	/* Will be turned off only when NFSv4 Sessions are used */
@@ -1014,17 +999,13 @@ svc_process(struct svc_rqst *rqstp)
 	/* Setup reply header */
 	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
-	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
 
-	dir  = svc_getnl(argv);
 	vers = svc_getnl(argv);
 
 	/* First words of reply: */
 	svc_putnl(resv, 1);		/* REPLY */
 
-	if (dir != 0)		/* direction != CALL */
-		goto err_bad_dir;
 	if (vers != 2)		/* RPC version number */
 		goto err_bad_rpc;
 
@@ -1147,7 +1128,7 @@ svc_process(struct svc_rqst *rqstp)
  sendit:
 	if (svc_authorise(rqstp))
 		goto dropit;
-	return svc_send(rqstp);
+	return 1;		/* Caller can now send it */
 
  dropit:
 	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
@@ -1161,12 +1142,6 @@ err_short_len:
 
 	goto dropit;			/* drop request */
 
-err_bad_dir:
-	svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
-
-	serv->sv_stats->rpcbadfmt++;
-	goto dropit;			/* drop request */
-
 err_bad_rpc:
 	serv->sv_stats->rpcbadfmt++;
 	svc_putnl(resv, 1);	/* REJECT */
@@ -1220,6 +1195,51 @@ err_bad:
 EXPORT_SYMBOL_GPL(svc_process);
 
 /*
+ * Process the RPC request.
+ */
+int
+svc_process(struct svc_rqst *rqstp)
+{
+	struct kvec		*argv = &rqstp->rq_arg.head[0];
+	struct kvec		*resv = &rqstp->rq_res.head[0];
+	struct svc_serv		*serv = rqstp->rq_server;
+	u32			dir;
+	int			error;
+
+	/*
+	 * Setup response xdr_buf.
+	 * Initially it has just one page
+	 */
+	rqstp->rq_resused = 1;
+	resv->iov_base = page_address(rqstp->rq_respages[0]);
+	resv->iov_len = 0;
+	rqstp->rq_res.pages = rqstp->rq_respages + 1;
+	rqstp->rq_res.len = 0;
+	rqstp->rq_res.page_base = 0;
+	rqstp->rq_res.page_len = 0;
+	rqstp->rq_res.buflen = PAGE_SIZE;
+	rqstp->rq_res.tail[0].iov_base = NULL;
+	rqstp->rq_res.tail[0].iov_len = 0;
+
+	rqstp->rq_xid = svc_getu32(argv);
+
+	dir  = svc_getnl(argv);
+	if (dir != 0) {
+		/* direction != CALL */
+		svc_printk(rqstp, "bad direction %d, dropping request\n", dir);
+		serv->sv_stats->rpcbadfmt++;
+		svc_drop(rqstp);
+		return 0;
+	}
+
+	error = svc_process_common(rqstp, argv, resv);
+	if (error <= 0)
+		return error;
+
+	return svc_send(rqstp);
+}
+
+/*
  * Return (transport-specific) limit on the rpc payload.
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
-- 
1.6.2.1

