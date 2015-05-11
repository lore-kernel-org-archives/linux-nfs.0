Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35532 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbbEKSEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:04:53 -0400
Subject: [PATCH v2 16/16] SUNRPC: Clean up bc_send()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:04:50 -0400
Message-ID: <20150511180450.31263.29472.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Merge bc_send() into bc_svc_process().

Note: even thought this touches svc.c, it is a client-side change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/bc_xprt.h |    1 -
 net/sunrpc/Makefile            |    2 +
 net/sunrpc/bc_svc.c            |   63 ----------------------------------------
 net/sunrpc/svc.c               |   33 ++++++++++++++++-----
 4 files changed, 26 insertions(+), 73 deletions(-)
 delete mode 100644 net/sunrpc/bc_svc.c

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 2ca67b5..8df43c9f 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -37,7 +37,6 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied);
 void xprt_free_bc_request(struct rpc_rqst *req);
 int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
 void xprt_destroy_backchannel(struct rpc_xprt *, unsigned int max_reqs);
-int bc_send(struct rpc_rqst *req);
 
 /*
  * Determine if a shared backchannel is in use
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 15e6f6c..1b8e68d 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -15,6 +15,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
 	    svc_xprt.o
 sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
-sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o bc_svc.o
+sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
deleted file mode 100644
index 15c7a8a..0000000
--- a/net/sunrpc/bc_svc.c
+++ /dev/null
@@ -1,63 +0,0 @@
-/******************************************************************************
-
-(c) 2007 Network Appliance, Inc.  All Rights Reserved.
-(c) 2009 NetApp.  All Rights Reserved.
-
-NetApp provides this source code under the GPL v2 License.
-The GPL v2 license is available at
-http://opensource.org/licenses/gpl-license.php.
-
-THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-
-******************************************************************************/
-
-/*
- * The NFSv4.1 callback service helper routines.
- * They implement the transport level processing required to send the
- * reply over an existing open connection previously established by the client.
- */
-
-#include <linux/module.h>
-
-#include <linux/sunrpc/xprt.h>
-#include <linux/sunrpc/sched.h>
-#include <linux/sunrpc/bc_xprt.h>
-
-#define RPCDBG_FACILITY	RPCDBG_SVCDSP
-
-/* Empty callback ops */
-static const struct rpc_call_ops nfs41_callback_ops = {
-};
-
-
-/*
- * Send the callback reply
- */
-int bc_send(struct rpc_rqst *req)
-{
-	struct rpc_task *task;
-	int ret;
-
-	dprintk("RPC:       bc_send req= %p\n", req);
-	task = rpc_run_bc_task(req, &nfs41_callback_ops);
-	if (IS_ERR(task))
-		ret = PTR_ERR(task);
-	else {
-		WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
-		ret = task->tk_status;
-		rpc_put_task(task);
-	}
-	dprintk("RPC:       bc_send ret= %d\n", ret);
-	return ret;
-}
-
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78974e4..e144902 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1350,6 +1350,11 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 {
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
+	static const struct rpc_call_ops reply_ops = { };
+	struct rpc_task *task;
+	int error;
+
+	dprintk("svc: %s(%p)\n", __func__, req);
 
 	/* Build the svc_rqst used by the common processing routine */
 	rqstp->rq_xprt = serv->sv_bc_xprt;
@@ -1372,21 +1377,33 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 
 	/*
 	 * Skip the next two words because they've already been
-	 * processed in the trasport
+	 * processed in the transport
 	 */
 	svc_getu32(argv);	/* XID */
 	svc_getnl(argv);	/* CALLDIR */
 
-	/* Returns 1 for send, 0 for drop */
-	if (svc_process_common(rqstp, argv, resv)) {
-		memcpy(&req->rq_snd_buf, &rqstp->rq_res,
-						sizeof(req->rq_snd_buf));
-		return bc_send(req);
-	} else {
-		/* drop request */
+	/* Parse and execute the bc call */
+	if (!svc_process_common(rqstp, argv, resv)) {
+		/* Processing error: drop the request */
 		xprt_free_bc_request(req);
 		return 0;
 	}
+
+	/* Finally, send the reply synchronously */
+	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
+	task = rpc_run_bc_task(req, &reply_ops);
+	if (IS_ERR(task)) {
+		error = PTR_ERR(task);
+		goto out;
+	}
+
+	WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
+	error = task->tk_status;
+	rpc_put_task(task);
+
+out:
+	dprintk("svc: %s(), error=%d\n", __func__, error);
+	return error;
 }
 EXPORT_SYMBOL_GPL(bc_svc_process);
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */

