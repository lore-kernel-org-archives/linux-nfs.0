From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Fri, 14 May 2004 12:23:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40A42DB8.7B9C8152@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOSMs-0001nn-B8
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 19:24:10 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOSMr-0004WQ-Rp
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 19:24:09 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

G'day,

This patch attempts to implement a suggestion made by Neil Brown in
offline discussions, to extend the Linux NFS server to use multiple
UDP sockets for load sharing.  It turns out that the single UDP socket
is a throughput limiter at surprisingly small loads.  With this patch
my test machine goes from being limited at about 146 MB/s in cached
read loads over UDP to about 210~230 MB/s, which is about the same
number as the same test over TCP.

The good thing about this patch is that it uses a couple of handy
network stack features to create multiple UDP sockets automatically
and almost completely transparently to userspace.  None of userspace
nfs-utils, the portmapper, client mount, or kernel network stack
need any modifications to work.  The patch creates one UDP socket per
network interface, bound to that network interface;  all sockets have
the same port.

With the patch, userspace sees

# ifconfig 
eth0      Link encap:Ethernet  [...]  # used for management only
eth1      Link encap:Ethernet  [...]
eth2      Link encap:Ethernet  [...]
eth3      Link encap:Ethernet  [...]
lo        Link encap:Local Loopback  [...]

# netstat -anu
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
[...]
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
[...]


# rpcinfo -p
   program vers proto   port
[...]
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
[...]


The downside with multiple sockets (both variants that I've tried)
is that while the server supports greater loads, some combinations of
irq-to-cpu mappings and loads have resulted in dramatically unbalanced
service compared to a single-socket server.  For example, a single
socket server will spread 146 MB/s among three NICs as about 48
MB/s per NIC but the worst case test showed a multiple socket server
spreading a larger load as 90.6, 7.3, 107.0 MB/s.  Other tests show
less dramatic imbalances such as 43.6, 72.5, and 97.5 MB/s, and yet
others show balanced loads.

I'm not sure if this is an Altix platform issue or a problem in the
network stack, so I'm pushing this patch out for comments and testing.

Another unknown is the behaviour in the presence of virtual interfaces
(tunnels, bonding etc).

Anyway, here it is:

Index: linux/fs/nfsd/nfssvc.c
===================================================================
--- linux.orig/fs/nfsd/nfssvc.c	Wed May 12 16:27:02 2004
+++ linux/fs/nfsd/nfssvc.c	Fri May 14 11:18:44 2004
@@ -31,6 +31,8 @@
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
 #include <linux/lockd/bind.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
@@ -52,6 +54,8 @@
 static void			nfsd(struct svc_rqst *rqstp);
 struct timeval			nfssvc_boot;
 static struct svc_serv 		*nfsd_serv;
+static unsigned short		nfsd_port;
+static int			nfsd_num_udp_socks;
 static atomic_t			nfsd_busy;
 static unsigned long		nfsd_last_call;
 static spinlock_t		nfsd_call_lock = SPIN_LOCK_UNLOCKED;
@@ -75,6 +79,44 @@
 		return nfsd_serv->sv_nrthreads;
 }
 
+static int
+nfsd_netdev_notifier(struct notifier_block *self, unsigned long code, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	int err;
+
+	switch (code)
+	{
+	case NETDEV_UP: 	/* device coming up */
+		dprintk("nfsd: interface %s coming up, creating socket\n",
+			dev->name);
+		lock_kernel();
+		err = svc_makesock_dev(nfsd_serv, IPPROTO_UDP, nfsd_port,
+				       dev->ifindex);
+		if (err < 0)
+			printk(KERN_ERR "nfsd: failed to create socket for interface %s\n",
+				dev->name);
+		else
+			nfsd_num_udp_socks++;
+		unlock_kernel();
+		break;
+	
+	case NETDEV_GOING_DOWN: /* device going down */
+		dprintk("nfsd: interface %s going down, removing socket\n",
+			dev->name);
+		lock_kernel();
+		if (svc_delete_socket_dev(nfsd_serv, dev->ifindex) >= 0)
+			nfsd_num_udp_socks--;
+		unlock_kernel();
+		break;
+	}
+	return 0;
+}
+
+static struct notifier_block nfsd_netdev_nb = {
+	.notifier_call = nfsd_netdev_notifier
+};
+
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
@@ -101,9 +143,24 @@
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
 		if (nfsd_serv == NULL)
 			goto out;
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-		if (error < 0)
-			goto failure;
+
+		/*
+		 * Register a notifier to be called when net device
+		 * state changes; as a side effect the callback is
+		 * immediately called for all current devices.
+		 */
+		nfsd_num_udp_socks = 0;
+		nfsd_port = port;
+		register_netdevice_notifier(&nfsd_netdev_nb);
+		if (nfsd_num_udp_socks == 0) {
+			/* a socket is bound to the port, or no up devices */
+			unregister_netdevice_notifier(&nfsd_netdev_nb);
+
+			dprintk("nfsd: falling back to global socket\n");
+			error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
+			if (error < 0)
+				goto failure;
+		}
 
 #ifdef CONFIG_NFSD_TCP
 		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
