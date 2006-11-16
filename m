From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/21] SUNRPC: Move TCP receive state variables into
	private data structure
Date: Thu, 16 Nov 2006 15:04:03 -0500
Message-ID: <20061116200402.32549.1746.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko10-0006q3-Hi
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:18 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko11-0000Qj-4n
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:19 -0800
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

Move the TCP receive state variables from the generic rpc_xprt structure to
a private structure maintained inside net/sunrpc/xprtsock.c.

Also rename a function/variable pair to refer to RPC fragment headers
instead of record markers, to be consistent with types defined in
sunrpc/*.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    9 ---
 net/sunrpc/xprtsock.c       |  154 ++++++++++++++++++++++++-------------------
 2 files changed, 86 insertions(+), 77 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 4c074a7..0a0ad1c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -158,15 +158,6 @@ struct rpc_xprt {
 				resvport   : 1; /* use a reserved port */
 
 	/*
-	 * State of TCP reply receive stuff
-	 */
-	__be32			tcp_recm,	/* Fragment header */
-				tcp_xid;	/* Current XID */
-	u32			tcp_reclen,	/* fragment length */
-				tcp_offset;	/* fragment offset */
-	unsigned long		tcp_copied,	/* copied to request */
-				tcp_flags;
-	/*
 	 * Connection of transports
 	 */
 	unsigned long		connect_timeout,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0497399..2cef177 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -133,6 +133,18 @@ struct sock_xprt {
 	 */
 	struct socket *		sock;
 	struct sock *		inet;
+
+	/*
+	 * State of TCP reply receive
+	 */
+	__be32			tcp_fraghdr,
+				tcp_xid;
+
+	u32			tcp_offset,
+				tcp_reclen;
+
+	unsigned long		tcp_copied,
+				tcp_flags;
 };
 
 static void xs_format_peer_addresses(struct rpc_xprt *xprt)
