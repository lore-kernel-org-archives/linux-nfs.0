From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] SUNRPC: Store formatted addresses in private
	data structure
Date: Tue, 17 Oct 2006 14:44:44 -0400
Message-ID: <20061017184444.25704.9479.stgit@schiele.dsl.sfldmi.ameritech.net>
References: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZtvz-0000MI-2F
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:45:03 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZtvv-0006Gh-OA
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:45:04 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hide buffers that store formatted IP addresses in a private data structure
maintained in net/sunrpc/xprtsock.c.

Test plan:
Enable RPCDBG_TRANS and run some typical workloads.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    2 --
 net/sunrpc/xprtsock.c       |   27 +++++++++++++++++----------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 17f3227..37a42c8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -188,8 +188,6 @@ struct rpc_xprt {
 		unsigned long long	req_u,		/* average requests on the wire */
 					bklog_u;	/* backlog queue utilization */
 	} stat;
-
-	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
 #ifdef __KERNEL__
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5eeccc4..de15e42 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -164,6 +164,8 @@ struct xs_xprt {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
+
+	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
 /*
@@ -187,6 +189,7 @@ static inline struct rpc_xprt *xprt_from
 static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
+	struct xs_xprt *private = xs_private_data(xprt);
 	char *buf;
 
 	buf = kzalloc(20, GFP_KERNEL);
@@ -194,19 +197,19 @@ static void xs_format_peer_addresses(str
 		snprintf(buf, 20, "%u.%u.%u.%u",
 				NIPQUAD(addr->sin_addr.s_addr));
 	}
-	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
+	private->address_strings[RPC_DISPLAY_ADDR] = buf;
 
 	buf = kzalloc(8, GFP_KERNEL);
 	if (buf) {
 		snprintf(buf, 8, "%u",
 				ntohs(addr->sin_port));
 	}
-	xprt->address_strings[RPC_DISPLAY_PORT] = buf;
+	private->address_strings[RPC_DISPLAY_PORT] = buf;
 
 	if (xprt->prot == IPPROTO_UDP)
-		xprt->address_strings[RPC_DISPLAY_PROTO] = "udp";
+		private->address_strings[RPC_DISPLAY_PROTO] = "udp";
 	else
-		xprt->address_strings[RPC_DISPLAY_PROTO] = "tcp";
+		private->address_strings[RPC_DISPLAY_PROTO] = "tcp";
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf) {
@@ -215,14 +218,16 @@ static void xs_format_peer_addresses(str
 			ntohs(addr->sin_port),
 			xprt->prot == IPPROTO_UDP ? "udp" : "tcp");
 	}
-	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
+	private->address_strings[RPC_DISPLAY_ALL] = buf;
 }
 
 static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 {
-	kfree(xprt->address_strings[RPC_DISPLAY_ADDR]);
-	kfree(xprt->address_strings[RPC_DISPLAY_PORT]);
-	kfree(xprt->address_strings[RPC_DISPLAY_ALL]);
+	struct xs_xprt *private = xs_private_data(xprt);
+
+	kfree(private->address_strings[RPC_DISPLAY_ADDR]);
+	kfree(private->address_strings[RPC_DISPLAY_PORT]);
+	kfree(private->address_strings[RPC_DISPLAY_ALL]);
 }
 
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
@@ -1074,8 +1079,10 @@ static unsigned short xs_get_random_port
  */
 static char *xs_print_peer_address(struct rpc_xprt *xprt, enum rpc_display_format_t format)
 {
-	if (xprt->address_strings[format] != NULL)
-		return xprt->address_strings[format];
+	struct xs_xprt *private = xs_private_data(xprt);
+
+	if (private->address_strings[format] != NULL)
+		return private->address_strings[format];
 	else
 		return "unprintable";
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
