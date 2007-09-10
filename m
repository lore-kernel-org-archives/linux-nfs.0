From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 10/19] SUNRPC: rename the rpc_xprtsock_create structure
Date: Mon, 10 Sep 2007 13:47:07 -0400
Message-ID: <EXNANE01Pf3L9BGTuAy000004b9@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnaS-0003Rr-Kv
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:02:16 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnaX-0003CS-61
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:02:21 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI2BlM021333
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:02:11 -0700 (PDT)
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

SUNRPC: rename the rpc_xprtsock_create structure

To prepare for including non-sockets-based RPC transports, change the
overly suggestive name of the transport creation arguments struct.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/xprt.h |   10 +++++-----
 net/sunrpc/clnt.c           |    2 +-
 net/sunrpc/xprt.c           |    2 +-
 net/sunrpc/xprtsock.c       |    6 +++---
 4 files changed, 10 insertions(+), 10 deletions(-)

Index: kernel/include/linux/sunrpc/xprt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprt.h
+++ kernel/include/linux/sunrpc/xprt.h
@@ -200,7 +200,7 @@ struct rpc_xprt {
 	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
-struct rpc_xprtsock_create {
+struct xprt_create {
 	int			proto;		/* IPPROTO_UDP or IPPROTO_TCP */
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
@@ -212,7 +212,7 @@ struct xprt_class {
 	struct list_head	list;
 	unsigned short		family;
 	int			protocol;
-	struct rpc_xprt *	(*setup)(struct rpc_xprtsock_create *);
+	struct rpc_xprt *	(*setup)(struct xprt_create *);
 	struct module		*owner;
 	char			name[32];
 };
@@ -225,7 +225,7 @@ void			xprt_set_timeout(struct rpc_timeo
 /*
  * Generic internal transport functions
  */
-struct rpc_xprt *	xprt_create_transport(struct rpc_xprtsock_create *args);
+struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
 void			xprt_connect(struct rpc_task *task);
 void			xprt_reserve(struct rpc_task *task);
 int			xprt_reserve_xprt(struct rpc_task *task);
@@ -265,8 +265,8 @@ void			xprt_disconnect(struct rpc_xprt *
 /*
  * Socket transport setup operations
  */
-struct rpc_xprt *	xs_setup_udp(struct rpc_xprtsock_create *args);
-struct rpc_xprt *	xs_setup_tcp(struct rpc_xprtsock_create *args);
+struct rpc_xprt		*xs_setup_udp(struct xprt_create *args);
+struct rpc_xprt		*xs_setup_tcp(struct xprt_create *args);
 int			init_socket_xprt(void);
 void			cleanup_socket_xprt(void);
 
Index: kernel/net/sunrpc/clnt.c
===================================================================
--- kernel.orig/net/sunrpc/clnt.c
+++ kernel/net/sunrpc/clnt.c
@@ -234,7 +234,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
 {
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
-	struct rpc_xprtsock_create xprtargs = {
+	struct xprt_create xprtargs = {
 		.proto = args->protocol,
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
Index: kernel/net/sunrpc/xprt.c
===================================================================
--- kernel.orig/net/sunrpc/xprt.c
+++ kernel/net/sunrpc/xprt.c
@@ -979,7 +979,7 @@ void xprt_set_timeout(struct rpc_timeout
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xprt_create_transport(struct rpc_xprtsock_create *args)
+struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
Index: kernel/net/sunrpc/xprtsock.c
===================================================================
--- kernel.orig/net/sunrpc/xprtsock.c
+++ kernel/net/sunrpc/xprtsock.c
@@ -1784,7 +1784,7 @@ static struct rpc_xprt_ops xs_tcp_ops = 
 	.print_stats		= xs_tcp_print_stats,
 };
 
-static struct rpc_xprt *xs_setup_xprt(struct rpc_xprtsock_create *args,
+static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
 {
 	struct rpc_xprt *xprt;
@@ -1826,7 +1826,7 @@ static struct rpc_xprt *xs_setup_xprt(st
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_udp(struct rpc_xprtsock_create *args)
+struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;
@@ -1892,7 +1892,7 @@ struct rpc_xprt *xs_setup_udp(struct rpc
  * @args: rpc transport creation arguments
  *
  */
-struct rpc_xprt *xs_setup_tcp(struct rpc_xprtsock_create *args)
+struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 {
 	struct sockaddr *addr = args->dstaddr;
 	struct rpc_xprt *xprt;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
