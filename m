From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 13/39] nfs41: Backchannel bc_svc_process()
Date: Fri,  1 May 2009 02:21:18 +0300
Message-ID: <1241133678-720-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14994 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753402AbZD3XV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:21:28 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Implement the NFSv4.1 backchannel service.  Invokes the common callback
processing logic svc_process_common() to authenticate the call and
dispatch the appropriate NFSv4.1 XDR decoder and operation procedure.
It then invokes bc_send() to send the reply over the same connection.
bc_send() is implemented in a separate patch.

At this time there is no slot validation or reply cache handling.

[nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/svc.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index bfda66d..06b52e4 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -25,6 +25,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/bc_xprt.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
@@ -1239,6 +1240,54 @@ svc_process(struct svc_rqst *rqstp)
 	return svc_send(rqstp);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * Process a backchannel RPC request that arrived over an existing
+ * outbound connection
+ */
+int
+bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
+	       struct svc_rqst *rqstp)
+{
+	struct kvec	*argv = &rqstp->rq_arg.head[0];
+	struct kvec	*resv = &rqstp->rq_res.head[0];
+	int 		error;
+
+	/* Build the svc_rqst used by the common processing routine */
+	rqstp->rq_xid = req->rq_xid;
+	rqstp->rq_prot = req->rq_xprt->prot;
+	rqstp->rq_server = serv;
+
+	rqstp->rq_addrlen = sizeof(req->rq_xprt->addr);
+	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
+	memcpy(&rqstp->rq_arg, &req->rq_rcv_buf, sizeof(rqstp->rq_arg));
+	memcpy(&rqstp->rq_res, &req->rq_snd_buf, sizeof(rqstp->rq_res));
+
+	/* reset result send buffer "put" position */
+	resv->iov_len = 0;
+
+	if (rqstp->rq_prot != IPPROTO_TCP) {
+		printk(KERN_ERR "No support for Non-TCP transports!\n");
+		BUG();
+	}
+
+	/*
+	 * Skip the next two words because they've already been
+	 * processed in the trasport
+	 */
+	svc_getu32(argv);	/* XID */
+	svc_getnl(argv);	/* CALLDIR */
+
+	error = svc_process_common(rqstp, argv, resv);
+	if (error <= 0)
+		return error;
+
+	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
+	return bc_send(req);
+}
+EXPORT_SYMBOL(bc_svc_process);
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * Return (transport-specific) limit on the rpc payload.
  */
-- 
1.6.2.1

