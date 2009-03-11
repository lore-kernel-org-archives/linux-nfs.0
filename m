From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/30] SUNRPC: dynamically load RPC transport modules
 on-demand
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184108.5578.78707.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Tom Talpey <tmtalpey@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51671 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754366AbZCKSoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:09 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Talpey <tmtalpey@gmail.com>

Provide an api to attempt to load any necessary kernel RPC
client transport module automatically. By convention, the
desired module name is "xprt"+"transport name". For example,
when NFS mounting with "-o proto=rdma", attempt to load the
"xprtrdma" module.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
index 62098d1..d1afec6 100644
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

