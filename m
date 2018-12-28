Return-Path: <SRS0=XDl6=PF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72C8BC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Dec 2018 02:55:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2CD1D214C6
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Dec 2018 02:55:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RtCQ91Ih"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728177AbeL1CzS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Dec 2018 21:55:18 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:40490 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726873AbeL1CzR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2018 21:55:17 -0500
Received: by mail-pg1-f196.google.com with SMTP id z10so9491426pgp.7;
        Thu, 27 Dec 2018 18:55:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=7C49Dk38UTlEkVQcN/N0SGjB+P62imQcKZsC2ilj/A4=;
        b=RtCQ91IhUIwdJMB0yHiKF728Z6OceIxLxVzDTRZpi8lnH7cV0aHSCHOXG710dnuu7m
         VmgKAJN5zQSsQ4rg6BaHX87BPWehdm2DlPZCr1DRIV6NvsbouMmQ7ctjvYVPr9o2iK3u
         r2m0INlP6w1sBF994GfU22GeTIeR/L8ZfVtb6NTotcvLp76A2zYHiBLyyyZcKYr908JA
         a9PMSB/zcl1tNPvS4CiwNv0RrupJGLke2ix5u5Cjy4yrni17K/MyKcVe9wOnQs2vr6Ei
         JDFkQIQ5IEijrmNhnWIBxqimLyZydeoDAQL05dvQ8fSb8kJmZ2CDu/bJn+r017s0foSz
         j+WQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=7C49Dk38UTlEkVQcN/N0SGjB+P62imQcKZsC2ilj/A4=;
        b=QY3PGmrDotQs6jLKD+Iv85HXHGSoVG71kUhaq1WAj41HmpwaZ0vbgusF+ETiJOGIXS
         2JCdqsB+HJyDPtkq87dRRsF2UJoWDS/Elnds1SqRRqZqRYjkIHIDEEw3dXsGduNCmxzn
         Mcrlj08R+d0Oy+h1K2GvNejOzuD6ukkcYu6w2o+uGlb8WLdEeW4w/E05PWR1PfQZOKAU
         0EahDhNgXsen0h0o3qcV6Tj5W9hj66RjD2PKv6SVN6/YFIQlxlN+wVLdNH2/CPgeWVMW
         oZG0prkvyPdia1VqUEOp8niq2ri/oT6ezFLT71qlCl1i13I6v20zCnh6r05sWNN2amnR
         rOEQ==
X-Gm-Message-State: AJcUukeAmmaFKnFV11HdL1k01taooA0Zwn3GQuJARKMmnGbp+cAkV/LL
        egWJyEPOjmTe5g3z5b1Tx/bX/upf
X-Google-Smtp-Source: AFSGD/UEj7T4wzKqnni8+YqVPC796Y+S35F5IbEAcMHewGa0pvtJkDNs+B6o1RCemoofBWbYKuGCHA==
X-Received: by 2002:a62:1484:: with SMTP id 126mr26090954pfu.257.1545965715599;
        Thu, 27 Dec 2018 18:55:15 -0800 (PST)
Received: from deepa-ubuntu.lan (c-98-234-52-230.hsd1.ca.comcast.net. [98.234.52.230])
        by smtp.gmail.com with ESMTPSA id c13sm85461530pfe.93.2018.12.27.18.55.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 18:55:14 -0800 (PST)
From:   Deepa Dinamani <deepa.kernel@gmail.com>
To:     davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk, arnd@arndb.de,
        eric.dumazet@gmail.com, y2038@lists.linaro.org
Subject: [PATCH v3] sock: Make sock->sk_stamp thread-safe
Date:   Thu, 27 Dec 2018 18:55:09 -0800
Message-Id: <20181228025509.14194-1-deepa.kernel@gmail.com>
X-Mailer: git-send-email 2.17.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Al Viro mentioned (Message-ID
<20170626041334.GZ10672@ZenIV.linux.org.uk>)
that there is probably a race condition
lurking in accesses of sk_stamp on 32-bit machines.

sock->sk_stamp is of type ktime_t which is always an s64.
On a 32 bit architecture, we might run into situations of
unsafe access as the access to the field becomes non atomic.

Use seqlocks for synchronization.
This allows us to avoid using spinlocks for readers as
readers do not need mutual exclusion.

Another approach to solve this is to require sk_lock for all
modifications of the timestamps. The current approach allows
for timestamps to have their own lock: sk_stamp_lock.
This allows for the patch to not compete with already
existing critical sections, and side effects are limited
to the paths in the patch.

