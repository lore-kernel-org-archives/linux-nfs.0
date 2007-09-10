From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 01/19] SUNRPC: move per-transport rpcbind netid's
Date: Mon, 10 Sep 2007 13:42:38 -0400
Message-ID: <EXNANE01wsXZZTHfyQg000004b0@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnWe-00030T-EK
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:20 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnWi-0005rQ-O9
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:25 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AHvYOn024598
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 10:57:34 -0700 (PDT)
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

SUNRPC: move per-transport rpcbind netid's

Move the TCP/UDP rpcbind netid's from the rpcbind client to a global header.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/msg_prot.h |   13 +++++++++++++
 net/sunrpc/rpcb_clnt.c          |   26 +++-----------------------
 2 files changed, 16 insertions(+), 23 deletions(-)

Index: kernel/net/sunrpc/rpcb_clnt.c
===================================================================
--- kernel.orig/net/sunrpc/rpcb_clnt.c
+++ kernel/net/sunrpc/rpcb_clnt.c
@@ -93,26 +93,6 @@ enum {
 #define RPCB_MAXADDRLEN		(128u)
 
 /*
- * r_netid
- *
- * Quoting RFC 3530, section 2.2:
- *
- * For TCP over IPv4 the value of r_netid is the string "tcp".  For UDP
- * over IPv4 the value of r_netid is the string "udp".
- *
- * ...
- *
- * For TCP over IPv6 the value of r_netid is the string "tcp6".  For UDP
- * over IPv6 the value of r_netid is the string "udp6".
- */
-#define RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
-#define RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
-#define RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
-#define RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
-
-#define RPCB_MAXNETIDLEN	(4u)
-
-/*
  * r_owner
  *
  * The "owner" is allowed to unset a service in the rpcbind database.
@@ -408,8 +388,8 @@ void rpcb_getport_async(struct rpc_task 
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
-						   RPCB_NETID_UDP;
+	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCBIND_NETID_TCP :
+						     RPCBIND_NETID_UDP;
 	memcpy(&map->r_addr,
 	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
 	       sizeof(map->r_addr));
@@ -565,7 +545,7 @@ static int rpcb_decode_getaddr(struct rp
 #define RPCB_port_sz		(1u)
 #define RPCB_boolean_sz		(1u)
 
-#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCB_MAXNETIDLEN))
+#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCBIND_MAXNETIDLEN))
 #define RPCB_addr_sz		(1+XDR_QUADLEN(RPCB_MAXADDRLEN))
 #define RPCB_ownerstring_sz	(1+XDR_QUADLEN(RPCB_MAXOWNERLEN))
 
Index: kernel/include/linux/sunrpc/msg_prot.h
===================================================================
--- kernel.orig/include/linux/sunrpc/msg_prot.h
+++ kernel/include/linux/sunrpc/msg_prot.h
@@ -138,6 +138,19 @@ typedef __be32	rpc_fraghdr;
 #define RPC_MAX_HEADER_WITH_AUTH \
 	(RPC_CALLHDRSIZE + 2*(2+RPC_MAX_AUTH_SIZE/4))
 
+/*
+ * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
+ */
+#define RPCBIND_NETID_UDP	"udp"
+#define RPCBIND_NETID_TCP	"tcp"
+#define RPCBIND_NETID_UDP6	"udp6"
+#define RPCBIND_NETID_TCP6	"tcp6"
+
+/*
+ * Note that RFC 1833 does not put any size restrictions on the
+ * netid string, but all currently defined netid's fit in 4 bytes.
+ */
+#define RPCBIND_MAXNETIDLEN	(4u)
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
