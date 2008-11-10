From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 62/85] nfs41: Backchannel callback service helper routines
Date: Mon, 10 Nov 2008 22:29:18 +0200
Message-ID: <1226348958-9300-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60017 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYKJU3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:29:25 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Executes the backchannel task on the RPC state machine using
the existing open connection previously established by the client.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>

nfs41: Add bc_svc.o to sunrpc Makefile.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/bc_xprt.h |    3 +
 net/sunrpc/Makefile            |    2 +-
 net/sunrpc/bc_svc.c            |   81 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtsock.c          |    3 +
 4 files changed, 88 insertions(+), 1 deletions(-)
 create mode 100644 net/sunrpc/bc_svc.c

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 8ad9337..9dbeb77 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -29,12 +29,15 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/sched.h>
 
 #ifdef CONFIG_NFS_V4_1
 struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt);
 void xprt_free_bc_request(struct rpc_rqst *req);
 int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
 void xprt_destroy_backchannel(struct rpc_xprt *, int max_reqs);
+void bc_release_request(struct rpc_task *);
+int bc_send(struct rpc_rqst *req);
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* _LINUX_SUNRPC_BC_XPRT_H */
 
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 4a01f96..db73fd2 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -13,6 +13,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
 	    svc_xprt.o
-sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o
+sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
new file mode 100644
index 0000000..669722e
--- /dev/null
+++ b/net/sunrpc/bc_svc.c
@@ -0,0 +1,81 @@
+/******************************************************************************
+
+(c) 2007 Network Appliance, Inc.  All Rights Reserved.
+
+Network Appliance provides this source code under the GPL v2 License.
+The GPL v2 license is available at
+http://opensource.org/licenses/gpl-license.php.
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+******************************************************************************/
+
+/*
+ * The NFSv4.1 callback service helper routines.
+ * They implement the transport level processing required to send the
+ * reply over an existing open connection previously established by the client.
+ */
+
+#if defined(CONFIG_NFS_V4_1)
+
+#include <linux/module.h>
+
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/bc_xprt.h>
+
+#define RPCDBG_FACILITY	RPCDBG_SVCDSP
+
+void bc_release_request(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	dprintk("RPC:       bc_release_request: task= %p\n", task);
+
+	/*
+	 * Release this request only if it's a backchannel
+	 * preallocated request
+	 */
+	if (!bc_prealloc(req))
+		return;
+	xprt_free_bc_request(req);
+}
+
+/* Empty callback ops */
+static const struct rpc_call_ops nfs41_callback_ops = {
+};
+
+
+/*
+ * Send the callback reply
+ */
+int bc_send(struct rpc_rqst *req)
+{
+	struct rpc_task *task;
+	int ret;
+
+	dprintk("RPC:       bc_send req= %p\n", req);
+	task = rpc_run_bc_task(req, &nfs41_callback_ops);
+	if (IS_ERR(task))
+		ret = PTR_ERR(task);
+	else {
+		BUG_ON(atomic_read(&task->tk_count) != 1);
+		ret = task->tk_status;
+		rpc_put_task(task);
+	}
+	return ret;
+	dprintk("RPC:       bc_send ret= %d \n", ret);
+}
+EXPORT_SYMBOL_GPL(bc_send);
+
+#endif /* CONFIG_NFS_V4_1 */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6ccdec8..8513d50 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2046,6 +2046,9 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+#if defined(CONFIG_NFS_V4_1)
+	.release_request	= bc_release_request,
+#endif /* CONFIG_NFS_V4_1 */
 	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
-- 
1.6.0.2