@@ -638,73 +650,73 @@ static inline size_t xs_tcp_copy_data(sk
 
 static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, skb_reader_t *desc)
 {
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	size_t len, used;
 	char *p;
 
-	p = ((char *) &xprt->tcp_recm) + xprt->tcp_offset;
-	len = sizeof(xprt->tcp_recm) - xprt->tcp_offset;
+	p = ((char *) &transport->tcp_fraghdr) + transport->tcp_offset;
+	len = sizeof(transport->tcp_fraghdr) - transport->tcp_offset;
 	used = xs_tcp_copy_data(desc, p, len);
-	xprt->tcp_offset += used;
+	transport->tcp_offset += used;
 	if (used != len)
 		return;
 
-	xprt->tcp_reclen = ntohl(xprt->tcp_recm);
-	if (xprt->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
-		xprt->tcp_flags |= XPRT_LAST_FRAG;
+	transport->tcp_reclen = ntohl(transport->tcp_fraghdr);
+	if (transport->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
+		transport->tcp_flags |= XPRT_LAST_FRAG;
 	else
-		xprt->tcp_flags &= ~XPRT_LAST_FRAG;
-	xprt->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
+		transport->tcp_flags &= ~XPRT_LAST_FRAG;
+	transport->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
 
-	xprt->tcp_flags &= ~XPRT_COPY_RECM;
-	xprt->tcp_offset = 0;
+	transport->tcp_flags &= ~XPRT_COPY_RECM;
+	transport->tcp_offset = 0;
 
 	/* Sanity check of the record length */
-	if (unlikely(xprt->tcp_reclen < 4)) {
+	if (unlikely(transport->tcp_reclen < 4)) {
 		dprintk("RPC:      invalid TCP record fragment length\n");
 		xprt_disconnect(xprt);
 		return;
 	}
 	dprintk("RPC:      reading TCP record fragment of length %d\n",
-			xprt->tcp_reclen);
+			transport->tcp_reclen);
 }
 
-static void xs_tcp_check_recm(struct rpc_xprt *xprt)
+static void xs_tcp_check_fraghdr(struct sock_xprt *transport)
 {
-	dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u, tcp_flags = %lx\n",
-			xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen, xprt->tcp_flags);
-	if (xprt->tcp_offset == xprt->tcp_reclen) {
-		xprt->tcp_flags |= XPRT_COPY_RECM;
-		xprt->tcp_offset = 0;
-		if (xprt->tcp_flags & XPRT_LAST_FRAG) {
-			xprt->tcp_flags &= ~XPRT_COPY_DATA;
-			xprt->tcp_flags |= XPRT_COPY_XID;
-			xprt->tcp_copied = 0;
+	if (transport->tcp_offset == transport->tcp_reclen) {
+		transport->tcp_flags |= XPRT_COPY_RECM;
+		transport->tcp_offset = 0;
+		if (transport->tcp_flags & XPRT_LAST_FRAG) {
+			transport->tcp_flags &= ~XPRT_COPY_DATA;
+			transport->tcp_flags |= XPRT_COPY_XID;
+			transport->tcp_copied = 0;
 		}
 	}
 }
 
-static inline void xs_tcp_read_xid(struct rpc_xprt *xprt, skb_reader_t *desc)
+static inline void xs_tcp_read_xid(struct sock_xprt *transport, skb_reader_t *desc)
 {
 	size_t len, used;
 	char *p;
 
-	len = sizeof(xprt->tcp_xid) - xprt->tcp_offset;
+	len = sizeof(transport->tcp_xid) - transport->tcp_offset;
 	dprintk("RPC:      reading XID (%Zu bytes)\n", len);
-	p = ((char *) &xprt->tcp_xid) + xprt->tcp_offset;
+	p = ((char *) &transport->tcp_xid) + transport->tcp_offset;
 	used = xs_tcp_copy_data(desc, p, len);
-	xprt->tcp_offset += used;
+	transport->tcp_offset += used;
 	if (used != len)
 		return;
-	xprt->tcp_flags &= ~XPRT_COPY_XID;
-	xprt->tcp_flags |= XPRT_COPY_DATA;
-	xprt->tcp_copied = 4;
+	transport->tcp_flags &= ~XPRT_COPY_XID;
+	transport->tcp_flags |= XPRT_COPY_DATA;
+	transport->tcp_copied = 4;
 	dprintk("RPC:      reading reply for XID %08x\n",
-						ntohl(xprt->tcp_xid));
-	xs_tcp_check_recm(xprt);
+			ntohl(transport->tcp_xid));
+	xs_tcp_check_fraghdr(transport);
 }
 
 static inline void xs_tcp_read_request(struct rpc_xprt *xprt, skb_reader_t *desc)
 {
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 	struct xdr_buf *rcvbuf;
 	size_t len;
@@ -712,34 +724,34 @@ static inline void xs_tcp_read_request(s
 
 	/* Find and lock the request corresponding to this xid */
 	spin_lock(&xprt->transport_lock);
-	req = xprt_lookup_rqst(xprt, xprt->tcp_xid);
+	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
 	if (!req) {
-		xprt->tcp_flags &= ~XPRT_COPY_DATA;
+		transport->tcp_flags &= ~XPRT_COPY_DATA;
 		dprintk("RPC:      XID %08x request not found!\n",
-				ntohl(xprt->tcp_xid));
+				ntohl(transport->tcp_xid));
 		spin_unlock(&xprt->transport_lock);
 		return;
 	}
 
 	rcvbuf = &req->rq_private_buf;
 	len = desc->count;
-	if (len > xprt->tcp_reclen - xprt->tcp_offset) {
+	if (len > transport->tcp_reclen - transport->tcp_offset) {
 		skb_reader_t my_desc;
 
-		len = xprt->tcp_reclen - xprt->tcp_offset;
+		len = transport->tcp_reclen - transport->tcp_offset;
 		memcpy(&my_desc, desc, sizeof(my_desc));
 		my_desc.count = len;
-		r = xdr_partial_copy_from_skb(rcvbuf, xprt->tcp_copied,
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
 					  &my_desc, xs_tcp_copy_data);
 		desc->count -= r;
 		desc->offset += r;
 	} else
-		r = xdr_partial_copy_from_skb(rcvbuf, xprt->tcp_copied,
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
 					  desc, xs_tcp_copy_data);
 
 	if (r > 0) {
-		xprt->tcp_copied += r;
-		xprt->tcp_offset += r;
+		transport->tcp_copied += r;
+		transport->tcp_offset += r;
 	}
 	if (r != len) {
 		/* Error when copying to the receive buffer,
@@ -751,77 +763,79 @@ static inline void xs_tcp_read_request(s
 		 * Any remaining data from this record will
 		 * be discarded.
 		 */
-		xprt->tcp_flags &= ~XPRT_COPY_DATA;
+		transport->tcp_flags &= ~XPRT_COPY_DATA;
 		dprintk("RPC:      XID %08x truncated request\n",
-				ntohl(xprt->tcp_xid));
+				ntohl(transport->tcp_xid));
 		dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
-				xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen);
+				xprt, transport->tcp_copied, transport->tcp_offset,
+					transport->tcp_reclen);
 		goto out;
 	}
 
 	dprintk("RPC:      XID %08x read %Zd bytes\n",
-			ntohl(xprt->tcp_xid), r);
+			ntohl(transport->tcp_xid), r);
 	dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
