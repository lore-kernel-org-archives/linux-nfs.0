Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2282C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 02:57:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CFB021920
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 02:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ThW0RHWb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2405107AbeLWC5x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 22 Dec 2018 21:57:53 -0500
Received: from mail-pf1-f194.google.com ([209.85.210.194]:44701 "EHLO
        mail-pf1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2404416AbeLWC5x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Dec 2018 21:57:53 -0500
Received: by mail-pf1-f194.google.com with SMTP id u6so4387776pfh.11;
        Sat, 22 Dec 2018 18:57:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=jzY8tImxS1dt+L6rpiXH7Qu6EdyrYXWUUbSwwyf9T7M=;
        b=ThW0RHWb2fLF2TE9Fvvq/LLqpIKexHf1Lpz8bxKcAPghlKtpNBHSlDxuyV6SLJO495
         akja+8SPswm8T4cyzGroCPLohXSwRviax0zoW3GZx58nRMCu5PEqQjYGQnDnAqfX/VC1
         Dl7w/OWa52ooBSdy6oslQyW09PhqPMLa3XwEI02LAXHbeyoxTLw7eQ79s+6C43qI4N4h
         Ovkmda9F/pGS/RW4gBwj1P5r++9KD+MQW3DkHXFwODKRlAPQP9zPT4JBFHBjBZy4q5Xu
         RwbgYln9LbVJRSe/rG7sjFZSb2M8bVxvP9gPsiTXEIqtx7QrdpldhdCZff6DW+uXa1J6
         CBDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=jzY8tImxS1dt+L6rpiXH7Qu6EdyrYXWUUbSwwyf9T7M=;
        b=g1v0a11117h0clgYpbavcYBPIuyj0oDkEJMWfM08roTiRHlzyFlod9MGcH/aVFshcd
         qisfvsT1nzV4jP+JNAfW4M+v0LvCQ/1v3HDTB9asJsyNzPQ2F1IKvdwlMPAa0ulLWC8K
         iBM+xlxSwrunStB4evGDkrsYTe4usNdZPOv6HeJubDAHD0wwDeCYXQ04A/Dkn0OhLn9v
         BzvtP2yeDysjrgUKnBnnYOsSJcon7nZHFt5rXrN6uNm/oMjG6O5JNmSeRwU28S9tB1pe
         99HuyP5fdw8tBktmkRctVCEh0CdivQpJlu95ELamUEpUu8tpRvb2eGEa1n1fSldvUvxO
         NkLw==
X-Gm-Message-State: AJcUukeB/v00IPcX23LrzPDQcE3avnzp7mqt9coh3pi0CbLv0wEAhc1F
        igTQPX+gpaLXyWcJLWI97lciOQUq
X-Google-Smtp-Source: ALg8bN4B8aCWItyJx4gP7PIQvqYPv3ZyJH9p+pcTnQMX6P/K777rzeyNPBPVRYhYgJz0eH9z0vml1A==
X-Received: by 2002:a63:334a:: with SMTP id z71mr8061526pgz.400.1545533872359;
        Sat, 22 Dec 2018 18:57:52 -0800 (PST)
Received: from deepa-ubuntu.lan (c-98-234-52-230.hsd1.ca.comcast.net. [98.234.52.230])
        by smtp.gmail.com with ESMTPSA id g185sm34891525pfc.174.2018.12.22.18.57.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Dec 2018 18:57:51 -0800 (PST)
From:   Deepa Dinamani <deepa.kernel@gmail.com>
To:     davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk, arnd@arndb.de,
        y2038@lists.linaro.org
Subject: [PATCH v2 1/1] sock: Make sock->sk_stamp thread-safe
Date:   Sat, 22 Dec 2018 18:57:35 -0800
Message-Id: <20181223025735.7591-1-deepa.kernel@gmail.com>
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
Changes since v1:
* fixed sunrpc sk_stamp update

 include/net/sock.h   | 16 +++++++++++++---
 net/compat.c         | 32 ++++++++++++++++++++++++++------
 net/core/sock.c      | 34 +++++++++++++++++++++++++++++-----
 net/sunrpc/svcsock.c |  2 ++
 4 files changed, 70 insertions(+), 14 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index fe58aec00d09..2cb641606533 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -298,6 +298,7 @@ struct sock_common {
   *	@sk_filter: socket filtering instructions
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
+  *	@sk_stamp_seq: lock for accessing sk_stamp
   *	@sk_tsflags: SO_TIMESTAMPING socket options
   *	@sk_tskey: counter to disambiguate concurrent tstamp requests
   *	@sk_zckey: counter to order MSG_ZEROCOPY notifications
@@ -474,6 +475,7 @@ struct sock {
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	ktime_t			sk_stamp;
+	seqlock_t		sk_stamp_seq;
 	u16			sk_tsflags;
 	u8			sk_shutdown;
 	u32			sk_tskey;
@@ -2311,8 +2313,11 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	    (hwtstamps->hwtstamp &&
 	     (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
-	else
+	else {
+		write_seqlock(&sk->sk_stamp_seq);
 		sk->sk_stamp = kt;
+		write_sequnlock(&sk->sk_stamp_seq);
+	}
 
 	if (sock_flag(sk, SOCK_WIFI_STATUS) && skb->wifi_acked_valid)
 		__sock_recv_wifi_status(msg, sk, skb);
@@ -2332,10 +2337,15 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
 		__sock_recv_ts_and_drops(msg, sk, skb);
-	else if (unlikely(sock_flag(sk, SOCK_TIMESTAMP)))
+	else if (unlikely(sock_flag(sk, SOCK_TIMESTAMP))) {
+		write_seqlock(&sk->sk_stamp_seq);
 		sk->sk_stamp = skb->tstamp;
-	else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP))
+		write_sequnlock(&sk->sk_stamp_seq);
+	} else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP)) {
+		write_seqlock(&sk->sk_stamp_seq);
 		sk->sk_stamp = 0;
+		write_sequnlock(&sk->sk_stamp_seq);
+	}
 }
 
 void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
