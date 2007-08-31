From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC#2 PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 13:37:45 -0400
Message-ID: <EXNANE01AkK5LqN33HF00000246@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRASI-0005gk-L0
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 10:39:09 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IRASM-0005TX-So
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 10:38:55 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l7VHcnN8001292
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 10:38:49 -0700 (PDT)
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

Version 2. Note I renamed/moved the RPCB_MAXADDRLEN constant,
and added a length check on the passed-in value for it and the netid.

Also note, there is a possible issue in the copy used as the source of the
r_addr. The existing code uses the newly-created rpcb_clnt, not the one
passed in by the caller. Chuck and I are looking into that (it appears to be
harmless as long as IPv4 is used).

Netid's are now defined as normal (non-octal) strings, per Trond.

Comments...

Tom.

-----

SUNRPC: export per-transport netid's

The rpcbind (v3+) netid is provided by each RPC client transport. This fixes
an omission in IPv6 rpcbind client support, and enables future extension.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/msg_prot.h |   14 +++++++++++
 include/linux/sunrpc/xprt.h     |    1 
 net/sunrpc/rpcb_clnt.c          |   49 +++++++++++++---------------------------
 net/sunrpc/xprtsock.c           |   10 ++++++++
 4 files changed, 42 insertions(+), 32 deletions(-)

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
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_UDP;
+	else
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_TCP;
 }
 
 static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt)
@@ -398,6 +403,11 @@ static void xs_format_ipv6_peer_addresse
 				ntohs(addr->sin6_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
+
+	if (xprt->prot == IPPROTO_UDP)
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_UDP6;
+	else
+		xprt->address_strings[RPC_DISPLAY_NETID] = RPCBIND_NETID_TCP6;
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
Index: linux-2.6.22/net/sunrpc/rpcb_clnt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/rpcb_clnt.c
+++ linux-2.6.22/net/sunrpc/rpcb_clnt.c
@@ -90,27 +90,6 @@ enum {
  * XXX: Currently this implementation does not explicitly convert the
  *      stored address to US-ASCII on non-ASCII systems.
  */
-#define RPCB_MAXADDRLEN		(128u)
-
-/*
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
 
 /*
  * r_owner
@@ -132,7 +111,7 @@ struct rpcbind_args {
 	u32			r_prot;
 	unsigned short		r_port;
 	char *			r_netid;
-	char			r_addr[RPCB_MAXADDRLEN];
+	char			r_addr[RPCBIND_MAXADDRLEN];
 	char *			r_owner;
 };
 
@@ -332,6 +311,7 @@ void rpcb_getport_async(struct rpc_task 
 	struct sockaddr addr;
 	int status;
 	struct rpcb_info *info;
+	char *r_addr;
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __FUNCTION__,
@@ -408,11 +388,16 @@ void rpcb_getport_async(struct rpc_task 
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
-						   RPCB_NETID_UDP;
-	memcpy(&map->r_addr,
-	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
-	       sizeof(map->r_addr));
+	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+	r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
+	if (strlen(map->r_netid) > RPCBIND_MAXNETIDLEN || strlen(r_addr) > RPCBIND_MAXADDRLEN) {
+		status = -ENAMETOOLONG;
+		dprintk("RPC: %5u %s: netid %s / addr %s too long (%u / %u)\n",
+			task->tk_pid, __FUNCTION__, map->r_netid, r_addr,
+			RPCBIND_MAXNETIDLEN, RPCBIND_MAXADDRLEN);
+		goto bailout;
+	}
+	strcpy(map->r_addr, r_addr);
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
 	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
@@ -505,8 +490,8 @@ static int rpcb_decode_set(struct rpc_rq
 static int rpcb_encode_getaddr(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
-	dprintk("RPC:       rpcb_encode_getaddr(%u, %u, %s)\n",
-			rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
+	dprintk("RPC:       rpcb_encode_getaddr(%u, %u, %s %s)\n",
+		rpcb->r_prog, rpcb->r_vers, rpcb->r_netid, rpcb->r_addr);
 	*p++ = htonl(rpcb->r_prog);
 	*p++ = htonl(rpcb->r_vers);
 
@@ -528,7 +513,7 @@ static int rpcb_decode_getaddr(struct rp
 
 	*portp = 0;
 	addr_len = ntohl(*p++);
-	if (addr_len > RPCB_MAXADDRLEN)			/* sanity */
+	if (addr_len > RPCBIND_MAXADDRLEN)			/* sanity */
 		return -EINVAL;
 
 	dprintk("RPC:       rpcb_decode_getaddr returned string: '%s'\n",
@@ -565,8 +550,8 @@ static int rpcb_decode_getaddr(struct rp
 #define RPCB_port_sz		(1u)
 #define RPCB_boolean_sz		(1u)
 
-#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCB_MAXNETIDLEN))
-#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCB_MAXADDRLEN))
+#define RPCB_netid_sz		(1+XDR_QUADLEN(RPCBIND_MAXNETIDLEN))
+#define RPCB_addr_sz		(1+XDR_QUADLEN(RPCBIND_MAXADDRLEN))
 #define RPCB_ownerstring_sz	(1+XDR_QUADLEN(RPCB_MAXOWNERLEN))
 
 #define RPCB_mappingargs_sz	RPCB_program_sz+RPCB_version_sz+	\
Index: linux-2.6.22/include/linux/sunrpc/msg_prot.h
===================================================================
--- linux-2.6.22.orig/include/linux/sunrpc/msg_prot.h
+++ linux-2.6.22/include/linux/sunrpc/msg_prot.h
@@ -138,6 +138,20 @@ typedef __be32	rpc_fraghdr;
 #define RPC_MAX_HEADER_WITH_AUTH \
 	(RPC_CALLHDRSIZE + 2*(2+RPC_MAX_AUTH_SIZE/4))
 
+/*
+ * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
+ */
+#define	RPCBIND_NETID_UDP	"udp"
+#define	RPCBIND_NETID_TCP	"tcp"
+#define	RPCBIND_NETID_UDP6	"udp6"
+#define	RPCBIND_NETID_TCP6	"tcp6"
+
+/*
+ * Note that RFC 1833 does not put any size restrictions on the
+ * netid string, but all currently defined netid's fit in 4 bytes.
+ */
+#define RPCBIND_MAXNETIDLEN	(4u)
+#define RPCBIND_MAXADDRLEN	(128u)
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