-			xprt, xprt->tcp_copied, xprt->tcp_offset, xprt->tcp_reclen);
-
-	if (xprt->tcp_copied == req->rq_private_buf.buflen)
-		xprt->tcp_flags &= ~XPRT_COPY_DATA;
-	else if (xprt->tcp_offset == xprt->tcp_reclen) {
-		if (xprt->tcp_flags & XPRT_LAST_FRAG)
-			xprt->tcp_flags &= ~XPRT_COPY_DATA;
+			xprt, transport->tcp_copied, transport->tcp_offset,
+				transport->tcp_reclen);
+
+	if (transport->tcp_copied == req->rq_private_buf.buflen)
+		transport->tcp_flags &= ~XPRT_COPY_DATA;
+	else if (transport->tcp_offset == transport->tcp_reclen) {
+		if (transport->tcp_flags & XPRT_LAST_FRAG)
+			transport->tcp_flags &= ~XPRT_COPY_DATA;
 	}
 
 out:
-	if (!(xprt->tcp_flags & XPRT_COPY_DATA))
-		xprt_complete_rqst(req->rq_task, xprt->tcp_copied);
+	if (!(transport->tcp_flags & XPRT_COPY_DATA))
+		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
 	spin_unlock(&xprt->transport_lock);
-	xs_tcp_check_recm(xprt);
+	xs_tcp_check_fraghdr(transport);
 }
 
-static inline void xs_tcp_read_discard(struct rpc_xprt *xprt, skb_reader_t *desc)
+static inline void xs_tcp_read_discard(struct sock_xprt *transport, skb_reader_t *desc)
 {
 	size_t len;
 
-	len = xprt->tcp_reclen - xprt->tcp_offset;
+	len = transport->tcp_reclen - transport->tcp_offset;
 	if (len > desc->count)
 		len = desc->count;
 	desc->count -= len;
 	desc->offset += len;
-	xprt->tcp_offset += len;
+	transport->tcp_offset += len;
 	dprintk("RPC:      discarded %Zu bytes\n", len);
-	xs_tcp_check_recm(xprt);
+	xs_tcp_check_fraghdr(transport);
 }
 
 static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
 {
 	struct rpc_xprt *xprt = rd_desc->arg.data;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	skb_reader_t desc = {
 		.skb	= skb,
 		.offset	= offset,
 		.count	= len,
-		.csum	= 0
 	};
 
 	dprintk("RPC:      xs_tcp_data_recv started\n");
 	do {
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
-		if (xprt->tcp_flags & XPRT_COPY_RECM) {
+		if (transport->tcp_flags & XPRT_COPY_RECM) {
 			xs_tcp_read_fraghdr(xprt, &desc);
 			continue;
 		}
 		/* Read in the xid if necessary */
-		if (xprt->tcp_flags & XPRT_COPY_XID) {
-			xs_tcp_read_xid(xprt, &desc);
+		if (transport->tcp_flags & XPRT_COPY_XID) {
+			xs_tcp_read_xid(transport, &desc);
 			continue;
 		}
 		/* Read in the request data */
-		if (xprt->tcp_flags & XPRT_COPY_DATA) {
+		if (transport->tcp_flags & XPRT_COPY_DATA) {
 			xs_tcp_read_request(xprt, &desc);
 			continue;
 		}
 		/* Skip over any trailing bytes on short reads */
-		xs_tcp_read_discard(xprt, &desc);
+		xs_tcp_read_discard(transport, &desc);
 	} while (desc.count);
 	dprintk("RPC:      xs_tcp_data_recv done\n");
 	return len - desc.count;
@@ -875,11 +889,15 @@ static void xs_tcp_state_change(struct s
 	case TCP_ESTABLISHED:
 		spin_lock_bh(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
+			struct sock_xprt *transport = container_of(xprt,
+					struct sock_xprt, xprt);
+
 			/* Reset TCP record info */
-			xprt->tcp_offset = 0;
-			xprt->tcp_reclen = 0;
-			xprt->tcp_copied = 0;
-			xprt->tcp_flags = XPRT_COPY_RECM | XPRT_COPY_XID;
+			transport->tcp_offset = 0;
+			transport->tcp_reclen = 0;
+			transport->tcp_copied = 0;
+			transport->tcp_flags = XPRT_COPY_RECM | XPRT_COPY_XID;
+
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 			xprt_wake_pending_tasks(xprt, 0);
 		}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
