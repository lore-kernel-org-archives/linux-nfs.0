From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 09/19] SUNRPC: Finish API to load RPC transport
 implementations dynamically
Date: Mon, 10 Sep 2007 13:46:39 -0400
Message-ID: <EXNANE01ODt9Cz93MgP000004b8@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnZu-0003M3-70
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:01:42 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnZy-0007G5-KC
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:01:46 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI1fVu021174
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:01:41 -0700 (PDT)
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

SUNRPC: Finish API to load RPC transport implementations dynamically
 
Allow RPC client transport implementations to be loaded as needed, or
as they become available from distributors or third-party vendors.

Note that we leave the IP sockets implementation in sunrpc.o
permanently, as IP functionality is always available in any
kernel that runs NFS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 net/sunrpc/xprt.c     |   26 +++++++++++++++-----------
 net/sunrpc/xprtsock.c |   47 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 57 insertions(+), 16 deletions(-)

Index: kernel/net/sunrpc/xprt.c
===================================================================
--- kernel.orig/net/sunrpc/xprt.c
+++ kernel/net/sunrpc/xprt.c
@@ -983,19 +983,23 @@ struct rpc_xprt *xprt_create_transport(s
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
+	struct xprt_class *t;
 
-	switch (args->proto) {
-	case IPPROTO_UDP:
-		xprt = xs_setup_udp(args);
-		break;
-	case IPPROTO_TCP:
-		xprt = xs_setup_tcp(args);
-		break;
-	default:
-		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
-				args->proto);
-		return ERR_PTR(-EIO);
+	spin_lock(&xprt_list_lock);
+	list_for_each_entry(t, &xprt_list, list) {
+		if ((t->family == args->dstaddr->sa_family) &&
+		    (t->protocol == args->proto)) {
+			spin_unlock(&xprt_list_lock);
+			goto found;
+		}
 	}
+	spin_unlock(&xprt_list_lock);
+	printk(KERN_ERR "RPC: transport (%u/%d) not supported\n",
+			args->dstaddr->sa_family, args->proto);
+	return ERR_PTR(-EIO);
+
+found:
+	xprt = t->setup(args);
 	if (IS_ERR(xprt)) {
 		dprintk("RPC:       xprt_create_transport: failed, %ld\n",
 				-PTR_ERR(xprt));
Index: kernel/net/sunrpc/xprtsock.c
===================================================================
--- kernel.orig/net/sunrpc/xprtsock.c
+++ kernel/net/sunrpc/xprtsock.c
@@ -20,6 +20,7 @@
 
 #include <linux/types.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/pagemap.h>
 #include <linux/errno.h>
@@ -777,6 +778,7 @@ static void xs_destroy(struct rpc_xprt *
 	xs_free_peer_addresses(xprt);
 	kfree(xprt->slot);
 	kfree(xprt);
+	module_put(THIS_MODULE);
 }
 
 static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
@@ -1782,7 +1784,8 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 	.print_stats		= xs_tcp_print_stats,
 };
 
-static struct rpc_xprt *xs_setup_xprt(struct rpc_xprtsock_create *args, unsigned int slot_table_size)
+static struct rpc_xprt *xs_setup_xprt(struct rpc_xprtsock_create *args,
+				      unsigned int slot_table_size)
 {
 	struct rpc_xprt *xprt;
 	struct sock_xprt *new;
@@ -1876,7 +1879,12 @@ struct rpc_xprt *xs_setup_udp(struct rpc
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
-	return xprt;
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+
+	kfree(xprt->slot);
+	kfree(xprt);
+	return ERR_PTR(-EINVAL);
 }
 
 /**
@@ -1934,11 +1942,34 @@ struct rpc_xprt *xs_setup_tcp(struct rpc
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
-	return xprt;
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+
+	kfree(xprt->slot);
+	kfree(xprt);
+	return ERR_PTR(-EINVAL);
 }
 
+static struct xprt_class	xs_udp_transport = {
+	.list		= LIST_HEAD_INIT(xs_udp_transport.list),
+	.name		= "udp",
+	.owner		= THIS_MODULE,
+	.family		= AF_INET,
+	.protocol	= IPPROTO_UDP,
+	.setup		= xs_setup_udp,
+};
+
+static struct xprt_class	xs_tcp_transport = {
+	.list		= LIST_HEAD_INIT(xs_tcp_transport.list),
+	.name		= "tcp",
+	.owner		= THIS_MODULE,
+	.family		= AF_INET,
+	.protocol	= IPPROTO_TCP,
+	.setup		= xs_setup_tcp,
+};
+
 /**
- * init_socket_xprt - set up xprtsock's sysctls
+ * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
  */
 int init_socket_xprt(void)
@@ -1948,11 +1979,14 @@ int init_socket_xprt(void)
 		sunrpc_table_header = register_sysctl_table(sunrpc_table);
 #endif
 
+	xprt_register_transport(&xs_udp_transport);
+	xprt_register_transport(&xs_tcp_transport);
+
 	return 0;
 }
 
 /**
- * cleanup_socket_xprt - remove xprtsock's sysctls
+ * cleanup_socket_xprt - remove xprtsock's sysctls, unregister
  *
  */
 void cleanup_socket_xprt(void)
@@ -1963,4 +1997,7 @@ void cleanup_socket_xprt(void)
 		sunrpc_table_header = NULL;
 	}
 #endif
+
+	xprt_unregister_transport(&xs_udp_transport);
+	xprt_unregister_transport(&xs_tcp_transport);
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
