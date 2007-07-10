From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 13/20] svc: Add svc_[un]register_transport
Date: Tue, 10 Jul 2007 00:34:47 -0500
Message-ID: <20070710053447.28979.27607.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88N8-00075N-Ml
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:50 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NB-0004vM-2I
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:54 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id A23FF7C79C
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:47 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Add an exported function for transport modules to [un]register themselves
with the sunrpc server side transport switch.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    7 ++++++
 net/sunrpc/svcsock.c           |   50 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 0e7307c..d132dd5 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -13,6 +13,7 @@ #include <linux/sunrpc/svc.h>
 
 struct svc_sock_ops {
 	const char		*sko_name;
+	struct module		*sko_owner;
 	int			(*sko_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sko_sendto)(struct svc_rqst *rqstp);
 	/*
@@ -45,7 +46,11 @@ struct svc_sock_ops {
 	 * Accept a pending connection, for connection-oriented transports
 	 */
 	int			(*sko_accept)(struct svc_sock *svsk);
+
+	/* Transport list link */
+	struct list_head	sko_list;
 };
+extern struct list_head svc_transport_list;
 
 /*
  * RPC server socket.
@@ -102,6 +107,8 @@ #define	SK_LISTENER	11			/* listener (e.
 /*
  * Function prototypes.
  */
+int 		svc_register_transport(struct svc_sock_ops *xprt);
+int 		svc_unregister_transport(struct svc_sock_ops *xprt);
 int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
 void		svc_force_close_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b88e3d2..ec0ad0e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -91,6 +91,54 @@ static struct svc_deferred_req *svc_defe
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 
+/* List of registered transports */
+static spinlock_t svc_transport_lock = SPIN_LOCK_UNLOCKED;
+LIST_HEAD(svc_transport_list);
+
+int svc_register_transport(struct svc_sock_ops *xprt)
+{
+	struct svc_sock_ops *ops;
+	int res;
+
+	dprintk("svc: Adding svc transport '%s'\n",
+		xprt->sko_name);
+	
+	res = -EEXIST;
+	INIT_LIST_HEAD(&xprt->sko_list);
+	spin_lock(&svc_transport_lock);
+	list_for_each_entry(ops, &svc_transport_list, sko_list) {
+		if (xprt == ops)
+			goto out;
+	}
+	list_add_tail(&xprt->sko_list, &svc_transport_list);
+	res = 0;
+out:
+	spin_unlock(&svc_transport_lock);
+	return res;
+}
+EXPORT_SYMBOL(svc_register_transport);
+
+int svc_unregister_transport(struct svc_sock_ops *xprt)
+{
+	struct svc_sock_ops *ops;
+	int res = 0;
+
+	dprintk("svc: Removing svc transport '%s'\n", xprt->sko_name);
+
+	spin_lock(&svc_transport_lock);
+	list_for_each_entry(ops, &svc_transport_list, sko_list) {
+		if (xprt == ops) {
+			list_del_init(&ops->sko_list);
+			goto out;
+		}
+	}
+	res = -ENOENT;
+ out:
+	spin_unlock(&svc_transport_lock);
+	return res;
+}
+EXPORT_SYMBOL(svc_unregister_transport);
+
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
  * 6 minutes
@@ -887,6 +935,7 @@ svc_udp_has_wspace(struct svc_sock *svsk
 
 static const struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
+	.sko_owner = THIS_MODULE,
 	.sko_recvfrom = svc_udp_recvfrom,
 	.sko_sendto = svc_udp_sendto,
 	.sko_detach = svc_tcpip_detach,
@@ -1346,6 +1395,7 @@ svc_tcp_has_wspace(struct svc_sock *svsk
 
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
+	.sko_owner = THIS_MODULE,
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