@@ -267,6 +324,7 @@
 	if (serv->sv_nrthreads==1) {
 		
 		printk(KERN_WARNING "nfsd: last server has exited\n");
+		unregister_netdevice_notifier(&nfsd_netdev_nb);
 		if (err != SIG_NOCLEAN) {
 			printk(KERN_WARNING "nfsd: unexporting all filesystems\n");
 			nfsd_export_flush();
Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	Wed May 12 16:27:02 2004
+++ linux/include/linux/sunrpc/svcsock.h	Wed May 12 16:46:43 2004
@@ -56,7 +56,10 @@
  * Function prototypes.
  */
 int		svc_makesock(struct svc_serv *, int, unsigned short);
+int		svc_makesock_dev(struct svc_serv *, int, unsigned short,
+				 int bind_dev);
 void		svc_delete_socket(struct svc_sock *);
+int		svc_delete_socket_dev(struct svc_serv *serv, int bind_dev);
 int		svc_recv(struct svc_serv *, struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	Wed May 12 16:27:02 2004
+++ linux/net/sunrpc/svcsock.c	Fri May 14 11:14:08 2004
@@ -1460,7 +1460,7 @@
 		svc_tcp_init(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!pmap_register) {
+	if (!pmap_register && sock->type == SOCK_STREAM) {
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
@@ -1482,17 +1482,18 @@
  * Create socket for RPC service.
  */
 static int
-svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin)
+svc_create_socket(struct svc_serv *serv, int protocol, struct sockaddr_in *sin,
+		  int bind_dev)
 {
 	struct svc_sock	*svsk;
 	struct socket	*sock;
 	int		error;
 	int		type;
 
-	dprintk("svc: svc_create_socket(%s, %d, %u.%u.%u.%u:%d)\n",
+	dprintk("svc: svc_create_socket(%s, %d, %u.%u.%u.%u:%d, %d)\n",
 				serv->sv_program->pg_name, protocol,
 				NIPQUAD(sin->sin_addr.s_addr),
-				ntohs(sin->sin_port));
+				ntohs(sin->sin_port), bind_dev);
 
 	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "
@@ -1507,11 +1508,14 @@
 	if (sin != NULL) {
 		if (type == SOCK_STREAM)
 			sock->sk->sk_reuse = 1; /* allow address reuse */
+		if (bind_dev)
+			sock->sk->sk_bound_dev_if = bind_dev;
 		error = sock->ops->bind(sock, (struct sockaddr *) sin,
 						sizeof(*sin));
 		if (error < 0)
 			goto bummer;
 	}
+	
 
 	if (protocol == IPPROTO_TCP) {
 		if ((error = sock->ops->listen(sock, 64)) < 0)
@@ -1528,15 +1532,15 @@
 }
 
 /*
- * Remove a dead socket
+ * Common code to remove a dead socket.  Should be called with
+ * the svc_serv's spinlock held.
  */
-void
-svc_delete_socket(struct svc_sock *svsk)
+static void
+__svc_delete_socket(struct svc_sock *svsk)
 {
 	struct svc_serv	*serv;
 	struct sock	*sk;
 
-	dprintk("svc: svc_delete_socket(%p)\n", svsk);
 
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
@@ -1545,8 +1549,6 @@
 	sk->sk_data_ready = svsk->sk_odata;
 	sk->sk_write_space = svsk->sk_owspace;
 
-	spin_lock_bh(&serv->sv_lock);
-
 	list_del_init(&svsk->sk_list);
 	list_del_init(&svsk->sk_ready);
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags))
@@ -1554,21 +1556,61 @@
 			serv->sv_tmpcnt--;
 
 	if (!svsk->sk_inuse) {
-		spin_unlock_bh(&serv->sv_lock);
 		sock_release(svsk->sk_sock);
 		kfree(svsk);
 	} else {
-		spin_unlock_bh(&serv->sv_lock);
 		dprintk(KERN_NOTICE "svc: server socket destroy delayed\n");
 		/* svsk->sk_server = NULL; */
 	}
 }
 
 /*
+ * Remove a dead socket
+ */
+void
+svc_delete_socket(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_server;
+
+	dprintk("svc: svc_delete_socket(%p)\n", svsk);
+
+	spin_lock_bh(&serv->sv_lock);
+	__svc_delete_socket(svsk);
+	spin_unlock_bh(&serv->sv_lock);
+}
+
+/*
+ * Remove any socket attached to the service which is bound to
+ * the given interface index.  Used when an interface goes down.
+ * Returns 0 if successful or a negative error code.
+ */
+int
+svc_delete_socket_dev(struct svc_serv *serv, int bind_dev)
+{
+	struct list_head *p;
+	int ret = -ENODEV;
+
+	dprintk("svc: svc_delete_socket_dev(%p, %d)\n", serv, bind_dev);
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each(p, &serv->sv_permsocks) {
+		struct svc_sock *svsk = list_entry(p, struct svc_sock, sk_list);
+		if (svsk->sk_sk->sk_bound_dev_if == bind_dev) {
+			__svc_delete_socket(svsk);
+			ret = 0;
+			break;
+		}
+	}
+	spin_unlock_bh(&serv->sv_lock);
+	return ret;
+}
+
+/*
  * Make a socket for nfsd and lockd
  */
 int
-svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
+svc_makesock_dev(struct svc_serv *serv, int protocol, unsigned short port,
+		 int bind_dev)
 {
 	struct sockaddr_in	sin;
 
@@ -1576,7 +1618,13 @@
 	sin.sin_family      = AF_INET;
 	sin.sin_addr.s_addr = INADDR_ANY;
 	sin.sin_port        = htons(port);
-	return svc_create_socket(serv, protocol, &sin);
+	return svc_create_socket(serv, protocol, &sin, bind_dev);
+}
+
+int
+svc_makesock(struct svc_serv *serv, int protocol, unsigned short port)
+{
+	return svc_makesock_dev(serv, protocol, port, 0);
 }
 
 /*





Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
