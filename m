Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99F9A46D543;
	Fri, 28 Aug 2026 13:50:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787925042; cv=none; b=iOLzLxIPnNbuKH6isaLMLzoRJ3pFbVqX4NppFCwfxcLwwtLNmPMf5F0nKVnMfD1Wzc2Naz7W1heFi2yIxV/zUyVmsABEBCndI1tHa/PB6+wduxUXtjAOTdvkM9XsYEaMRPzm+86Uoch4r6Qh6mlT2B+5N/31m/HZwx7w7VT/zEQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787925042; c=relaxed/simple;
	bh=5PydHeJ4ayHphLCO/lpKzhMcMRvR+lpFj4I0IAtl58w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bIZnYqWOl9TIKBcpSFotknSB3LQgs6oVvnrDycUM3kewU/J0iM5faFrPEqfBhc11IPV+TVjQnbfOKQzTzEpCb1XpJ5hKpyydP4TVbqGPHBB7jXaSqpBLNiO12v0/L/e0AdYPFITFdKvYTKfb43QK2JqAcvA/Sr0pbnAm7zbYLT0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VMSFJlvq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VMSFJlvq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE16A1F00A3E;
	Fri, 28 Aug 2026 13:50:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787925040;
	bh=/3jHpVXAdDKyENdB1TyHln3BVpzFDWafxK+/umUf3gk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VMSFJlvqp6ZuDIuCHHLUJiH1pSRfAvS6WHMtfhFpQYwZzRTtMSu+bg++XI/PFO59c
	 RuM+4Fnw/mgGJAOI6gU4bFwbgnHBA49/orl7NtW4UVwDy+dt9snPrRmWtxoMQvThcj
	 c0jSoFfDbbiz0Cpr5idLR5CKPH/cjh2uW0ktrCaROA3TiYoBxOOl7K+luzmFu8owOj
	 ymHEXpqcKfjinzBs9LuLl/v9JKDCUDx0HWINzb96COorQv2r2RIIefOygVs5VKaA+a
	 7NQB6urikTvl9g99nbROn0TH+t1YCrNBcVezo3peR31rTXxlgShux4OH99gy9XH2aM
	 xPTGBzzvtRdzA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH 3/3] SUNRPC: Skip xpt_reserved accounting for non-UDP transports
Date: Fri, 28 Aug 2026 09:50:36 -0400
Message-ID: <20260828135036.796842-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260828135036.796842-1-cel@kernel.org>
References: <20260828135036.796842-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The xpt_reserved counter exists for UDP socket-buffer back-pressure.
svc_udp_has_wspace() is the only has_wspace implementation that
consults it, so on TCP and RDMA the counter is maintained and never
read. svc_handle_xprt() adds to it once per RPC. svc_reserve()
shrinks it again on each call from svc_process_common(), from
svc_xprt_release(), and from each proc function that calls
svc_reserve_auth(). Every shrinking call also runs
svc_xprt_resource_released(), which issues an smp_mb() and can
enqueue the transport.

Add an xcl_flags field to svc_xprt_class and set
SVC_XPRT_FLAG_WSPACE_RESERVE on the UDP class. Gate the xpt_reserved
accounting on that flag.

After the change, svc_reserve() no longer calls
svc_xprt_resource_released() on TCP and RDMA. Two paths still cover
that enqueue. svc_xprt_release() reaches the helper through
svc_xprt_release_slot(), and svc_xprt_received() enqueues a transport
whose XPT_DATA remains set.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h |  5 ++++-
 net/sunrpc/svc_xprt.c           | 25 ++++++++++++++++---------
 net/sunrpc/svcsock.c            |  1 +
 3 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index da2a2531e110..2af222f3ea2c 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -37,6 +37,9 @@ struct svc_xprt_class {
 	struct list_head	xcl_list;
 	u32			xcl_max_payload;
 	int			xcl_ident;
+	u32			xcl_flags;
+/* Set only on classes whose xpo_has_wspace() reads xpt_reserved */
+#define SVC_XPRT_FLAG_WSPACE_RESERVE	BIT(0)
 };
 
 /*
@@ -59,7 +62,7 @@ struct svc_xprt {
 	unsigned long		xpt_flags;
 
 	struct svc_serv		*xpt_server;	/* service for transport */
-	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
+	atomic_t		xpt_reserved;	/* outq space rsvd, UDP only */
 	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
 	spinlock_t		xpt_lock;	/* protects sk_deferred
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c0e6772c6683..6e96e9b93071 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -476,11 +476,11 @@ static bool svc_xprt_ready(struct svc_xprt *xprt)
 
 	/*
 	 * If another cpu has recently updated xpt_flags,
-	 * sk_sock->flags, xpt_reserved, or xpt_nr_rqsts, we need to
-	 * know about it; otherwise it's possible that both that cpu and
-	 * this one could call svc_xprt_enqueue() without either
-	 * svc_xprt_enqueue() recognizing that the conditions below
-	 * are satisfied, and we could stall indefinitely:
+	 * sk_sock->flags, xpt_reserved (UDP only), or xpt_nr_rqsts,
+	 * we need to know about it; otherwise it's possible that both
+	 * that cpu and this one could call svc_xprt_enqueue() without
+	 * either svc_xprt_enqueue() recognizing that the conditions
+	 * below are satisfied, and we could stall indefinitely:
 	 */
 	smp_rmb();
 	xpt_flags = READ_ONCE(xprt->xpt_flags);
@@ -552,6 +552,10 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
  * to make sure the reply fits.  This function reduces that reserved
  * space to be the amount of space used already, plus @space.
  *
+ * The transport's reservation is tracked only on classes that set
+ * SVC_XPRT_FLAG_WSPACE_RESERVE.  On the others, only @rqstp's
+ * reservation is updated.
+ *
  */
 void svc_reserve(struct svc_rqst *rqstp, int space)
 {
@@ -560,10 +564,12 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 	space += rqstp->rq_res.head[0].iov_len;
 
 	if (xprt && space < rqstp->rq_reserved) {
-		atomic_sub((rqstp->rq_reserved - space),
-			   &xprt->xpt_reserved);
+		if (xprt->xpt_class->xcl_flags & SVC_XPRT_FLAG_WSPACE_RESERVE) {
+			atomic_sub((rqstp->rq_reserved - space),
+				   &xprt->xpt_reserved);
+			svc_xprt_resource_released(xprt);
+		}
 		rqstp->rq_reserved = space;
-		svc_xprt_resource_released(xprt);
 	}
 }
 EXPORT_SYMBOL_GPL(svc_reserve);
@@ -870,7 +876,8 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		else
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
 		rqstp->rq_reserved = serv->sv_max_mesg;
-		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+		if (xprt->xpt_class->xcl_flags & SVC_XPRT_FLAG_WSPACE_RESERVE)
+			atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		if (len <= 0)
 			goto out;
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ef7ac080fcd3..e5459d504b6a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -800,6 +800,7 @@ static struct svc_xprt_class svc_udp_class = {
 	.xcl_ops = &svc_udp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 	.xcl_ident = XPRT_TRANSPORT_UDP,
+	.xcl_flags = SVC_XPRT_FLAG_WSPACE_RESERVE,
 };
 
 static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
-- 
2.54.0

