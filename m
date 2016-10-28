Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36619 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942347AbcJ1Ruc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2016 13:50:32 -0400
Message-ID: <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Date: Fri, 28 Oct 2016 10:50:30 -0700
In-Reply-To: <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-28 at 10:16 -0700, Eric Dumazet wrote:
> Nice !
> 
> I was working on this as well and my implementation was somewhat
> different.

This is my WIP

Note this can be split in two parts.

1) One adding struct sock *sk param to ip_cmsg_recv_offset()
 
   This was because I left skb->sk NULL for skbs stored in receive
queue.
   You chose instead to set skb->sk, which is unusual (check
skb_orphan() BUG_ON())

2) Udp changes.

Tell me what you think, thanks again !


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 601258f6e621..52e70431abc9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3033,9 +3033,13 @@ int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				const struct sk_buff *skb);
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
 					int *peeked, int *off, int *err,
-					struct sk_buff **last);
+					struct sk_buff **last,
+					void (*destructor)(struct sock *sk,
+							   struct sk_buff *skb));
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
-				    int *peeked, int *off, int *err);
+				    int *peeked, int *off, int *err,
+				    void (*destructor)(struct sock *sk,
+						       struct sk_buff *skb));
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
 				  int *err);
 unsigned int datagram_poll(struct file *file, struct socket *sock,
diff --git a/include/net/ip.h b/include/net/ip.h
index 79b102ffbe16..f91fc376f3fb 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -572,7 +572,8 @@ int ip_options_rcv_srr(struct sk_buff *skb);
  */
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
-void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int tlen, int offset);
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
+			 struct sk_buff *skb, int tlen, int offset);
 int ip_cmsg_send(struct sock *sk, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
@@ -594,7 +595,7 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 
 static inline void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
-	ip_cmsg_recv_offset(msg, skb, 0, 0);
+	ip_cmsg_recv_offset(msg, skb->sk, skb, 0, 0);
 }
 
 bool icmp_global_allow(void);
diff --git a/include/net/udp.h b/include/net/udp.h
index 18f1e6b91927..0178f4552c4d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -248,6 +248,7 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 /* net/ipv4/udp.c */
 void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
+void udp_skb_destructor(struct sock *sk, struct sk_buff *skb);
 
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index bfb973aebb5b..48228d15f33c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -198,7 +198,8 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
  */
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 					int *peeked, int *off, int *err,
-					struct sk_buff **last)
+					struct sk_buff **last,
+					void (*destructor)(struct sock *sk, struct sk_buff *skb))
 {
 	struct sk_buff_head *queue = &sk->sk_receive_queue;
 	struct sk_buff *skb;
@@ -241,9 +242,11 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 				}
 
 				atomic_inc(&skb->users);
-			} else
+			} else {
 				__skb_unlink(skb, queue);
-
+				if (destructor)
+					destructor(sk, skb);
+			}
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			*off = _off;
 			return skb;
@@ -262,7 +265,9 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 EXPORT_SYMBOL(__skb_try_recv_datagram);
 
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
-				    int *peeked, int *off, int *err)
+				    int *peeked, int *off, int *err,
+				    void (*destructor)(struct sock *sk,
+						       struct sk_buff *skb))
 {
 	struct sk_buff *skb, *last;
 	long timeo;
@@ -271,7 +276,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 
 	do {
 		skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
-					      &last);
+					      &last, destructor);
 		if (skb)
 			return skb;
 
@@ -290,7 +295,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
 	int peeked, off = 0;
 
 	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				   &peeked, &off, err);
+				   &peeked, &off, err, NULL);
 }
 EXPORT_SYMBOL(skb_recv_datagram);
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b8a2d63d1fb8..1de70870d0aa 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -153,11 +153,10 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_IP, IP_ORIGDSTADDR, sizeof(sin), &sin);
 }
 
-void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
-			 int tlen, int offset)
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
+			 struct sk_buff *skb, int tlen, int offset)
 {
-	struct inet_sock *inet = inet_sk(skb->sk);
-	unsigned int flags = inet->cmsg_flags;
+	unsigned int flags = inet_sk(sk)->cmsg_flags;
 
 	/* Ordered by supposed usage frequency */
 	if (flags & IP_CMSG_PKTINFO) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bfa9609ba0f4..8ff7ee74a992 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1178,20 +1178,20 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 
 	atomic_sub(size, &sk->sk_rmem_alloc);
 
-	spin_lock_bh(&sk->sk_receive_queue.lock);
 	sk->sk_forward_alloc += size;
 	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
 	sk->sk_forward_alloc -= amt;
-	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 	if (amt)
 		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
 }
 