The addition of the new field maintains the data locality
optimizations from
commit 9115e8cd2a0c ("net: reorganize struct sock for better data
locality")

Note that all the instances of the sk_stamp accesses
are either through the ioctl or the syscall recvmsg.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
---
Changes since v2:
* added ifdef as per eric's request
Changes since v1:
* fixed sunrpc sk_stamp update

 include/net/sock.h   | 38 +++++++++++++++++++++++++++++++++++---
 net/compat.c         | 15 +++++++++------
 net/core/sock.c      | 15 ++++++++++-----
 net/sunrpc/svcsock.c |  2 +-
 4 files changed, 55 insertions(+), 15 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f665d74ae509..e144c071c93f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -298,6 +298,7 @@ struct sock_common {
   *	@sk_filter: socket filtering instructions
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
+  *	@sk_stamp_seq: lock for accessing sk_stamp on 32 bit architectures only
   *	@sk_tsflags: SO_TIMESTAMPING socket options
   *	@sk_tskey: counter to disambiguate concurrent tstamp requests
   *	@sk_zckey: counter to order MSG_ZEROCOPY notifications
@@ -474,6 +475,9 @@ struct sock {
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	ktime_t			sk_stamp;
+#if BITS_PER_LONG==32
+	seqlock_t		sk_stamp_seq;
+#endif
 	u16			sk_tsflags;
 	u8			sk_shutdown;
 	u32			sk_tskey;
@@ -2287,6 +2291,34 @@ static inline void sk_drops_add(struct sock *sk, const struct sk_buff *skb)
 	atomic_add(segs, &sk->sk_drops);
 }
 
+static inline ktime_t sock_read_timestamp(struct sock *sk)
+{
+#if BITS_PER_LONG==32
+	unsigned int seq;
+	ktime_t kt;
+
+	do {
+		seq = read_seqbegin(&sk->sk_stamp_seq);
+		kt = sk->sk_stamp;
+	} while (read_seqretry(&sk->sk_stamp_seq, seq));
+
+	return kt;
+#else
+	return sk->sk_stamp;
+#endif
+}
+
+static inline void sock_write_timestamp(struct sock *sk, ktime_t kt)
+{
+#if BITS_PER_LONG==32
+	write_seqlock(&sk->sk_stamp_seq);
+	sk->sk_stamp = kt;
+	write_sequnlock(&sk->sk_stamp_seq);
+#else
+	sk->sk_stamp = kt;
+#endif
+}
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			   struct sk_buff *skb);
 void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
@@ -2311,7 +2343,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	     (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
 	else
-		sk->sk_stamp = kt;
+		sock_write_timestamp(sk, kt);
 
 	if (sock_flag(sk, SOCK_WIFI_STATUS) && skb->wifi_acked_valid)
 		__sock_recv_wifi_status(msg, sk, skb);
@@ -2332,9 +2364,9 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_recv_ts_and_drops(msg, sk, skb);
 	else if (unlikely(sock_flag(sk, SOCK_TIMESTAMP)))
-		sk->sk_stamp = skb->tstamp;
+		sock_write_timestamp(sk, skb->tstamp);
 	else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP))
-		sk->sk_stamp = 0;
+		sock_write_timestamp(sk, 0);
 }
 
 void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
diff --git a/net/compat.c b/net/compat.c
index 47a614b370cd..d1f3a8a0b3ef 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -467,12 +467,14 @@ int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 	ctv = (struct compat_timeval __user *) userstamp;
 	err = -ENOENT;
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sk->sk_stamp);
+	tv = ktime_to_timeval(sock_read_timestamp(sk));
+
 	if (tv.tv_sec == -1)
 		return err;
 	if (tv.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		tv = ktime_to_timeval(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+		sock_write_timestamp(sk, kt);
+		tv = ktime_to_timeval(kt);
 	}
 	err = 0;
 	if (put_user(tv.tv_sec, &ctv->tv_sec) ||
@@ -494,12 +496,13 @@ int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *usersta
 	ctv = (struct compat_timespec __user *) userstamp;
 	err = -ENOENT;
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sk->sk_stamp);
+	ts = ktime_to_timespec(sock_read_timestamp(sk));
 	if (ts.tv_sec == -1)
 		return err;
 	if (ts.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		ts = ktime_to_timespec(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+		sock_write_timestamp(sk, kt);
+		ts = ktime_to_timespec(kt);
 	}
 	err = 0;
 	if (put_user(ts.tv_sec, &ctv->tv_sec) ||
diff --git a/net/core/sock.c b/net/core/sock.c
index 6d7e189e3cd9..8236b28611c5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2747,6 +2747,9 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
 	sk->sk_stamp = SK_DEFAULT_STAMP;
+#if BITS_PER_LONG==32
+	seqlock_init(&sk->sk_stamp_seq);
+#endif
 	atomic_set(&sk->sk_zckey, 0);
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -2846,12 +2849,13 @@ int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 	struct timeval tv;
 
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sk->sk_stamp);
+	tv = ktime_to_timeval(sock_read_timestamp(sk));
 	if (tv.tv_sec == -1)
 		return -ENOENT;
 	if (tv.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		tv = ktime_to_timeval(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+		sock_write_timestamp(sk, kt);
+		tv = ktime_to_timeval(kt);
 	}
 	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
 }
@@ -2862,11 +2866,12 @@ int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
 	struct timespec ts;
 
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sk->sk_stamp);
+	ts = ktime_to_timespec(sock_read_timestamp(sk));
 	if (ts.tv_sec == -1)
 		return -ENOENT;
 	if (ts.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
+		ktime_t kt = ktime_get_real();
+		sock_write_timestamp(sk, kt);
 		ts = ktime_to_timespec(sk->sk_stamp);
 	}
 	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 986f3ed7d1a2..b7e67310ec37 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -549,7 +549,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* Don't enable netstamp, sunrpc doesn't
 		   need that much accuracy */
 	}
-	svsk->sk_sk->sk_stamp = skb->tstamp;
+	sock_write_timestamp(svsk->sk_sk, skb->tstamp);
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
 	len  = skb->len;
-- 
2.17.1

