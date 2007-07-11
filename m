From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 03/09] NFS/RDMA client - sockets transport
Date: Wed, 11 Jul 2007 17:07:31 -0400
Message-ID: <EXNANE01WtIIZS2TRqf00000c62@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jR0-000280-Q4
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jR4-00043q-4h
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:22 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL9GVw019275
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:09:16 -0700 (PDT)
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

Note that we leave the IPv4 sockets implementation in sunrpc.o
permanently, as IPv4 functionality is always available in any
kernel that runs NFS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    6 -----
 net/sunrpc/xprt.c           |   29 ++++++++++++++++----------
 net/sunrpc/xprtsock.c       |   48 ++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 60 insertions(+), 23 deletions(-)

Index: linux-2.6.22/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprt.c
+++ linux-2.6.22/net/sunrpc/xprt.c
@@ -62,6 +62,9 @@ static inline void    do_xprt_reserve(struc
 static void    xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
+static spinlock_t xprt_list_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(xprt_list);
+
 /*
  * The transport code maintains an estimate on the maximum number of out-
  * standing RPC requests, using a smoothed version of the congestion
@@ -982,19 +985,23 @@ struct rpc_xprt *xprt_create_transport(i
 {
        struct rpc_xprt *xprt;
        struct rpc_rqst *req;
+       struct xprt_class *t;
 
-       switch (proto) {
-       case IPPROTO_UDP:
-               xprt = xs_setup_udp(ap, size, to);
-               break;
-       case IPPROTO_TCP:
-               xprt = xs_setup_tcp(ap, size, to);
-               break;
-       default:
-               printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
-                               proto);
-               return ERR_PTR(-EIO);
+       spin_lock(&xprt_list_lock);
+       list_for_each_entry(t, &xprt_list, list) {
+               if ((t->family == ap->sa_family) &&
+                   (t->protocol == proto)) {
+                       spin_unlock(&xprt_list_lock);
+                       goto found;
+               }
        }
+       spin_unlock(&xprt_list_lock);
+       printk(KERN_ERR "RPC: transport (%u/%d) not supported\n",
+                       ap->sa_family, proto);
+       return ERR_PTR(-EIO);
+
+found:
+       xprt = t->setup(ap, size, to);
        if (IS_ERR(xprt)) {
                dprintk("RPC:       xprt_create_transport: failed, %ld\n",
                                -PTR_ERR(xprt));
Index: linux-2.6.22/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprtsock.c
+++ linux-2.6.22/net/sunrpc/xprtsock.c
@@ -17,6 +17,7 @@
 
 #include <linux/types.h>
 #include <linux/slab.h>
+#include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/pagemap.h>
 #include <linux/errno.h>
@@ -661,6 +662,7 @@ static void xs_destroy(struct rpc_xprt *
        xs_free_peer_addresses(xprt);
        kfree(xprt->slot);
        kfree(xprt);
+       module_put(THIS_MODULE);
 }
 
 static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
@@ -1546,7 +1548,7 @@ static struct rpc_xprt *xs_setup_xprt(st
  * @to:   timeout parameters
  *
  */
-struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
+static struct rpc_xprt *xs_setup_udp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
        struct rpc_xprt *xprt;
        struct sock_xprt *transport;
@@ -1581,7 +1583,12 @@ struct rpc_xprt *xs_setup_udp(struct soc
        dprintk("RPC:       set up transport to address %s\n",
                        xprt->address_strings[RPC_DISPLAY_ALL]);
 
-       return xprt;
+       if (try_module_get(THIS_MODULE))
+               return xprt;
+
+       kfree(xprt->slot);
+       kfree(xprt);
+       return ERR_PTR(-EINVAL);
 }
 
 /**
@@ -1591,7 +1598,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
  * @to: timeout parameters
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
+static struct rpc_xprt *xs_setup_tcp(struct sockaddr *addr, size_t addrlen, struct rpc_timeout *to)
 {
        struct rpc_xprt *xprt;
        struct sock_xprt *transport;
@@ -1625,11 +1632,34 @@ struct rpc_xprt *xs_setup_tcp(struct soc
        dprintk("RPC:       set up transport to address %s\n",
                        xprt->address_strings[RPC_DISPLAY_ALL]);
 
-       return xprt;
+       if (try_module_get(THIS_MODULE))
+               return xprt;
+
+       kfree(xprt->slot);
+       kfree(xprt);
+       return ERR_PTR(-EINVAL);
 }
 
+static struct xprt_class       xs_udp_transport = {
+       .list           = LIST_HEAD_INIT(xs_udp_transport.list),
+       .name           = "udp-ipv4",
+       .owner          = THIS_MODULE,
+       .family         = AF_INET,
+       .protocol       = IPPROTO_UDP,
+       .setup          = xs_setup_udp,
+};
+
+static struct xprt_class       xs_tcp_transport = {
+       .list           = LIST_HEAD_INIT(xs_tcp_transport.list),
+       .name           = "tcp-ipv4",
+       .owner          = THIS_MODULE,
+       .family         = AF_INET,
+       .protocol       = IPPROTO_TCP,
+       .setup          = xs_setup_tcp,
+};
+
 /**
- * init_socket_xprt - set up xprtsock's sysctls
+ * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
  */
 int init_socket_xprt(void)
@@ -1639,11 +1669,14 @@ int init_socket_xprt(void)
                sunrpc_table_header = register_sysctl_table(sunrpc_table);
 #endif
 
+       xprt_register_transport(&xs_udp_transport);
+       xprt_register_transport(&xs_tcp_transport);
+
        return 0;
 }
 
 /**
- * cleanup_socket_xprt - remove xprtsock's sysctls
+ * cleanup_socket_xprt - remove xprtsock's sysctls, unregister
  *
  */
 void cleanup_socket_xprt(void)
@@ -1654,4 +1687,7 @@ void cleanup_socket_xprt(void)
                sunrpc_table_header = NULL;
        }
 #endif
+
+       xprt_unregister_transport(&xs_udp_transport);
+       xprt_unregister_transport(&xs_tcp_transport);
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
