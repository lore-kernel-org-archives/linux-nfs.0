From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 09:35:19 -0400
Message-ID: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR6gS-0003Ly-4T
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:37:12 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IR6gT-0001tD-HG
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 06:37:16 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l7VDZNh3015862
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 06:35:23 -0700 (PDT)
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

The following patch moves rpcbind v3 "netid" selection from the
rpbcind client to the originating transport, where I believe it belongs.
This also enables IPv6 rpcbind transport resolution by the client.

Patch base is 2.6.23-rc4 + Trond NFS_ALL.

Comments?

Tom.

-----

SUNRPC: export per-transport netid's

The rpcbind (v3+) netid is provided by each RPC client transport.
This enables IPv6 rpcbind client support, and future extension.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/clnt.h |    8 ++++++++
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/rpcb_clnt.c      |   24 +++++++++---------------
 net/sunrpc/xprtsock.c       |   10 ++++++++++
 4 files changed, 28 insertions(+), 15 deletions(-)

Index: linux-2.6.22/include/linux/sunrpc/xprt.h
===================================================================
--- linux-2.6.22.orig/include/linux/sunrpc/xprt.h
+++ linux-2.6.22/include/linux/sunrpc/xprt.h
@@ -56,6 +56,7 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_HEX_ADDR,
 	RPC_DISPLAY_HEX_PORT,
 	RPC_DISPLAY_UNIVERSAL_ADDR,
+	RPC_DISPLAY_NETID,
 	RPC_DISPLAY_MAX,
 };
 
Index: linux-2.6.22/net/sunrpc/xprtsock.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprtsock.c
+++ linux-2.6.22/net/sunrpc/xprtsock.c
@@ -337,6 +337,11 @@ static void xs_format_ipv4_peer_addresse
 				ntohs(addr->sin_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
+
+	if (xprt->prot == IPPROTO_UDP)
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCB_NETID_UDP;
+	else
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCB_NETID_TCP;
 }
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
@@ -398,6 +403,11 @@ static void xs_format_ipv6_peer_addresse
 				ntohs(addr->sin6_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
+
+	if (xprt->prot == IPPROTO_UDP)
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCB_NETID_UDP6;
+	else
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCB_NETID_TCP6;
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
Index: linux-2.6.22/net/sunrpc/rpcb_clnt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/rpcb_clnt.c
+++ linux-2.6.22/net/sunrpc/rpcb_clnt.c
@@ -95,20 +95,9 @@ enum {
 /*
  * r_netid
  *
- * Quoting RFC 3530, section 2.2:
- *
- * For TCP over IPv4 the value of r_netid is the string "tcp".  For UDP
- * over IPv4 the value of r_netid is the string "udp".
- *
- * ...
- *
- * For TCP over IPv6 the value of r_netid is the string "tcp6".  For UDP
- * over IPv6 the value of r_netid is the string "udp6".
+ * Note that RFC 1833 does not put any size restrictions on the
+ * netid string, but all currently defined netid's fit in 4 bytes.
  */
-#define RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
-#define RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
-#define RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
-#define RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
 
 #define RPCB_MAXNETIDLEN	(4u)
 
@@ -408,8 +397,13 @@ void rpcb_getport_async(struct rpc_task 
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
-						   RPCB_NETID_UDP;
+	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+	if (strlen(map->r_netid) > RPCB_MAXNETIDLEN) {
+		status = -ENAMETOOLONG;
+		dprintk("RPC: %5u %s: netid %s too long (%d)\n",
+			task->tk_pid, __FUNCTION__, map->r_netid, RPCB_MAXNETIDLEN);
+		goto bailout;
+	}
 	memcpy(&map->r_addr,
 	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
 	       sizeof(map->r_addr));
Index: linux-2.6.22/include/linux/sunrpc/clnt.h
===================================================================
--- linux-2.6.22.orig/include/linux/sunrpc/clnt.h
+++ linux-2.6.22/include/linux/sunrpc/clnt.h
@@ -92,6 +92,14 @@ struct rpc_procinfo {
 	char *			p_name;		/* name of procedure */
 };
 
+/*
+ * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
+ */
+#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
+#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
+#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
+#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
+
 #ifdef __KERNEL__
 
 struct rpc_create_args {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