-static void udp_rmem_free(struct sk_buff *skb)
+/* Note : called with sk_receive_queue.lock held */
+void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(skb->sk, skb->truesize, 1);
+	udp_rmem_release(sk, skb->truesize, 1);
 }
+EXPORT_SYMBOL(udp_skb_destructor);
 
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 {
@@ -1220,17 +1220,14 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 		if (!__sk_mem_raise_allocated(sk, delta, amt, SK_MEM_RECV)) {
 			err = -ENOBUFS;
 			spin_unlock(&list->lock);
-			goto uncharge_drop;
+			goto drop;
 		}
 
 		sk->sk_forward_alloc += delta;
 	}
-
+	atomic_add(size, &sk->sk_rmem_alloc);
 	sk->sk_forward_alloc -= size;
 
-	/* the skb owner in now the udp socket */
-	skb->sk = sk;
-	skb->destructor = udp_rmem_free;
 	skb->dev = NULL;
 	sock_skb_set_dropcount(sk, skb);
 
@@ -1253,9 +1250,14 @@ EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
 
 static void udp_destruct_sock(struct sock *sk)
 {
-	/* reclaim completely the forward allocated memory */
-	__skb_queue_purge(&sk->sk_receive_queue);
-	udp_rmem_release(sk, 0, 0);
+	unsigned int total = 0;
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		total += skb->truesize;
+		kfree_skb(skb);
+	}
+	udp_rmem_release(sk, total, 0);
 	inet_sock_destruct(sk);
 }
 
@@ -1287,12 +1289,11 @@ EXPORT_SYMBOL_GPL(skb_consume_udp);
  */
 static int first_packet_length(struct sock *sk)
 {
-	struct sk_buff_head list_kill, *rcvq = &sk->sk_receive_queue;
+	struct sk_buff_head *rcvq = &sk->sk_receive_queue;
 	struct sk_buff *skb;
+	int total = 0;
 	int res;
 
-	__skb_queue_head_init(&list_kill);
-
 	spin_lock_bh(&rcvq->lock);
 	while ((skb = skb_peek(rcvq)) != NULL &&
 		udp_lib_checksum_complete(skb)) {
@@ -1302,12 +1303,14 @@ static int first_packet_length(struct sock *sk)
 				IS_UDPLITE(sk));
 		atomic_inc(&sk->sk_drops);
 		__skb_unlink(skb, rcvq);
-		__skb_queue_tail(&list_kill, skb);
+		total += skb->truesize;
+		kfree_skb(skb);
 	}
 	res = skb ? skb->len : -1;
+	if (total)
+		udp_rmem_release(sk, total, 1);
 	spin_unlock_bh(&rcvq->lock);
 
-	__skb_queue_purge(&list_kill);
 	return res;
 }
 
@@ -1363,7 +1366,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+				  &peeked, &off, &err, udp_skb_destructor);
 	if (!skb)
 		return err;
 
@@ -1420,7 +1423,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		*addr_len = sizeof(*sin);
 	}
 	if (inet->cmsg_flags)
-		ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr), off);
+		ip_cmsg_recv_offset(msg, sk, skb, sizeof(struct udphdr), off);
 
 	err = copied;
 	if (flags & MSG_TRUNC)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bbf6788..7e602b89c64d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -344,7 +344,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 try_again:
 	peeking = off = sk_peek_offset(sk, flags);
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+				  &peeked, &off, &err, udp_skb_destructor);
 	if (!skb)
 		return err;
 
@@ -425,7 +425,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 	if (is_udp4) {
 		if (inet->cmsg_flags)
-			ip_cmsg_recv_offset(msg, skb,
+			ip_cmsg_recv_offset(msg, sk, skb,
 					    sizeof(struct udphdr), off);
 	} else {
 		if (np->rxopt.all)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 145082e2ba36..8b995f88d000 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2114,7 +2114,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 
 		skip = sk_peek_offset(sk, flags);
 		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
-					      &last);
+					      &last, NULL);
 		if (skb)
 			break;
 


