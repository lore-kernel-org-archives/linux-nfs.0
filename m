Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932203AbcKDK3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Nov 2016 06:29:19 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        linux-nfs@vger.kernel.org
Subject: [PATCH net-next v2 1/2] net/sock: add an explicit sk argument for ip_cmsg_recv_offset()
Date: Fri,  4 Nov 2016 11:28:58 +0100
Message-Id: <1b4e5292a0c15494515423245e8eeb7adf2ebcea.1478254512.git.pabeni@redhat.com>
In-Reply-To: <cover.1478254512.git.pabeni@redhat.com>
References: <cover.1478254512.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that we can use it even after orphaining the skbuff.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
@Eric, please add your signed off by when you feel comfortable with the patch
as you basically authored it

 include/net/ip.h       | 5 +++--
 net/ipv4/ip_sockglue.c | 6 +++---
 net/ipv4/udp.c         | 2 +-
 net/ipv6/udp.c         | 2 +-
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 5413883..f25c662 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -578,7 +578,8 @@ int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
  */
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
-void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int tlen, int offset);
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
+			 struct sk_buff *skb, int tlen, int offset);
 int ip_cmsg_send(struct sock *sk, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
@@ -600,7 +601,7 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 
 static inline void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
-	ip_cmsg_recv_offset(msg, skb, 0, 0);
+	ip_cmsg_recv_offset(msg, skb->sk, skb, 0, 0);
 }
 
 bool icmp_global_allow(void);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b8a2d63..940257f 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -153,10 +153,10 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_IP, IP_ORIGDSTADDR, sizeof(sin), &sin);
 }
 
-void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
-			 int tlen, int offset)
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
+			 struct sk_buff *skb, int tlen, int offset)
 {
-	struct inet_sock *inet = inet_sk(skb->sk);
+	struct inet_sock *inet = inet_sk(sk);
 	unsigned int flags = inet->cmsg_flags;
 
 	/* Ordered by supposed usage frequency */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 195992e..55f2d7c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1420,7 +1420,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		*addr_len = sizeof(*sin);
 	}
 	if (inet->cmsg_flags)
-		ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr), off);
+		ip_cmsg_recv_offset(msg, sk, skb, sizeof(struct udphdr), off);
 
 	err = copied;
 	if (flags & MSG_TRUNC)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bb..cb73533 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -425,7 +425,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 	if (is_udp4) {
 		if (inet->cmsg_flags)
-			ip_cmsg_recv_offset(msg, skb,
+			ip_cmsg_recv_offset(msg, sk, skb,
 					    sizeof(struct udphdr), off);
 	} else {
 		if (np->rxopt.all)
-- 
1.8.3.1

