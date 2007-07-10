From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 14/20] svc: Register TCP/UDP Transports
Date: Tue, 10 Jul 2007 00:34:49 -0500
Message-ID: <20070710053449.28979.20825.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88NA-00075c-23
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:52 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88ND-0003Vg-CH
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:55 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id B769D7C7BD
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:49 -0500 (CDT)
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


Add a call to svc_register_transport for the built
in transports UDP and TCP. The registration is done in the 
sunrpc module initialization logic.
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/sunrpc_syms.c |    2 ++
 net/sunrpc/svcsock.c     |   10 ++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 73075de..c68577b 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -134,6 +134,7 @@ EXPORT_SYMBOL(nfsd_debug);
 EXPORT_SYMBOL(nlm_debug);
 #endif
 
+extern void init_svc_xprt(void);
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
 static int __init
@@ -156,6 +157,7 @@ #endif
 	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
 	init_socket_xprt();
+	init_svc_xprt();
 out:
 	return err;
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ec0ad0e..2583623 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -933,7 +933,7 @@ svc_udp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sock_wspace(svsk->sk_sk));
 }
 
-static const struct svc_sock_ops svc_udp_ops = {
+static struct svc_sock_ops svc_udp_ops = {
 	.sko_name = "udp",
 	.sko_owner = THIS_MODULE,
 	.sko_recvfrom = svc_udp_recvfrom,
@@ -1393,7 +1393,7 @@ svc_tcp_has_wspace(struct svc_sock *svsk
 	return svc_sock_has_write_space(svsk, sk_stream_wspace(svsk->sk_sk));
 }
 
-static const struct svc_sock_ops svc_tcp_ops = {
+static struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_owner = THIS_MODULE,
 	.sko_recvfrom = svc_tcp_recvfrom,
@@ -1406,6 +1406,12 @@ static const struct svc_sock_ops svc_tcp
 	.sko_accept = svc_tcp_accept
 };
 
+void init_svc_xprt(void) 
+{
+	svc_register_transport(&svc_udp_ops);
+	svc_register_transport(&svc_tcp_ops);
+}
+	
 static void
 svc_tcp_init_listener(struct svc_sock *svsk)
 {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
