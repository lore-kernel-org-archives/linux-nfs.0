Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:24636 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab2AYM1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 07:27:33 -0500
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
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
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/6] net: add paged frag destructor support to kernel_sendpage.
Date: Wed, 25 Jan 2012 12:27:13 +0000
Message-ID: <1327494434-21566-5-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This requires adding a new argument to various sendpage hooks up and down the
stack. At the moment this parameter is always NULL.

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
---
 drivers/block/drbd/drbd_main.c           |    1 +
 drivers/scsi/iscsi_tcp.c                 |    4 ++--
 drivers/scsi/iscsi_tcp.h                 |    3 ++-
 drivers/staging/pohmelfs/trans.c         |    3 ++-
 drivers/target/iscsi/iscsi_target_util.c |    3 ++-
 fs/dlm/lowcomms.c                        |    4 ++--
 fs/ocfs2/cluster/tcp.c                   |    1 +
 include/linux/net.h                      |    6 +++++-
 include/net/inet_common.h                |    4 +++-
 include/net/ip.h                         |    4 +++-
 include/net/sock.h                       |    8 +++++---
 include/net/tcp.h                        |    4 +++-
 net/ceph/messenger.c                     |    2 +-
 net/core/sock.c                          |    6 +++++-
 net/ipv4/af_inet.c                       |    9 ++++++---
 net/ipv4/ip_output.c                     |    6 ++++--
 net/ipv4/tcp.c                           |   24 +++++++++++++++---------
 net/ipv4/udp.c                           |   11 ++++++-----
 net/ipv4/udp_impl.h                      |    5 +++--
 net/rds/tcp_send.c                       |    1 +
 net/socket.c                             |   11 +++++++----
 net/sunrpc/svcsock.c                     |    6 +++---
 net/sunrpc/xprtsock.c                    |    2 +-
 23 files changed, 83 insertions(+), 45 deletions(-)

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
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 7c34d8e..3884ae1 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -284,8 +284,8 @@ static int iscsi_sw_tcp_xmit_segment(struct iscsi_tcp_conn *tcp_conn,
 		if (!segment->data) {
 			sg = segment->sg;
 			offset += segment->sg_offset + sg->offset;
-			r = tcp_sw_conn->sendpage(sk, sg_page(sg), offset,
-						  copy, flags);
+			r = tcp_sw_conn->sendpage(sk, sg_page(sg), NULL,
+						  offset, copy, flags);
 		} else {
 			struct msghdr msg = { .msg_flags = flags };
 			struct kvec iov = {
diff --git a/drivers/scsi/iscsi_tcp.h b/drivers/scsi/iscsi_tcp.h
index 666fe09..1e23265 100644
--- a/drivers/scsi/iscsi_tcp.h
+++ b/drivers/scsi/iscsi_tcp.h
@@ -52,7 +52,8 @@ struct iscsi_sw_tcp_conn {
 	uint32_t		sendpage_failures_cnt;
 	uint32_t		discontiguous_hdr_cnt;
 
-	ssize_t (*sendpage)(struct socket *, struct page *, int, size_t, int);
+	ssize_t (*sendpage)(struct socket *, struct page *,
+			    struct skb_frag_destructor *, int, size_t, int);
 };
 
 struct iscsi_sw_tcp_host {
diff --git a/drivers/staging/pohmelfs/trans.c b/drivers/staging/pohmelfs/trans.c
index 06c1a74..96a7921 100644
--- a/drivers/staging/pohmelfs/trans.c
+++ b/drivers/staging/pohmelfs/trans.c
@@ -104,7 +104,8 @@ static int netfs_trans_send_pages(struct netfs_trans *t, struct netfs_state *st)
 		msg.msg_flags = MSG_WAITALL | (attached_pages == 1 ? 0 :
 				MSG_MORE);
 
-		err = kernel_sendpage(st->socket, page, 0, size, msg.msg_flags);
+		err = kernel_sendpage(st->socket, page, NULL,
+				      0, size, msg.msg_flags);
 		if (err <= 0) {
 			printk("%s: %d/%d failed to send transaction page: t: %p, gen: %u, size: %u, err: %d.\n",
 					__func__, i, t->page_num, t, t->gen, size, err);
diff --git a/drivers/target/iscsi/iscsi_target_util.c b/drivers/target/iscsi/iscsi_target_util.c
index 02348f7..d0c984b 100644
--- a/drivers/target/iscsi/iscsi_target_util.c
+++ b/drivers/target/iscsi/iscsi_target_util.c
@@ -1315,7 +1315,8 @@ send_hdr:
 		u32 sub_len = min_t(u32, data_len, space);
 send_pg:
 		tx_sent = conn->sock->ops->sendpage(conn->sock,
-					sg_page(sg), sg->offset + offset, sub_len, 0);
+					sg_page(sg), NULL,
+					sg->offset + offset, sub_len, 0);
 		if (tx_sent != sub_len) {
 			if (tx_sent == -EAGAIN) {
 				pr_err("tcp_sendpage() returned"
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 0b3109e..622107a 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -1342,8 +1342,8 @@ static void send_to_sock(struct connection *con)
 
 		ret = 0;
 		if (len) {
-			ret = kernel_sendpage(con->sock, e->page, offset, len,
-					      msg_flags);
+			ret = kernel_sendpage(con->sock, e->page, NULL,
+					      offset, len, msg_flags);
 			if (ret == -EAGAIN || ret == 0) {
 				if (ret == -EAGAIN &&
 				    test_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags) &&
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 044e7b5..e13851e 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -983,6 +983,7 @@ static void o2net_sendpage(struct o2net_sock_container *sc,
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
index 775009f..33ea0da 100644
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
index bb972d2..e13a512 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -801,6 +801,7 @@ struct proto {
 					size_t len, int noblock, int flags, 
 					int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
+					struct skb_frag_destructor *destroy,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
 					struct sockaddr *uaddr, int addr_len);
@@ -1422,9 +1423,10 @@ extern int			sock_no_mmap(struct file *file,
 					     struct socket *sock,
 					     struct vm_area_struct *vma);
 extern ssize_t			sock_no_sendpage(struct socket *sock,
-						struct page *page,
-						int offset, size_t size, 
-						int flags);
+					struct page *page,
+					struct skb_frag_destructor *destroy,
+					int offset, size_t size,
+					int flags);
 
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..147a268 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -322,7 +322,9 @@ extern void *tcp_v4_tw_get_peer(struct sock *sk);
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
index ad5b708..69f049b 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -851,7 +851,7 @@ static int write_partial_msg_pages(struct ceph_connection *con)
 				cpu_to_le32(crc32c(tmpcrc, base, len));
 			con->out_msg_pos.did_page_crc = 1;
 		}
-		ret = kernel_sendpage(con->sock, page,
+		ret = kernel_sendpage(con->sock, page, NULL,
 				      con->out_msg_pos.page_pos + page_shift,
 				      len,
 				      MSG_DONTWAIT | MSG_NOSIGNAL |
diff --git a/net/core/sock.c b/net/core/sock.c
index 002939c..563401b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1939,7 +1939,9 @@ int sock_no_mmap(struct file *file, struct socket *sock, struct vm_area_struct *
 }
 EXPORT_SYMBOL(sock_no_mmap);
 
-ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
+ssize_t sock_no_sendpage(struct socket *sock, struct page *page,
+			 struct skb_frag_destructor *destroy,
+			 int offset, size_t size, int flags)
 {
 	ssize_t res;
 	struct msghdr msg = {.msg_flags = flags};
@@ -1949,6 +1951,8 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, siz
 	iov.iov_len = size;
 	res = kernel_sendmsg(sock, &msg, &iov, 1, size);
 	kunmap(page);
+	/* kernel_sendmsg copies so we can destroy immediately */
+	skb_frag_destructor_unref(destroy);
 	return res;
 }
 EXPORT_SYMBOL(sock_no_sendpage);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f7b5670..591665d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -745,7 +745,9 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
-ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+ssize_t inet_sendpage(struct socket *sock, struct page *page,
+		      struct skb_frag_destructor *destroy,
+		      int offset,
 		      size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
@@ -758,8 +760,9 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
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
index 9e4eca6..2ce0b8e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1130,6 +1130,7 @@ int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 }
 
 ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
+		       struct skb_frag_destructor *destroy,
 		       int offset, size_t size, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1243,11 +1244,12 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		i = skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len = size;
-		if (skb_can_coalesce(skb, i, page, NULL, offset)) {
+		if (skb_can_coalesce(skb, i, page, destroy, offset)) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
 		} else if (i < MAX_SKB_FRAGS) {
-			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, len);
+			skb_frag_set_destructor(skb, i, destroy);
+			skb_frag_ref(skb, i);
 		} else {
 			err = -EMSGSIZE;
 			goto error;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a928aec..17dd307 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -755,8 +755,11 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
-			 size_t psize, int flags)
+static ssize_t do_tcp_sendpages(struct sock *sk,
+				struct page **pages,
+				struct skb_frag_destructor *destroy,
+				int poffset,
+				size_t psize, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -802,7 +805,7 @@ new_segment:
 			copy = size;
 
 		i = skb_shinfo(skb)->nr_frags;
-		can_coalesce = skb_can_coalesce(skb, i, page, NULL, offset);
+		can_coalesce = skb_can_coalesce(skb, i, page, destroy, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
@@ -813,8 +816,9 @@ new_segment:
 		if (can_coalesce) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 		} else {
-			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
+			skb_frag_set_destructor(skb, i, destroy);
+			skb_frag_ref(skb, i);
 		}
 
 		skb->len += copy;
@@ -869,18 +873,20 @@ out_err:
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
+	res = do_tcp_sendpages(sk, &page, destroy,
+			       offset, size, flags);
 	release_sock(sk);
 	return res;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..c596d36 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1029,8 +1029,9 @@ do_confirm:
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
@@ -1058,11 +1059,11 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
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
index 1b4fd68..71503ad 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -119,6 +119,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 	while (sg < rm->data.op_nents) {
 		ret = tc->t_sock->ops->sendpage(tc->t_sock,
 						sg_page(&rm->data.op_sg[sg]),
+						NULL,
 						rm->data.op_sg[sg].offset + off,
 						rm->data.op_sg[sg].length - off,
 						MSG_DONTWAIT|MSG_NOSIGNAL);
diff --git a/net/socket.c b/net/socket.c
index e56162c..1812660 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -815,7 +815,7 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 	if (more)
 		flags |= MSG_MORE;
 
-	return kernel_sendpage(sock, page, offset, size, flags);
+	return kernel_sendpage(sock, page, NULL, offset, size, flags);
 }
 
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
@@ -3358,15 +3358,18 @@ int kernel_setsockopt(struct socket *sock, int level, int optname,
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
index 4653286..0e6b919 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -185,7 +185,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	/* send head */
 	if (slen == xdr->head[0].iov_len)
 		flags = 0;
-	len = kernel_sendpage(sock, headpage, headoffset,
+	len = kernel_sendpage(sock, headpage, NULL, headoffset,
 				  xdr->head[0].iov_len, flags);
 	if (len != xdr->head[0].iov_len)
 		goto out;
@@ -198,7 +198,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
-		result = kernel_sendpage(sock, *ppage, base, size, flags);
+		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
 		if (result > 0)
 			len += result;
 		if (result != size)
@@ -212,7 +212,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
-		result = kernel_sendpage(sock, tailpage, tailoffset,
+		result = kernel_sendpage(sock, tailpage, NULL, tailoffset,
 				   xdr->tail[0].iov_len, 0);
 		if (result > 0)
 			len += result;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..38b2fec 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -408,7 +408,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
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

