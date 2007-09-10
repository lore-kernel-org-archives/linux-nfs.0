From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 02/19] SUNRPC: export per-transport rpcbind netid's
Date: Mon, 10 Sep 2007 13:43:05 -0400
Message-ID: <EXNANE01Ex3AkwtsQzt000004b1@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnWc-00030J-Ak
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnWg-0001fr-U5
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:23 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AHwAdu024799
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 10:58:11 -0700 (PDT)
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

SUNRPC: export per-transport rpcbind netid's

The rpcbind (v3+) netid is provided by each RPC client transport. This fixes
an omission in IPv6 rpcbind client support, and enables future extension.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/rpcb_clnt.c      |    3 +--
 net/sunrpc/xprtsock.c       |    8 ++++++++
 3 files changed, 10 insertions(+), 2 deletions(-)

Index: kernel/include/linux/sunrpc/xprt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprt.h
+++ kernel/include/linux/sunrpc/xprt.h
@@ -56,6 +56,7 @@ enum rpc_display_format_t {
 	RPC_DISPLAY_HEX_ADDR,
 	RPC_DISPLAY_HEX_PORT,
 	RPC_DISPLAY_UNIVERSAL_ADDR,
+	RPC_DISPLAY_NETID,
 	RPC_DISPLAY_MAX,
 };
 
Index: kernel/net/sunrpc/xprtsock.c
===================================================================
--- kernel.orig/net/sunrpc/xprtsock.c
+++ kernel/net/sunrpc/xprtsock.c
@@ -337,6 +337,10 @@ static void xs_format_ipv4_peer_addresse
 				ntohs(addr->sin_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
+
+	xprt->address_strings[RPC_DISPLAY_NETID] =
+		kstrdup(xprt->prot == IPPROTO_UDP ?
+			RPCBIND_NETID_UDP : RPCBIND_NETID_TCP, GFP_KERNEL);
 }
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
@@ -398,6 +402,10 @@ static void xs_format_ipv6_peer_addresse
 				ntohs(addr->sin6_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
+
+	xprt->address_strings[RPC_DISPLAY_NETID] =
+		kstrdup(xprt->prot == IPPROTO_UDP ?
+			RPCBIND_NETID_UDP6 : RPCBIND_NETID_TCP6, GFP_KERNEL);
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
Index: kernel/net/sunrpc/rpcb_clnt.c
===================================================================
--- kernel.orig/net/sunrpc/rpcb_clnt.c
+++ kernel/net/sunrpc/rpcb_clnt.c
@@ -388,8 +388,7 @@ void rpcb_getport_async(struct rpc_task 
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCBIND_NETID_TCP :
-						     RPCBIND_NETID_UDP;
+	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
 	memcpy(&map->r_addr,
 	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
 	       sizeof(map->r_addr));

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
