Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34496 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEDR4y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 13:56:54 -0400
Subject: [PATCH v1 01/14] xprtrdma: Transport fault injection
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 13:56:51 -0400
Message-ID: <20150504175651.3483.35554.stgit@manet.1015granger.net>
In-Reply-To: <20150504174626.3483.97639.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It has been exceptionally useful to exercise the logic that handles
local immediate errors and RDMA connection loss.  To enable
developers to test this regularly and repeatably, add logic to
simulate connection loss every so often.

Fault injection is disabled by default. It is enabled with

  $ sudo echo xxx > /proc/sys/sunrpc/rdma_inject_transport_fault

where "xxx" is a large positive number of transport method calls
before a disconnect. A value of several thousand is usually a good
number that allows reasonable forward progress while still causing a
lot of connection drops.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/Kconfig              |   12 ++++++++++++
 net/sunrpc/xprtrdma/transport.c |   34 ++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 3 files changed, 47 insertions(+)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 9068e72..329f82c 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -61,6 +61,18 @@ config SUNRPC_XPRT_RDMA_CLIENT
 
 	  If unsure, say N.
 
+config SUNRPC_XPRT_RDMA_FAULT_INJECTION
+	bool "RPC over RDMA client fault injection"
+	depends on SUNRPC_XPRT_RDMA_CLIENT
+	default N
+	help
+	  This option enables fault injection in the xprtrdma module.
+	  Fault injection is disabled by default. It is enabled with:
+
+	    $ sudo echo xxx > /proc/sys/sunrpc/rdma_inject_fault
+
+	  If unsure, say N.
+
 config SUNRPC_XPRT_RDMA_SERVER
 	tristate "RPC over RDMA Server Support"
 	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 54f23b1..fdcb2c7 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -74,6 +74,7 @@ static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
 		int xprt_rdma_pad_optimize = 1;
+static unsigned int xprt_rdma_inject_transport_fault;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 
@@ -135,6 +136,13 @@ static struct ctl_table xr_tunables_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "rdma_inject_transport_fault",
+		.data		= &xprt_rdma_inject_transport_fault,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ },
 };
 
@@ -246,6 +254,27 @@ xprt_rdma_connect_worker(struct work_struct *work)
 	xprt_clear_connecting(xprt);
 }
 
+#if defined CONFIG_SUNRPC_XPRT_RDMA_FAULT_INJECTION
+static void
+xprt_rdma_inject_disconnect(struct rpcrdma_xprt *r_xprt)
+{
+	if (!xprt_rdma_inject_transport_fault)
+		return;
+
+	if (atomic_dec_return(&r_xprt->rx_inject_count) == 0) {
+		atomic_set(&r_xprt->rx_inject_count,
+			   xprt_rdma_inject_transport_fault);
+		pr_info("rpcrdma: injecting transport disconnect\n");
+		(void)rdma_disconnect(r_xprt->rx_ia.ri_id);
+	}
+}
+#else
+static void
+xprt_rdma_inject_disconnect(struct rpcrdma_xprt *r_xprt)
+{
+}
+#endif
+
 /*
  * xprt_rdma_destroy
  *
@@ -405,6 +434,8 @@ xprt_setup_rdma(struct xprt_create *args)
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
 
+	atomic_set(&new_xprt->rx_inject_count,
+		   xprt_rdma_inject_transport_fault);
 	xprt_rdma_format_addresses(xprt);
 	xprt->max_payload = new_xprt->rx_ia.ri_ops->ro_maxpages(new_xprt);
 	if (xprt->max_payload == 0)
@@ -515,6 +546,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
+	xprt_rdma_inject_disconnect(r_xprt);
 	return req->rl_sendbuf->rg_base;
 
 out_rdmabuf:
@@ -589,6 +621,7 @@ xprt_rdma_free(void *buffer)
 	}
 
 	rpcrdma_buffer_put(req);
+	xprt_rdma_inject_disconnect(r_xprt);
 }
 
 /*
@@ -634,6 +667,7 @@ xprt_rdma_send_request(struct rpc_task *task)
 
 	rqst->rq_xmit_bytes_sent += rqst->rq_snd_buf.len;
 	rqst->rq_bytes_sent = 0;
+	xprt_rdma_inject_disconnect(r_xprt);
 	return 0;
 
 failed_marshal:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 78e0b8b..08aee53 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -377,6 +377,7 @@ struct rpcrdma_xprt {
 	struct rpcrdma_create_data_internal rx_data;
 	struct delayed_work	rx_connect_worker;
 	struct rpcrdma_stats	rx_stats;
+	atomic_t		rx_inject_count;
 };
 
 #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, rx_xprt)

