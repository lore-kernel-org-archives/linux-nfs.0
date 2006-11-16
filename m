From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/21] SUNRPC: Move TCP state flags into xprtsock.c
Date: Thu, 16 Nov 2006 15:04:07 -0500
Message-ID: <20061116200407.32549.92799.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko14-0006qC-GB
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:22 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko15-0000RO-Cm
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:23 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

Move "XPRT_LAST_FRAG" and friends from xprt.h into xprtsock.c, and rename
them to use the naming scheme in use in xprtsock.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    5 ----
 net/sunrpc/xprtsock.c       |   49 +++++++++++++++++++++++++------------------
 2 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 0a0ad1c..3ff8230 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -203,11 +203,6 @@ struct rpc_xprt {
 	char *			address_strings[RPC_DISPLAY_MAX];
 };
 
-#define XPRT_LAST_FRAG		(1 << 0)
-#define XPRT_COPY_RECM		(1 << 1)
-#define XPRT_COPY_XID		(1 << 2)
-#define XPRT_COPY_DATA		(1 << 3)
-
 #ifdef __KERNEL__
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2cef177..66096a9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -147,6 +147,14 @@ struct sock_xprt {
 				tcp_flags;
 };
 
+/*
+ * TCP receive state flags
+ */
+#define TCP_RCV_LAST_FRAG	(1UL << 0)
+#define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
+#define TCP_RCV_COPY_XID	(1UL << 2)
+#define TCP_RCV_COPY_DATA	(1UL << 3)
+
 static void xs_format_peer_addresses(struct rpc_xprt *xprt)
 {
 	struct sockaddr_in *addr = (struct sockaddr_in *) &xprt->addr;
@@ -663,12 +671,12 @@ static inline void xs_tcp_read_fraghdr(s
 
 	transport->tcp_reclen = ntohl(transport->tcp_fraghdr);
 	if (transport->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
-		transport->tcp_flags |= XPRT_LAST_FRAG;
+		transport->tcp_flags |= TCP_RCV_LAST_FRAG;
 	else
-		transport->tcp_flags &= ~XPRT_LAST_FRAG;
+		transport->tcp_flags &= ~TCP_RCV_LAST_FRAG;
 	transport->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
 
-	transport->tcp_flags &= ~XPRT_COPY_RECM;
+	transport->tcp_flags &= ~TCP_RCV_COPY_FRAGHDR;
 	transport->tcp_offset = 0;
 
 	/* Sanity check of the record length */
@@ -684,11 +692,11 @@ static inline void xs_tcp_read_fraghdr(s
 static void xs_tcp_check_fraghdr(struct sock_xprt *transport)
 {
 	if (transport->tcp_offset == transport->tcp_reclen) {
-		transport->tcp_flags |= XPRT_COPY_RECM;
+		transport->tcp_flags |= TCP_RCV_COPY_FRAGHDR;
 		transport->tcp_offset = 0;
-		if (transport->tcp_flags & XPRT_LAST_FRAG) {
-			transport->tcp_flags &= ~XPRT_COPY_DATA;
-			transport->tcp_flags |= XPRT_COPY_XID;
+		if (transport->tcp_flags & TCP_RCV_LAST_FRAG) {
+			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+			transport->tcp_flags |= TCP_RCV_COPY_XID;
 			transport->tcp_copied = 0;
 		}
 	}
@@ -706,8 +714,8 @@ static inline void xs_tcp_read_xid(struc
 	transport->tcp_offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~XPRT_COPY_XID;
-	transport->tcp_flags |= XPRT_COPY_DATA;
+	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
+	transport->tcp_flags |= TCP_RCV_COPY_DATA;
 	transport->tcp_copied = 4;
 	dprintk("RPC:      reading reply for XID %08x\n",
 			ntohl(transport->tcp_xid));
@@ -726,7 +734,7 @@ static inline void xs_tcp_read_request(s
 	spin_lock(&xprt->transport_lock);
 	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
 	if (!req) {
-		transport->tcp_flags &= ~XPRT_COPY_DATA;
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 		dprintk("RPC:      XID %08x request not found!\n",
 				ntohl(transport->tcp_xid));
 		spin_unlock(&xprt->transport_lock);
@@ -757,13 +765,13 @@ static inline void xs_tcp_read_request(s
 		/* Error when copying to the receive buffer,
 		 * usually because we weren't able to allocate
 		 * additional buffer pages. All we can do now
-		 * is turn off XPRT_COPY_DATA, so the request
+		 * is turn off TCP_RCV_COPY_DATA, so the request
 		 * will not receive any additional updates,
 		 * and time out.
 		 * Any remaining data from this record will
 		 * be discarded.
 		 */
-		transport->tcp_flags &= ~XPRT_COPY_DATA;
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 		dprintk("RPC:      XID %08x truncated request\n",
 				ntohl(transport->tcp_xid));
 		dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
@@ -779,14 +787,14 @@ static inline void xs_tcp_read_request(s
 				transport->tcp_reclen);
 
 	if (transport->tcp_copied == req->rq_private_buf.buflen)
-		transport->tcp_flags &= ~XPRT_COPY_DATA;
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 	else if (transport->tcp_offset == transport->tcp_reclen) {
-		if (transport->tcp_flags & XPRT_LAST_FRAG)
-			transport->tcp_flags &= ~XPRT_COPY_DATA;
+		if (transport->tcp_flags & TCP_RCV_LAST_FRAG)
+			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 	}
 
 out:
-	if (!(transport->tcp_flags & XPRT_COPY_DATA))
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
 	spin_unlock(&xprt->transport_lock);
 	xs_tcp_check_fraghdr(transport);
@@ -820,17 +828,17 @@ static int xs_tcp_data_recv(read_descrip
 	do {
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
-		if (transport->tcp_flags & XPRT_COPY_RECM) {
+		if (transport->tcp_flags & TCP_RCV_COPY_FRAGHDR) {
 			xs_tcp_read_fraghdr(xprt, &desc);
 			continue;
 		}
 		/* Read in the xid if necessary */
-		if (transport->tcp_flags & XPRT_COPY_XID) {
+		if (transport->tcp_flags & TCP_RCV_COPY_XID) {
 			xs_tcp_read_xid(transport, &desc);
 			continue;
 		}
 		/* Read in the request data */
-		if (transport->tcp_flags & XPRT_COPY_DATA) {
+		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
 			xs_tcp_read_request(xprt, &desc);
 			continue;
 		}
@@ -896,7 +904,8 @@ static void xs_tcp_state_change(struct s
 			transport->tcp_offset = 0;
 			transport->tcp_reclen = 0;
 			transport->tcp_copied = 0;
-			transport->tcp_flags = XPRT_COPY_RECM | XPRT_COPY_XID;
+			transport->tcp_flags =
+				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 			xprt_wake_pending_tasks(xprt, 0);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
