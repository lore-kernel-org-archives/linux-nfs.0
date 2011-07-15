Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42445 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582Ab1GOLHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 07:07:22 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 08/10] net: add paged frag destructor support to kernel_sendpage.
Date: Fri, 15 Jul 2011 12:07:09 +0100
Message-ID: <1310728031-19569-8-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NB: I added a separate sendpage_destructor to struct proto_ops and struct proto
for this PoC but expect that it would be preferable to just add the new
parameter and update all callers in the tree for the final version.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/staging/pohmelfs/trans.c |    2 +-
 fs/dlm/lowcomms.c                |    2 +-
 include/linux/net.h              |    9 ++++++++-
 include/net/inet_common.h        |    4 ++++
 include/net/sock.h               |    4 ++++
 include/net/tcp.h                |    4 ++++
 net/ceph/messenger.c             |    2 +-
 net/ipv4/af_inet.c               |   20 ++++++++++++++++++--
 net/ipv4/tcp.c                   |   29 ++++++++++++++++++++++++-----
 net/ipv4/tcp_ipv4.c              |    1 +
 net/ipv6/af_inet6.c              |    1 +
 net/ipv6/tcp_ipv6.c              |    1 +
 net/socket.c                     |   28 +++++++++++++++++++++++-----
 net/sunrpc/svcsock.c             |    6 +++---
 14 files changed, 94 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/pohmelfs/trans.c b/drivers/staging/pohmelfs/trans.c
index 36a2535..b5d8411 100644
--- a/drivers/staging/pohmelfs/trans.c
+++ b/drivers/staging/pohmelfs/trans.c
@@ -104,7 +104,7 @@ static int netfs_trans_send_pages(struct netfs_trans *t, struct netfs_state *st)
 		msg.msg_flags = MSG_WAITALL | (attached_pages == 1 ? 0 :
 				MSG_MORE);
 
