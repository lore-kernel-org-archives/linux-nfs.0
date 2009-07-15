From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] SUNRPC: Introduce xdr_stream-based decoders for
	RPCB_UNSET
Date: Wed, 15 Jul 2009 17:42:09 -0400
Message-ID: <20090715214209.7883.32907.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60981
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752952AbZGOVmM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:42:12 -0400
In-Reply-To: <20090715213842.7883.48947.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open-coded decode logic for rpcbind UNSET results with an
xdr_stream-based implementation, similar to what NFSv4 uses, to
protect against buffer overflows.

The new function is unused for the moment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8da6a9b..d52bb0f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -736,6 +736,28 @@ static int rpcb_decode_set(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int rpcb_dec_set(struct rpc_rqst *req, __be32 *p,
+			unsigned int *boolp)
+{
+	struct rpc_task *task = req->rq_task;
+	struct xdr_stream xdr;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+
+	p = xdr_inline_decode(&xdr, sizeof(u32));
+	if (unlikely(p == NULL))
+		return -EIO;
+
+	*boolp = 0;
+	if (*p)
+		*boolp = 1;
+
+	dprintk("RPC: %5u RPCB_%s call %s\n",
+			task->tk_pid, task->tk_msg.rpc_proc->p_name,
+			(*boolp ? "succeeded" : "failed"));
+	return 0;
+}
+
 static int encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 				const u32 maxstrlen)
 {

