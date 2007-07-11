From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 02/09] NFS/RDMA client - transport module registry
Date: Wed, 11 Jul 2007 17:07:26 -0400
Message-ID: <EXNANE01XvpFVjCRGry00000c61@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jQf-00022W-0V
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:08:57 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jQi-0003u6-FL
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:00 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL8s1d022131
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:08:54 -0700 (PDT)
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
---

 include/linux/sunrpc/xprt.h |   11 +++++++
 net/sunrpc/xprt.c           |   71 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+), 0 deletions(-)

Index: linux-2.6.22/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.22.orig/include/linux/sunrpc/xprt.h
+++ linux-2.6.22/include/linux/sunrpc/xprt.h
@@ -124,6 +124,15 @@ struct rpc_xprt_ops {
        void            (*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
 };
 
+struct xprt_class {
+       struct list_head        list;
+       unsigned short          family;
+       int                     protocol;
+       struct rpc_xprt *       (*setup)(struct sockaddr *, size_t, struct rpc_timeout *);
+       struct module *         owner;
+       char                    name[32];
+};
+
 struct rpc_xprt {
        struct kref             kref;           /* Reference count */
        struct rpc_xprt_ops *   ops;            /* transport methods */
@@ -227,6 +236,8 @@ static inline __be32 *xprt_skip_transpor
 /*
  * Transport switch helper functions
  */
+int                    xprt_register_transport(struct xprt_class *type);
+int                    xprt_unregister_transport(struct xprt_class *type);
 void                   xprt_set_retrans_timeout_def(struct rpc_task *task);
 void                   xprt_set_retrans_timeout_rtt(struct rpc_task *task);
 void                   xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
@@ -242,8 +253,6 @@ void                        xprt_disconnect(struct rpc_xprt *
 /*
  * Socket transport setup operations
  */
-struct rpc_xprt *      xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
-struct rpc_xprt *      xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to);
 int                    init_socket_xprt(void);
 void                   cleanup_socket_xprt(void);
 
Index: linux-2.6.22/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprt.c
+++ linux-2.6.22/net/sunrpc/xprt.c
@@ -81,6 +81,77 @@ static int      __xprt_get_cong(struct r
 #define RPCXPRT_CONGESTED(xprt) ((xprt)->cong >= (xprt)->cwnd)
 
 /**
+ * xprt_register_transport - register a transport implementation
+ * @transport: transport to register
+ *
+ * If a transport implementation is loaded as a kernel module, it can
+ * call this interface to make itself known to the RPC client.
+ *
+ * Returns:
+ * 0:          transport successfully registered
+ * -EEXIST:    transport already registered
+ * -EINVAL:    transport module being unloaded
+ */
+int xprt_register_transport(struct xprt_class *transport)
+{
+       struct xprt_class *t;
+       int result;
+
+       result = -EEXIST;
+       spin_lock(&xprt_list_lock);
+       list_for_each_entry(t, &xprt_list, list) {
+               /* don't register the same transport class twice */
+               if (t == transport)
+                       goto out;
+       }
+
+       result = -EINVAL;
+       if (try_module_get(THIS_MODULE)) {
+               list_add_tail(&transport->list, &xprt_list);
+               printk(KERN_INFO "RPC: Registered %s transport module.\n",
+                       transport->name);
+               result = 0;
+       }
+
+out:
+       spin_unlock(&xprt_list_lock);
+       return result;
+}
+EXPORT_SYMBOL_GPL(xprt_register_transport);
+
+/**
+ * xprt_unregister_transport - unregister a transport implementation
+ * transport: transport to unregister
+ *
+ * Returns:
+ * 0:          transport successfully unregistered
+ * -ENOENT:    transport never registered
+ */
+int xprt_unregister_transport(struct xprt_class *transport)
+{
+       struct xprt_class *t;
+       int result;
+
+       result = 0;
+       spin_lock(&xprt_list_lock);
+       list_for_each_entry(t, &xprt_list, list) {
+               if (t == transport) {
+                       printk(KERN_INFO "RPC: Unregistered %s transport module.\n",
+                               transport->name);
+                       list_del_init(&transport->list);
+                       module_put(THIS_MODULE);
+                       goto out;
+               }
+       }
+       result = -ENOENT;
+
+out:
+       spin_unlock(&xprt_list_lock);
+       return result;
+}
+EXPORT_SYMBOL_GPL(xprt_unregister_transport);
+
+/**
  * xprt_reserve_xprt - serialize write access to transports
  * @task: task that is requesting access to the transport
  *


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
