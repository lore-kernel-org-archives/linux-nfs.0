From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH 3/4] SUNRPC: dynamically load RPC transport modules on-demand
Date: Thu, 05 Mar 2009 16:17:59 -0500
Message-ID: <20090305211759.6517.24300.stgit@localhost.localdomain>
References: <20090305210738.6517.67862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Tom Talpey <tmtalpey@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:49084
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752971AbZCEVSD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:18:03 -0500
In-Reply-To: <20090305210738.6517.67862.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide an api to attempt to load any necessary kernel RPC
client transport module automatically. By convention, the
desired module name is "xprt"+"transport name". For example,
when NFS mounting with "-o proto=rdma", attempt to load the
"xprtrdma" module.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/xprt.c           |   31 +++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 11fc71d..2b0d960 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -235,6 +235,7 @@ static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
  */
 int			xprt_register_transport(struct xprt_class *type);
 int			xprt_unregister_transport(struct xprt_class *type);
+int			xprt_load_transport(const char *);
 void			xprt_set_retrans_timeout_def(struct rpc_task *task);
 void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 29e401b..3fd4d65 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -152,6 +152,37 @@ out:
 EXPORT_SYMBOL_GPL(xprt_unregister_transport);
 
 /**
+ * xprt_load_transport - load a transport implementation
+ * @transport_name: transport to load
+ *
+ * Returns:
+ * 0:		transport successfully loaded
+ * -ENOENT:	transport module not available
+ */
+int xprt_load_transport(const char *transport_name)
+{
+	struct xprt_class *t;
+	char module_name[sizeof t->name + 5];
+	int result;
+
+	result = 0;
+	spin_lock(&xprt_list_lock);
+	list_for_each_entry(t, &xprt_list, list) {
+		if (strcmp(t->name, transport_name) == 0) {
+			spin_unlock(&xprt_list_lock);
+			goto out;
+		}
+	}
+	spin_unlock(&xprt_list_lock);
+	strcpy(module_name, "xprt");
+	strncat(module_name, transport_name, sizeof t->name);
+	result = request_module(module_name);
+out:
+	return result;
+}
+EXPORT_SYMBOL_GPL(xprt_load_transport);
+
+/**
  * xprt_reserve_xprt - serialize write access to transports
  * @task: task that is requesting access to the transport
  *

