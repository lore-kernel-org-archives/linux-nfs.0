Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794528975;
	b=JxHoOB+xLOxWZsmkHAnqyboSdQl+OF4XFyRzUZNjrUghqW0UB/6zCQZ6nqtbo2hWedQc
	 jD+lC3YNDGbFsatXOskxeGGCoNXYp0rLgcBHFLFeAMIo16wzyedAZ6U22C3/RgxIKvbHp
	 ZIy6DuYXJAY2jDEZD7xnvnBo1f2Qho+No0gCBT7uAB06WuQqCJDQmMimtSawkoPOmFUud
	 lLZNjfFaY+qnFljFMXYFjuFgnfcy1XNYCnWtSwKmsBc8AnFRtlrBJJSWQ8BE5tZxdyVf9
	 Z5vfuOK5lDQ3Odn5hSSRC2sblcFXue9zFy+RYGKrZ9BYdTx526hFywnBttJqnykn86A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794528975;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5BiYSLry/tbqBUTFDglrfHyEDaiX82e5XrRFzLwGfdk=;
	b=neG6r/EaFQ2ihDHvtLj3ovbmPrmVElLXt9JDjrqQ3mgFjWfeLXRLwknmjnb8frDNA9w1
	 cez44rBvIm/Jgo3AE3Tec9mgScIejmgRWtpO07Qr9AZ18Wo0hORC/+nc7X93+60fZWT6N
	 gDVfPq1bEQLc7WPuBni17rPSCl5fLOqvxEeeC+4a8elo9+rgntsHbag+6xgQ920Mi0T3A
	 F3FxT8o92aIWQkJZ/JNv//0jOr/bCYQ4Gv8xEOOxIZA1JaMKD3Glfq19RVvXLBuXi/kMS
	 HYs6/QqxF1psH5Aqyudaf8aKQL6jbv/RnptJhVFEBgLQ+c6UZiw+jiayVHIeLFG8TPw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S+LcWsqI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6059606A339
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 00:16:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S+LcWsqI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 415FC1F000C8;
	Fri, 13 Nov 2026 00:16:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794528975;
	bh=5BiYSLry/tbqBUTFDglrfHyEDaiX82e5XrRFzLwGfdk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=S+LcWsqIUYKybfWo4rlp8HL5cJH+DCvKayIYRA0jLhcY+FSXdX4FHmhfJHaYgHgFI
	 NH1fOVudExRMIBYqz/seLxmsP8VrqDQQXiP0tV1JV2SroODwADtSWyvINpk4Cmn3VV
	 eFOCv0Tnb0Gg4iJTMiD4eJR6KWquC66F17Inf1Irj0lscPn6h+jtu81FYoAjgRfKIX
	 rsZJJOFt2u19bIAEMyMTZWrynuCShGBzlypW/HnDmBmGo2YcL7+M0ldha488u3R7v4
	 ErMy+f3kHr2mPuQSLkjjZy6tMOtKOr47aAHC+83Ys1LkwqpVdaJfQRwxwz8QRdF8l+
	 hLDZp0v+XHB2A==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna.schumaker@oracle.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Splice a request's pages into the TCP socket
Date: Thu, 12 Nov 2026 19:16:11 -0500
Message-ID: <20261113001611.90519-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261113001611.90519-1-snitzer@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

xprt_sock_sendmsg() sends a request's page array to the socket as a
bvec, and tcp_sendmsg_locked() copies every byte of it into the
socket's skbs under the socket lock.  For an NFS WRITE that is the
whole payload, copied by rpciod one request at a time a transport: at
1 MiB a WRITE it comes to about 3 GB/s a connection, and on a client
with 24 connections to a server whose storage takes more, it is the
ceiling of the rate, with 18% of the client's 48 CPUs in memcpy under
tcp_sendmsg_locked().