diff --git a/net/compat.c b/net/compat.c
index 6c9fceeefac0..17da30bd34a9 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -459,6 +459,7 @@ int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
 	struct compat_timeval __user *ctv;
 	int err;
+	unsigned int seq;
 	struct timeval tv;
 
 	if (COMPAT_USE_64BIT_TIME)
@@ -467,12 +468,21 @@ int compat_sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 	ctv = (struct compat_timeval __user *) userstamp;
 	err = -ENOENT;
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sk->sk_stamp);
+
+	do {
+		seq = read_seqbegin(&sk->sk_stamp_seq);
+		tv = ktime_to_timeval(sk->sk_stamp);
+	} while (read_seqretry(&sk->sk_stamp_seq, seq));
+
 	if (tv.tv_sec == -1)
 		return err;
 	if (tv.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		tv = ktime_to_timeval(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+
+		write_seqlock(&sk->sk_stamp_seq);
+		sk->sk_stamp = kt;
+		write_sequnlock(&sk->sk_stamp_seq);
+		tv = ktime_to_timeval(kt);
 	}
 	err = 0;
 	if (put_user(tv.tv_sec, &ctv->tv_sec) ||
@@ -486,6 +496,7 @@ int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *usersta
 {
 	struct compat_timespec __user *ctv;
 	int err;
+	unsigned int seq;
 	struct timespec ts;
 
 	if (COMPAT_USE_64BIT_TIME)
@@ -494,12 +505,21 @@ int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *usersta
 	ctv = (struct compat_timespec __user *) userstamp;
 	err = -ENOENT;
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sk->sk_stamp);
+
+	do {
+		seq = read_seqbegin(&sk->sk_stamp_seq);
+		ts = ktime_to_timespec(sk->sk_stamp);
+	} while (read_seqretry(&sk->sk_stamp_seq, seq));
+
 	if (ts.tv_sec == -1)
 		return err;
 	if (ts.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		ts = ktime_to_timespec(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+
+		write_seqlock(&sk->sk_stamp_seq);
+		sk->sk_stamp = kt;
+		write_sequnlock(&sk->sk_stamp_seq);
+		ts = ktime_to_timespec(kt);
 	}
 	err = 0;
 	if (put_user(ts.tv_sec, &ctv->tv_sec) ||
diff --git a/net/core/sock.c b/net/core/sock.c
index f0e0e12b2e0d..a9a99af24a95 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2783,6 +2783,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
 	sk->sk_stamp = SK_DEFAULT_STAMP;
+	seqlock_init(&sk->sk_stamp_seq);
 	atomic_set(&sk->sk_zckey, 0);
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -2880,15 +2881,27 @@ EXPORT_SYMBOL(lock_sock_fast);
 int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
 	struct timeval tv;
+	unsigned int seq;
 
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	tv = ktime_to_timeval(sk->sk_stamp);
+
+	do {
+		seq = read_seqbegin(&sk->sk_stamp_seq);
+		tv = ktime_to_timeval(sk->sk_stamp);
+	} while (read_seqretry(&sk->sk_stamp_seq, seq));
+
 	if (tv.tv_sec == -1)
 		return -ENOENT;
 	if (tv.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		tv = ktime_to_timeval(sk->sk_stamp);
+		ktime_t kt = ktime_get_real();
+
+		write_seqlock(&sk->sk_stamp_seq);
+		sk->sk_stamp = kt;
+		write_sequnlock(&sk->sk_stamp_seq);
+
+		tv = ktime_to_timeval(kt);
 	}
+
 	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
 }
 EXPORT_SYMBOL(sock_get_timestamp);
@@ -2896,13 +2909,24 @@ EXPORT_SYMBOL(sock_get_timestamp);
 int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
 {
 	struct timespec ts;
+	unsigned int seq;
 
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
-	ts = ktime_to_timespec(sk->sk_stamp);
+
+	do {
+		seq = read_seqbegin(&sk->sk_stamp_seq);
+		ts = ktime_to_timespec(sk->sk_stamp);
+	} while (read_seqretry(&sk->sk_stamp_seq, seq));
+
 	if (ts.tv_sec == -1)
 		return -ENOENT;
 	if (ts.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
+		ktime_t kt = ktime_get_real();
+
+		write_seqlock(&sk->sk_stamp_seq);
+		sk->sk_stamp = kt;
+		write_sequnlock(&sk->sk_stamp_seq);
+
 		ts = ktime_to_timespec(sk->sk_stamp);
 	}
 	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 986f3ed7d1a2..cd12177720aa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -549,7 +549,9 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* Don't enable netstamp, sunrpc doesn't
 		   need that much accuracy */
 	}
+	write_seqlock(&svsk->sk_sk->sk_stamp_seq);
 	svsk->sk_sk->sk_stamp = skb->tstamp;
+	write_sequnlock(&svsk->sk_sk->sk_stamp_seq);
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
 	len  = skb->len;
-- 
2.17.1

