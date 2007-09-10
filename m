From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 08/19] SUNRPC: Provide a new API for registering
 transport implementations
Date: Mon, 10 Sep 2007 13:46:00 -0400
Message-ID: <EXNANE01qFRE7R2V0oH000004b7@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnZT-0003Kq-5h
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:01:15 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnZX-00078g-N4
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:01:19 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI1DOw021058
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:01:13 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

SUNRPC: Provide a new API for registering transport implementations

To allow transport capabilities to be loaded dynamically, provide an API
for registering and unregistering the transports with the RPC client.
Eventually xprt_create_transport() will be changed to search the list of
registered transports when initializing a fresh transport.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/xprt.h |   11 ++++++
 net/sunrpc/xprt.c           |   75 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)

Index: kernel/include/linux/sunrpc/xprt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprt.h
+++ kernel/include/linux/sunrpc/xprt.h
@@ -208,6 +208,15 @@ struct rpc_xprtsock_create {
 	struct rpc_timeout *	timeout;	/* optional timeout parameters */
 };
 
+struct xprt_class {
+	struct list_head	list;
+	unsigned short		family;
+	int			protocol;
+	struct rpc_xprt *	(*setup)(struct rpc_xprtsock_create *);
+	struct module		*owner;
+	char			name[32];
+};
+
 /*
  * Transport operations used by ULPs
  */
@@ -239,6 +248,8 @@ static inline __be32 *xprt_skip_transpor
 /*
  * Transport switch helper functions
  */
+int			xprt_register_transport(struct xprt_class *type);
+int			xprt_unregister_transport(struct xprt_class *type);
 void			xprt_set_retrans_timeout_def(struct rpc_task *task);
 void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
Index: kernel/net/sunrpc/xprt.c
===================================================================
--- kernel.orig/net/sunrpc/xprt.c
+++ kernel/net/sunrpc/xprt.c
@@ -62,6 +62,9 @@ static inline void	do_xprt_reserve(struc
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
+static spinlock_t xprt_list_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(xprt_list);
+
 /*
  * The transport code maintains an estimate on the maximum number of out-
  * standing RPC requests, using a smoothed version of the congestion
@@ -81,6 +84,78 @@ static int      __xprt_get_cong(struct r
 #define RPCXPRT_CONGESTED(xprt) ((xprt)->cong >= (xprt)->cwnd)
 
 /**
+ * xprt_register_transport - register a transport implementation
+ * @transport: transport to register
+ *
+ * If a transport implementation is loaded as a kernel module, it can
+ * call this interface to make itself known to the RPC client.
+ *
+ * Returns:
+ * 0:		transport successfully registered
+ * -EEXIST:	transport already registered
+ * -EINVAL:	transport module being unloaded
+ */
+int xprt_register_transport(struct xprt_class *transport)
+{
+	struct xprt_class *t;
+	int result;
+
+	result = -EEXIST;
+	spin_lock(&xprt_list_lock);
+	list_for_each_entry(t, &xprt_list, list) {
+		/* don't register the same transport class twice */
+		if (t == transport)
+			goto out;
+	}
+
+	result = -EINVAL;
+	if (try_module_get(THIS_MODULE)) {
+		list_add_tail(&transport->list, &xprt_list);
+		printk(KERN_INFO "RPC: Registered %s transport module.\n",
+			transport->name);
+		result = 0;
+	}
+
+out:
+	spin_unlock(&xprt_list_lock);
+	return result;
+}
+EXPORT_SYMBOL_GPL(xprt_register_transport);
+
+/**
+ * xprt_unregister_transport - unregister a transport implementation
+ * transport: transport to unregister
+ *
+ * Returns:
+ * 0:		transport successfully unregistered
+ * -ENOENT:	transport never registered
+ */
+int xprt_unregister_transport(struct xprt_class *transport)
+{
+	struct xprt_class *t;
+	int result;
+
+	result = 0;
+	spin_lock(&xprt_list_lock);
+	list_for_each_entry(t, &xprt_list, list) {
+		if (t == transport) {
+			printk(KERN_INFO
+				"RPC: Unregistered %s transport module.\n",
+				transport->name);
+			list_del_init(&transport->list);
+			module_put(THIS_MODULE);
+			goto out;
+		}
+	}
+	result = -ENOENT;
+
+out:
+	spin_unlock(&xprt_list_lock);
+	return result;
+}
+EXPORT_SYMBOL_GPL(xprt_unregister_transport);
+
+/**
  * xprt_reserve_xprt - serialize write access to transports
  * @task: task that is requesting access to the transport
  *

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