Until commit 0472e4766049 ("SUNRPC: Convert socket page send code to
use iov_iter()") the client sent the pages with kernel_sendpage(), so
the socket held them and copied nothing.  Send them with
MSG_SPLICE_PAGES, as the server's svc_tcp_sendmsg() has since
commit 5df5dd03a8f7 ("sunrpc: Use sendmsg(MSG_SPLICE_PAGES) rather then
sendpage"), and the socket holds them again.  Only the page array is
spliced: the head and the tail are kvecs over the request's buffer,
memory the socket may not hold a reference to, and are copied as
before.

A request's pages are the caller's until the reply, and TCP delivers
them before the server can reply, so a first transmission is safe to
splice.  A retransmission is not: the reply to the first transmission
may complete the call and release the pages to be rewritten while the
socket still holds them for the second, the corruption that
commit a6b31d18b02f ("SUNRPC: Fix a data corruption issue when
retransmitting RPC calls") found with kernel_sendpage().  So a
retransmission is copied, as it was then, and only the TCP transport
asks for the splice: UDP and AF_LOCAL copy as before.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 net/sunrpc/socklib.c  | 26 ++++++++++++++++++++++----
 net/sunrpc/xprtsock.c |  9 +++++++++
 2 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index d8d8842c7de5c..ba18387f8ed6d 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -173,11 +173,17 @@ static int xprt_send_kvec(struct socket *sock, struct msghdr *msg,
 }
 
 static int xprt_send_pagedata(struct socket *sock, struct msghdr *msg,
-			      struct xdr_buf *xdr, size_t base)
+			      struct xdr_buf *xdr, size_t base,
+			      unsigned int splice)
 {
+	int ret;
+
 	iov_iter_bvec(&msg->msg_iter, ITER_SOURCE, xdr->bvec, xdr_buf_pagecount(xdr),
 		      xdr->page_len + xdr->page_base);
-	return xprt_sendmsg(sock, msg, base + xdr->page_base);
+	msg->msg_flags |= splice;
+	ret = xprt_sendmsg(sock, msg, base + xdr->page_base);
+	msg->msg_flags &= ~MSG_SPLICE_PAGES;
+	return ret;
 }
 
 /* Common case:
@@ -207,6 +213,12 @@ static int xprt_send_rm_and_kvec(struct socket *sock, struct msghdr *msg,
  * @sock: open socket to send on
  * @msg: socket message metadata
  * @xdr: xdr_buf containing this request
+ *
+ * With %MSG_SPLICE_PAGES set in @msg->msg_flags, the pages of @xdr are
+ * spliced into the socket rather than copied, and the caller must leave
+ * them unchanged until the socket has sent them.  The head and the tail
+ * are always copied.
+ *
  * @base: starting position in the buffer
  * @marker: stream record marker field
  * @sent_p: return the total number of bytes successfully queued for sending
@@ -221,6 +233,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 {
 	unsigned int rmsize = marker ? sizeof(marker) : 0;
 	unsigned int remainder = rmsize + xdr->len - base;
+	unsigned int splice = msg->msg_flags & MSG_SPLICE_PAGES;
 	unsigned int want;
 	int err = 0;
 
@@ -229,6 +242,10 @@ int xprt_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (unlikely(!sock))
 		return -ENOTSOCK;
 
+	/* The head and tail are kvecs over memory the socket may not
+	 * hold a reference to, so only the page array is spliced.
+	 */
+	msg->msg_flags &= ~MSG_SPLICE_PAGES;
 	msg->msg_flags |= MSG_MORE;
 	want = xdr->head[0].iov_len + rmsize;
 	if (base < want) {
@@ -256,7 +273,7 @@ int xprt_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 		remainder -= len;
 		if (remainder == 0)
 			msg->msg_flags &= ~MSG_MORE;
-		err = xprt_send_pagedata(sock, msg, xdr, base);
+		err = xprt_send_pagedata(sock, msg, xdr, base, splice);
 		if (remainder == 0 || err != len)
 			goto out;
 		*sent_p += err;
@@ -266,10 +283,11 @@ int xprt_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	}
 
 	if (base >= xdr->tail[0].iov_len)
-		return 0;
+		goto out;
 	msg->msg_flags &= ~MSG_MORE;
 	err = xprt_send_kvec(sock, msg, &xdr->tail[0], base);
 out:
+	msg->msg_flags |= splice;
 	if (err > 0) {
 		*sent_p += err;
 		err = 0;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 173e3b0fd7a3b..2a077cddcc8ad 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1136,6 +1136,15 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 
 	xs_set_srcport(transport, transport->sock);
 
+	/* Splice the pages of a first transmission into the socket: TCP
+	 * delivers them before the server can reply, and the reply is
+	 * what releases them.  A retransmission is copied, since the
+	 * reply to the first transmission may complete the call and
+	 * release the pages while the socket still holds them.
+	 */
+	if (!RPC_WAS_SENT(req->rq_task))
+		msg.msg_flags |= MSG_SPLICE_PAGES;
+
 	/* Continue transmitting the packet/record. We must be careful
 	 * to cope with writespace callbacks arriving _after_ we have
 	 * called sendmsg(). */
-- 
2.52.0

