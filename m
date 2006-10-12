From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/9] SUNRPC: Move the UDP socket bufsize parameters to
	a private data structure
Date: Thu, 12 Oct 2006 17:15:17 -0400
Message-ID: <20061012211517.8734.37182.stgit@ingres.dsl.sfldmi.ameritech.net>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GY7tp-000854-83
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:29 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GY7tp-0002h1-9x
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 14:15:30 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
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

Move the socket-specific buffer size parameters for UDP sockets to a
private data structure maintained in net/sunrpc/xprtsock.c.

Test plan:
Connectathon with NFS over UDP.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    3 ---
 net/sunrpc/xprtsock.c       |   24 ++++++++++++++++--------
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 18bf72c..21beb56 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -137,9 +137,6 @@ struct rpc_xprt {
 	unsigned long		cong;		/* current congestion */
 	unsigned long		cwnd;		/* congestion window */
 
-	size_t			rcvsize,	/* transport rcv buffer size */
-				sndsize;	/* transport send buffer size */
-
 	size_t			max_payload;	/* largest RPC payload size,
 						   in bytes */
 	unsigned int		tsh_size;	/* size of transport specific
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b0bead5..c0e23e3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -151,6 +151,12 @@ struct xs_xprt {
 	 */
 	struct work_struct	connect_worker;
 	unsigned short		port;
+
+	/*
+	 * UDP socket buffer size parameters
+	 */
+	size_t			rcvsize,
+				sndsize;
 };
 
 /*
@@ -1003,13 +1009,13 @@ static void xs_udp_do_set_buffer_size(st
 	struct xs_xprt *private = xs_private_data(xprt);
 	struct sock *sk = private->inet;
 
-	if (xprt->rcvsize) {
+	if (private->rcvsize) {
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
-		sk->sk_rcvbuf = xprt->rcvsize * xprt->max_reqs *  2;
+		sk->sk_rcvbuf = private->rcvsize * xprt->max_reqs *  2;
 	}
-	if (xprt->sndsize) {
+	if (private->sndsize) {
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
-		sk->sk_sndbuf = xprt->sndsize * xprt->max_reqs * 2;
+		sk->sk_sndbuf = private->sndsize * xprt->max_reqs * 2;
 		sk->sk_write_space(sk);
 	}
 }
@@ -1024,12 +1030,14 @@ static void xs_udp_do_set_buffer_size(st
  */
 static void xs_udp_set_buffer_size(struct rpc_xprt *xprt, size_t sndsize, size_t rcvsize)
 {
-	xprt->sndsize = 0;
+	struct xs_xprt *private = xs_private_data(xprt);
+
+	private->sndsize = 0;
 	if (sndsize)
-		xprt->sndsize = sndsize + 1024;
-	xprt->rcvsize = 0;
+		private->sndsize = sndsize + 1024;
+	private->rcvsize = 0;
 	if (rcvsize)
-		xprt->rcvsize = rcvsize + 1024;
+		private->rcvsize = rcvsize + 1024;
 
 	xs_udp_do_set_buffer_size(xprt);
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
