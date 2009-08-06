Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45898
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753279AbZHFSyy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:54:54 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/10] SUNRPC: Introduce xdr_stream-based decoders for
	RPCB_UNSET
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Thu, 06 Aug 2009 14:54:53 -0400
Message-ID: <20090806185452.3458.1774.stgit@matisse.1015granger.net>
In-Reply-To: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Replace the open-coded decode logic for rpcbind UNSET results with an
xdr_stream-based implementation, similar to what NFSv4 uses, to
protect against buffer overflows.

The new function is unused for the moment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index e0d7b31..fe183af 100644
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
+	p = xdr_inline_decode(&xdr, sizeof(__be32));
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

