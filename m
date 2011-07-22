Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15816 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754412Ab1GVNSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:18:11 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, drbd-user@lists.linbit.com,
        devel@driverdev.osuosl.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com
Subject: [PATCH 12/13] net: add paged frag destructor support to kernel_sendpage.
Date: Fri, 22 Jul 2011 14:17:32 +0100
Message-ID: <1311340653-19336-12-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: drbd-user@lists.linbit.com
Cc: devel@driverdev.osuosl.org
Cc: cluster-devel@redhat.com
Cc: ocfs2-devel@oss.oracle.com
Cc: netdev@vger.kernel.org
Cc: ceph-devel@vger.kernel.org
Cc: rds-devel@oss.oracle.com
Cc: linux-nfs@vger.kernel.org
[since v1:
  Drop sendpage_destructor and just add an argument to sendpage protocol hooks
]
---
 drivers/block/drbd/drbd_main.c   |    1 +
 drivers/staging/pohmelfs/trans.c |    2 +-
 fs/dlm/lowcomms.c                |    2 +-
 fs/ocfs2/cluster/tcp.c           |    1 +
 include/linux/net.h              |    6 +++++-
 include/net/inet_common.h        |    4 +++-
 include/net/ip.h                 |    4 +++-
 include/net/sock.h               |    2 ++
 include/net/tcp.h                |    4 +++-
 net/ceph/messenger.c             |    2 +-
 net/core/sock.c                  |    6 +++++-
 net/ipv4/af_inet.c               |    9 ++++++---
 net/ipv4/ip_output.c             |    7 ++++---
 net/ipv4/tcp.c                   |   25 ++++++++++++++++---------
 net/ipv4/udp.c                   |   11 ++++++-----
 net/ipv4/udp_impl.h              |    5 +++--
 net/rds/tcp_send.c               |    1 +
 net/socket.c                     |   11 +++++++----
 net/sunrpc/svcsock.c             |    6 +++---
 net/sunrpc/xprtsock.c            |    2 +-
 20 files changed, 73 insertions(+), 38 deletions(-)

diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index 0358e55..49c7346 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -2584,6 +2584,7 @@ static int _drbd_send_page(struct drbd_conf *mdev, struct page *page,
 	set_fs(KERNEL_DS);
 	do {
 		sent = mdev->data.socket->ops->sendpage(mdev->data.socket, page,
+							NULL,
 							offset, len,
 							msg_flags);
 		if (sent == -EAGAIN) {
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
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index db5ee4b..81366a0 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -982,6 +982,7 @@ static void o2net_sendpage(struct o2net_sock_container *sc,
 		mutex_lock(&sc->sc_send_lock);
 		ret = sc->sc_sock->ops->sendpage(sc->sc_sock,
 						 virt_to_page(kmalloced_virt),
+						 NULL,
 						 (long)kmalloced_virt & ~PAGE_MASK,
 						 size, MSG_DONTWAIT);
 		mutex_unlock(&sc->sc_send_lock);
diff --git a/include/linux/net.h b/include/linux/net.h
index b299230..db562ba 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -157,6 +157,7 @@ struct kiocb;
 struct sockaddr;
 struct msghdr;
 struct module;
+struct skb_frag_destructor;
 
 struct proto_ops {
 	int		family;
@@ -203,6 +204,7 @@ struct proto_ops {
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
+				      struct skb_frag_destructor *destroy,
 				      int offset, size_t size, int flags);
 	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
@@ -273,7 +275,9 @@ extern int kernel_getsockopt(struct socket *sock, int level, int optname,
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
index 22fac98..91cd8d0 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -21,7 +21,9 @@ extern int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 extern int inet_accept(struct socket *sock, struct socket *newsock, int flags);
 extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size);
-extern ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+extern ssize_t inet_sendpage(struct socket *sock, struct page *page,
+			     struct skb_frag_destructor *frag,
+			     int offset,
 			     size_t size, int flags);
 extern int inet_recvmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size, int flags);
diff --git a/include/net/ip.h b/include/net/ip.h
index 66dd491..887a834 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -114,7 +114,9 @@ extern int		ip_append_data(struct sock *sk, struct flowi4 *fl4,
 				struct rtable **rt,
 				unsigned int flags);
 extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
-extern ssize_t		ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
+extern ssize_t		ip_append_page(struct sock *sk, struct flowi4 *fl4,
+				struct page *page,
+				struct skb_frag_destructor *destroy,
 				int offset, size_t size, int flags);
 extern struct sk_buff  *__ip_make_skb(struct sock *sk,
 				      struct flowi4 *fl4,
diff --git a/include/net/sock.h b/include/net/sock.h
index c0b938c..c1ab674 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -763,6 +763,7 @@ struct proto {
 					size_t len, int noblock, int flags, 
 					int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
+					struct skb_frag_destructor *destroy,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
 					struct sockaddr *uaddr, int addr_len);
@@ -1152,6 +1153,7 @@ extern int			sock_no_mmap(struct file *file,
 					     struct vm_area_struct *vma);
 extern ssize_t			sock_no_sendpage(struct socket *sock,
 						struct page *page,
+						struct skb_frag_destructor *destroy,
 						int offset, size_t size, 
 						int flags);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..1f43c0d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -317,7 +317,9 @@ extern void *tcp_v4_tw_get_peer(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
-extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
+extern int tcp_sendpage(struct sock *sk, struct page *page,
+			struct skb_frag_destructor *destroy,
+			int offset,
 			size_t size, int flags);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
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
diff --git a/net/core/sock.c b/net/core/sock.c
index be55676..87d04db 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1858,7 +1858,9 @@ int sock_no_mmap(struct file *file, struct socket *sock, struct vm_area_struct *
 }
 EXPORT_SYMBOL(sock_no_mmap);
 
-ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
+ssize_t sock_no_sendpage(struct socket *sock, struct page *page,
+			 struct skb_frag_destructor *destroy,
+			 int offset, size_t size, int flags)
 {
 	ssize_t res;
 	struct msghdr msg = {.msg_flags = flags};
@@ -1868,6 +1870,8 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, siz
 	iov.iov_len = size;
 	res = kernel_sendmsg(sock, &msg, &iov, 1, size);
 	kunmap(page);
+	/* kernel_sendmsg copies so we can destroy immediately */
+	skb_frag_destructor_unref(destroy);
 	return res;
 }
 EXPORT_SYMBOL(sock_no_sendpage);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ef1528a..45c0876 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -740,7 +740,9 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
-ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+ssize_t inet_sendpage(struct socket *sock, struct page *page,
+		      struct skb_frag_destructor *destroy,
+		      int offset,
 		      size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -753,8 +755,9 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 		return -EAGAIN;
 
 	if (sk->sk_prot->sendpage)
-		return sk->sk_prot->sendpage(sk, page, offset, size, flags);
-	return sock_no_sendpage(sock, page, offset, size, flags);
+		return sk->sk_prot->sendpage(sk, page, destroy,
+					     offset, size, flags);
+	return sock_no_sendpage(sock, page, destroy, offset, size, flags);
 }
 EXPORT_SYMBOL(inet_sendpage);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c4326fb..b35b728 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1111,6 +1111,7 @@ int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 }
 
 ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
+		       struct skb_frag_destructor *destroy,
 		       int offset, size_t size, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1224,11 +1225,11 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		i = skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len = size;
-		if (skb_can_coalesce(skb, i, page, NULL, offset)) {
+		if (skb_can_coalesce(skb, i, page, destroy, offset)) {
 			skb_shinfo(skb)->frags[i-1].size += len;
 		} else if (i < MAX_SKB_FRAGS) {
-			get_page(page);
-			skb_fill_page_desc(skb, i, page, NULL, offset, len);
+			skb_fill_page_desc(skb, i, page, destroy, offset, len);
+			skb_frag_ref(skb, i);
 		} else {
 			err = -EMSGSIZE;
 			goto error;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a1a0ccd..2f590e5 100644
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
@@ -783,6 +786,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	while (psize > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		struct page *page = pages[poffset / PAGE_SIZE];
+		struct skb_frag_destructor *destroy =
+			destructors ? destructors[poffset / PAGE_SIZE] : NULL;
 		int copy, i, can_coalesce;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
@@ -804,7 +809,7 @@ new_segment:
 			copy = size;
 
 		i = skb_shinfo(skb)->nr_frags;
-		can_coalesce = skb_can_coalesce(skb, i, page, NULL, offset);
+		can_coalesce = skb_can_coalesce(skb, i, page, destroy, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
@@ -815,8 +820,8 @@ new_segment:
 		if (can_coalesce) {
 			skb_shinfo(skb)->frags[i - 1].size += copy;
 		} else {
-			get_page(page);
-			skb_fill_page_desc(skb, i, page, NULL, offset, copy);
+			skb_fill_page_desc(skb, i, page, destroy, offset, copy);
+			skb_frag_ref(skb, i);
 		}
 
 		skb->len += copy;
@@ -871,18 +876,20 @@ out_err:
 	return sk_stream_error(sk, flags, err);
 }
 
-int tcp_sendpage(struct sock *sk, struct page *page, int offset,
-		 size_t size, int flags)
+int tcp_sendpage(struct sock *sk, struct page *page,
+		 struct skb_frag_destructor *destroy,
+		 int offset, size_t size, int flags)
 {
 	ssize_t res;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
-		return sock_no_sendpage(sk->sk_socket, page, offset, size,
-					flags);
+		return sock_no_sendpage(sk->sk_socket, page, destroy,
+					offset, size, flags);
 
 	lock_sock(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, &page, &destroy,
+			       offset, size, flags);
 	release_sock(sk);
 	return res;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 198f75b..ebdc8ea 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1027,8 +1027,9 @@ do_confirm:
 }
 EXPORT_SYMBOL(udp_sendmsg);
 
-int udp_sendpage(struct sock *sk, struct page *page, int offset,
-		 size_t size, int flags)
+int udp_sendpage(struct sock *sk, struct page *page,
+		 struct skb_frag_destructor *destroy,
+		 int offset, size_t size, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct udp_sock *up = udp_sk(sk);
@@ -1056,11 +1057,11 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	}
 
 	ret = ip_append_page(sk, &inet->cork.fl.u.ip4,
-			     page, offset, size, flags);
+			     page, destroy, offset, size, flags);
 	if (ret == -EOPNOTSUPP) {
 		release_sock(sk);
-		return sock_no_sendpage(sk->sk_socket, page, offset,
-					size, flags);
+		return sock_no_sendpage(sk->sk_socket, page, destroy,
+					offset, size, flags);
 	}
 	if (ret < 0) {
 		udp_flush_pending_frames(sk);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index aaad650..4923d82 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -23,8 +23,9 @@ extern int	compat_udp_getsockopt(struct sock *sk, int level, int optname,
 #endif
 extern int	udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			    size_t len, int noblock, int flags, int *addr_len);
-extern int	udp_sendpage(struct sock *sk, struct page *page, int offset,
-			     size_t size, int flags);
+extern int	udp_sendpage(struct sock *sk, struct page *page,
+			     struct skb_frag_destructor *destroy,
+			     int offset, size_t size, int flags);
 extern int	udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
 extern void	udp_destroy_sock(struct sock *sk);
 
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 1b4fd68..e0f03be 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -121,6 +121,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 						sg_page(&rm->data.op_sg[sg]),
 						rm->data.op_sg[sg].offset + off,
 						rm->data.op_sg[sg].length - off,
+						NULL,
 						MSG_DONTWAIT|MSG_NOSIGNAL);
 		rdsdebug("tcp sendpage %p:%u:%u ret %d\n", (void *)sg_page(&rm->data.op_sg[sg]),
 			 rm->data.op_sg[sg].offset + off, rm->data.op_sg[sg].length - off,
diff --git a/net/socket.c b/net/socket.c
index 02dc82d..4b77658 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -795,7 +795,7 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 	if (more)
 		flags |= MSG_MORE;
 
-	return kernel_sendpage(sock, page, offset, size, flags);
+	return kernel_sendpage(sock, page, NULL, offset, size, flags);
 }
 
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
@@ -3343,15 +3343,18 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
 }
 EXPORT_SYMBOL(kernel_setsockopt);
 
-int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+int kernel_sendpage(struct socket *sock, struct page *page,
+		    struct skb_frag_destructor *destroy,
+		    int offset,
 		    size_t size, int flags)
 {
 	sock_update_classid(sock->sk);
 
 	if (sock->ops->sendpage)
-		return sock->ops->sendpage(sock, page, offset, size, flags);
+		return sock->ops->sendpage(sock, page, destroy,
+					   offset, size, flags);
 
-	return sock_no_sendpage(sock, page, offset, size, flags);
+	return sock_no_sendpage(sock, page, destroy, offset, size, flags);
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
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 72abb73..d027621 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -397,7 +397,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		remainder -= len;
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
-		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
+		err = sock->ops->sendpage(sock, *ppage, NULL, base, len, flags);
 		if (remainder == 0 || err != len)
 			break;
 		sent += err;
-- 
1.7.2.5