-		err = kernel_sendpage(st->socket, page, 0, size, msg.msg_flags);
+		err = kernel_sendpage(st->socket, page, NULL, 0, size, msg.msg_flags);
 		if (err <= 0) {
 			printk("%s: %d/%d failed to send transaction page: t: %p, gen: %u, size: %u, err: %d.\n",
 					__func__, i, t->page_num, t, t->gen, size, err);
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 5e2c71f..64933ff 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -1341,7 +1341,7 @@ static void send_to_sock(struct connection *con)
 
 		ret = 0;
 		if (len) {
-			ret = kernel_sendpage(con->sock, e->page, offset, len,
+			ret = kernel_sendpage(con->sock, e->page, NULL, offset, len,
 					      msg_flags);
 			if (ret == -EAGAIN || ret == 0) {
 				if (ret == -EAGAIN &&
diff --git a/include/linux/net.h b/include/linux/net.h
index b299230..dfedc46 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -157,6 +157,7 @@ struct kiocb;
 struct sockaddr;
 struct msghdr;
 struct module;
+struct skb_frag_destructor;
 
 struct proto_ops {
 	int		family;
@@ -204,6 +205,10 @@ struct proto_ops {
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
 				      int offset, size_t size, int flags);
+	ssize_t		(*sendpage_destructor)
+				     (struct socket *sock, struct page *page,
+				      struct skb_frag_destructor *destroy,
+				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
 };
@@ -273,7 +278,9 @@ extern int kernel_getsockopt(struct socket *sock, int level, int optname,
 			     char *optval, int *optlen);
 extern int kernel_setsockopt(struct socket *sock, int level, int optname,
 			     char *optval, unsigned int optlen);
-extern int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+extern int kernel_sendpage(struct socket *sock, struct page *page,
+			   struct skb_frag_destructor *destroy,
+			   int offset,
 			   size_t size, int flags);
 extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
 extern int kernel_sock_shutdown(struct socket *sock,
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 22fac98..0c39b4b 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -23,6 +23,10 @@ extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size);
 extern ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 			     size_t size, int flags);
+extern ssize_t inet_sendpage_destructor(struct socket *sock, struct page *page,
+			     struct skb_frag_destructor *frag,
+			     int offset,
+			     size_t size, int flags);
 extern int inet_recvmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size, int flags);
 extern int inet_shutdown(struct socket *sock, int how);
diff --git a/include/net/sock.h b/include/net/sock.h
index c0b938c..7836acf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -764,6 +764,10 @@ struct proto {
 					int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
+	int			(*sendpage_destructor)
+				       (struct sock *sk, struct page *page,
+					struct skb_frag_destructor *destroy,
+					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
 					struct sockaddr *uaddr, int addr_len);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..2b42320 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -319,6 +319,10 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
 extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags);
+extern int tcp_sendpage_destructor(struct sock *sk, struct page *page,
+			struct skb_frag_destructor *destroy,
+			int offset,
+			size_t size, int flags);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 struct tcphdr *th, unsigned len);
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 78b55f4..ec7955b 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -852,7 +852,7 @@ static int write_partial_msg_pages(struct ceph_connection *con)
 				cpu_to_le32(crc32c(tmpcrc, base, len));
 			con->out_msg_pos.did_page_crc = 1;
 		}
-		ret = kernel_sendpage(con->sock, page,
+		ret = kernel_sendpage(con->sock, page, NULL,
 				      con->out_msg_pos.page_pos + page_shift,
 				      len,
 				      MSG_DONTWAIT | MSG_NOSIGNAL |
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index eae1f67..7954809 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -738,7 +738,9 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
-ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+ssize_t inet_sendpage_destructor(struct socket *sock, struct page *page,
+		      struct skb_frag_destructor *destroy,
+		      int offset,
 		      size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -750,10 +752,21 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 	    inet_autobind(sk))
 		return -EAGAIN;
 
-	if (sk->sk_prot->sendpage)
+	if (destroy) {
+		if (sk->sk_prot->sendpage_destructor)
+			return sk->sk_prot->sendpage_destructor
+				(sk, page, destroy, offset, size, flags);
+	} else if (sk->sk_prot->sendpage)
 		return sk->sk_prot->sendpage(sk, page, offset, size, flags);
 	return sock_no_sendpage(sock, page, offset, size, flags);
 }
+EXPORT_SYMBOL(inet_sendpage_destructor);
+
+ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+		      size_t size, int flags)
+{
+	return inet_sendpage_destructor(sock, page, NULL, offset, size, flags);
+}
 EXPORT_SYMBOL(inet_sendpage);
 
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
@@ -917,6 +930,7 @@ const struct proto_ops inet_stream_ops = {
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.sendpage_destructor = inet_sendpage_destructor,
 	.splice_read	   = tcp_splice_read,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
@@ -945,6 +959,7 @@ const struct proto_ops inet_dgram_ops = {
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.sendpage_destructor = inet_sendpage_destructor,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
@@ -976,6 +991,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.sendpage_destructor = inet_sendpage_destructor,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3a3703c..bfc778e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -757,7 +757,10 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
+static ssize_t do_tcp_sendpages(struct sock *sk,
+				struct page **pages,
+				struct skb_frag_destructor **destructors,
+				int poffset,
 			 size_t psize, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -783,6 +786,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	while (psize > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		struct page *page = pages[poffset / PAGE_SIZE];
+		struct skb_frag_destructor *destructor = destructors ? destructors[poffset / PAGE_SIZE] : NULL;
 		int copy, i, can_coalesce;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
@@ -815,8 +819,9 @@ new_segment:
 		if (can_coalesce) {
 			skb_shinfo(skb)->frags[i - 1].size += copy;
 		} else {
-			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
+			skb_shinfo(skb)->frags[i].page.destructor = destructor;
+			skb_frag_ref(skb, i);
 		}
 
 		skb->len += copy;
@@ -871,8 +876,11 @@ out_err:
 	return sk_stream_error(sk, flags, err);
 }
 
-int tcp_sendpage(struct sock *sk, struct page *page, int offset,
-		 size_t size, int flags)
+int tcp_sendpage_destructor(struct sock *sk,
+			    struct page *page,
+			    struct skb_frag_destructor *destructor,
+			    int offset,
+			    size_t size, int flags)
 {
 	ssize_t res;
 
@@ -882,10 +890,21 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 					flags);
 
 	lock_sock(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, &page,
+			       destructor ? &destructor : NULL,
+			       offset, size, flags);
 	release_sock(sk);
 	return res;
 }
+EXPORT_SYMBOL(tcp_sendpage_destructor);
+
+int tcp_sendpage(struct sock *sk,
+		 struct page *page,
+		 int offset,
+		 size_t size, int flags)
+{
+	return tcp_sendpage_destructor(sk, page, NULL, offset, size, flags);
+}
 EXPORT_SYMBOL(tcp_sendpage);
 
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 708dc20..9baa996 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2587,6 +2587,7 @@ struct proto tcp_prot = {
 	.recvmsg		= tcp_recvmsg,
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
+	.sendpage_destructor	= tcp_sendpage_destructor,
 	.backlog_rcv		= tcp_v4_do_rcv,
 	.hash			= inet_hash,
 	.unhash			= inet_unhash,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d450a2f..58d2520 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -531,6 +531,7 @@ const struct proto_ops inet6_stream_ops = {
 	.recvmsg	   = inet_recvmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.sendpage_destructor = inet_sendpage_destructor,
 	.splice_read	   = tcp_splice_read,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 87551ca..98a2576 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2210,6 +2210,7 @@ struct proto tcpv6_prot = {
 	.recvmsg		= tcp_recvmsg,
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
+	.sendpage_destructor	= tcp_sendpage_destructor,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.hash			= tcp_v6_hash,
 	.unhash			= inet_unhash,
diff --git a/net/socket.c b/net/socket.c
index 02dc82d..f1c39a4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -795,7 +795,7 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 	if (more)
 		flags |= MSG_MORE;
 
-	return kernel_sendpage(sock, page, offset, size, flags);
+	return kernel_sendpage(sock, page, NULL, offset, size, flags);
 }
 
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
@@ -3343,15 +3343,33 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
 }
 EXPORT_SYMBOL(kernel_setsockopt);
 
-int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+int kernel_sendpage(struct socket *sock, struct page *page,
+		    struct skb_frag_destructor *destroy,
+		    int offset,
 		    size_t size, int flags)
 {
+	int ret;
 	sock_update_classid(sock->sk);
 
-	if (sock->ops->sendpage)
-		return sock->ops->sendpage(sock, page, offset, size, flags);
+	/*
+         * If we have a destructor but the socket does not support
+         * sendpage_destructor then fallback to sock_no_sendpage which
+         * is copying...
+         */
+	if (destroy) {
+		if (sock->ops->sendpage_destructor)
+			return sock->ops->sendpage_destructor(sock, page, destroy,
+							      offset, size, flags);
+	} else {
+		if (sock->ops->sendpage)
+			return sock->ops->sendpage(sock, page,
+						   offset, size, flags);
+	}
 
-	return sock_no_sendpage(sock, page, offset, size, flags);
+	ret = sock_no_sendpage(sock, page, offset, size, flags);
+	/* sock_no_sendpage copies so we can destroy immediately */
+	skb_frag_destructor_unref(destroy);
+	return ret;
 }
 EXPORT_SYMBOL(kernel_sendpage);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index af04f77..a80b1d3 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -181,7 +181,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	/* send head */
 	if (slen == xdr->head[0].iov_len)
 		flags = 0;
-	len = kernel_sendpage(sock, headpage, headoffset,
+	len = kernel_sendpage(sock, headpage, NULL, headoffset,
 				  xdr->head[0].iov_len, flags);
 	if (len != xdr->head[0].iov_len)
 		goto out;
@@ -194,7 +194,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
-		result = kernel_sendpage(sock, *ppage, base, size, flags);
+		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
 		if (result > 0)
 			len += result;
 		if (result != size)
@@ -208,7 +208,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
-		result = kernel_sendpage(sock, tailpage, tailoffset,
+		result = kernel_sendpage(sock, tailpage, NULL, tailoffset,
 				   xdr->tail[0].iov_len, 0);
 		if (result > 0)
 			len += result;
-- 
1.7.2.5

