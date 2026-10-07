Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D1194E80B7
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403184; cv=none; b=Yrg3tgUt29iVzmbJfrTBgFmYPsCeHV2P3jtF928CZujumktWXgDhZagGND3FPm1Fvv2fub/5t6RVS5Rb03xwxwjabrRtu0UnT7xQB6lPoteLH7EkofCrgAu/FVtbV3OpztvaunmFA4GNNEBBkdUYp/rDkt1igXim0hcFvAbYLLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403184; c=relaxed/simple;
	bh=TQc7SZqkDBQCFG0lnjA0nag40gg+xmh/Fn7XCu4lSh4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ldsk79AhtABc2lttKuwhUKwNT7+JpJI4paV9urfDIcmbEbzWyckjea79DgoDEdoE9Y7rNd32PqRgvfCl2vsha7JOMq3SgEkDYCIKWVWwpvz5LG59kGhlkSb03G3o4zMXtw5vV0stCCDpqiboaOvJWZZ2+3pGXoCVlg0SI02c9o4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=KFjM4r3H; arc=none smtp.client-ip=209.85.161.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KFjM4r3H"
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-6d00d120b28so1314205eaf.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403180; x=1792007980; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6qc+z2A1CDAkEk5V1tYJLxetVFb6K7NEYZRE6T4VBck=;
        b=KFjM4r3HYBOh/3Bj1nDb98nxlCkTDadnHPzX79UBTWin0xTBwneAXL3BoURGULU9Qj
         5BoxMYZSmGcFhae6W/7x9nnQyxjGysjWHEGxmaLGmTlbJgiwbO9QfE7/y64CHCQgibx8
         nz8HjI8WwoMYlXdnd90+mCcmQQ/HPtpp+OuHNIiBVfmSk9WCOjN4xKSJ+tAr4lrSXZp5
         x8cZH1E/CohJzUx7QRy1sIrfeedd4gTNKyIsqLD1n1SiWmQC4oelQ+uCfChzir//8jm1
         pM0KGc90aCLlSDuXNs/N8yyiH79EoSc2kFUQ6F/pUb5QpRbbFI73q0x+XQlHOoVE+68t
         1HoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403180; x=1792007980;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6qc+z2A1CDAkEk5V1tYJLxetVFb6K7NEYZRE6T4VBck=;
        b=w0qOIi+UYJLlJSqxkYXZb2kSD8wFQ5F1OCNzWuLr5tzaSSq8D6Xra5pYyJ/VE7euJc
         PMhFz4z/M8O/ISOUnAof0Iuqu7gZtz2ZJXbiIm/5kSRKfqQotiCENkO7jPmC55X5eChn
         udlKMdM965w/0mJfRwyHoj7l1ReYIA/3Z/og2Ur2UST3vGsTjRmrSvRtZCpPvNGihDly
         L/3mJFXGCUKnDEPYkOu93+XYFuATiwjR+9fEXByqgad57ouqavIk/JVQVHhAoC+q/c+X
         YZyYkbcV9OeIFwEFYu8266OsHsipjmDlp2l/m0QURonH5U2ZvlgBtmVq4YG+HPJ52wnv
         03dA==
X-Gm-Message-State: AFuF++lO8AQJZfmfd/AnSp1zqm8kjH5kP4h8Rz8ukshYHciSfiF+kXSV
	1PWCwnLzrvPpVB+iTsqt3HBXnqpeS8FGfGdlm8Zzwc36npW6AiqFJSIrd1DP0qixz10=
X-Gm-Gg: AYBFou1vD9rfg4QM4oiFntJ/xFaUWh8LM+pyAg/RI4Gq6Xh/0nLcWUKSUlr5+Ut22o1
	6EXoCc/3ptWHbRgdLRIjNpnK8bXcUNZ9NKJSIK3NqBmuIb979OZZjEZ+wtA+mFfJbbWVZFEK6I1
	PnnY4c++XT+C54wZW0mwwWU0gwmKLMNKWvgWZixJHNWVOzZ7bT73Pi8tHw+l70hZU8AsyTOMYN/
	6hYuS1mqd4BMjqRfcZDHEOoOYGUm9mdZ01HWDgW2cPZOhYTS8/wwcm+blPP4IwX7XfryE2njd+L
	5Y/XDcFzHTjBpd+Tv0lvalK0GmKdnGIP+kJb+m2Wg1YmOQl8zSWyKsj9rvrk4oSKJvt17KqH263
	xyfgQVsqXOGfISfKfStJHdfTlOCt+FJlcP2aohffMQ2eJo1SKZejyvLvYB7hccUeuiDZ9cQQfQx
	FhPBom4fl4TtZbcXohTKQ8XsKqo+pEWCm9U1YxsxTHGR3anVwxSphgzSEDYOv+cFckvzwwy15gx
	EZu+BkcTVU+28PdPk+MHAf2/Dnu8Aiy6Qs2+GSVEgk=
X-Received: by 2002:a05:6820:16a2:b0:6dd:d8be:118c with SMTP id 006d021491bc7-6e7a9258542mr3146448eaf.78.1791403179471;
        Wed, 07 Oct 2026 12:59:39 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:39 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 2/9] SUNRPC: dispatch ready transports round-robin across clients
Date: Wed,  7 Oct 2026 15:59:27 -0400
Message-ID: <630a7f082a6926159e6f25f333b1420af711de31.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

A pool keeps its ready transports in one FIFO and serves one RPC per
turn, so a peer is served in proportion to how many of its connections
are backlogged.  A client with K connections, or a deep NFSv4.1 slot
table spread over nconnect transports, takes K turns for every one a
single-connection client gets, and the single-connection client's
latency grows with everyone else's connection count.

Queue ready transports on their client instead, and have the pool
dispatch round-robin across clients: take the client at the head of
the pool's client queue, dispatch one of its transports, and put the
client back at the tail if it has more.  Every client with work queued
gets one dispatch per round however many connections it holds, and a
client's wait is bounded by the number of busy clients rather than by
the number of busy connections.  Within a client, transports are still
served in FIFO order.

Enqueue stays lockless: the transport goes on the client's per-pool
lwq, and the client goes on the pool's lwq the first time one of its
transports becomes ready, guarded by a per-pool SVC_CP_QUEUED bit that
the dequeuing thread clears when it finds the client empty.  The bit is
cleared before the client's queue is re-tested, so an enqueue that saw
it set and did not queue the client is caught by the re-test.  Dequeue
takes one more lwq spinlock than before.  Control events (XPT_CONN,
XPT_CLOSE, XPT_HANDSHAKE) take turns like data: a close queued behind
k of its own client's transports is dispatched k rounds later, where
it used to wait behind every queued transport in the pool.

Network namespace teardown walks the pool's clients: those of the
namespace being destroyed are drained and their transports deleted; the
anonymous client, which may hold listeners from several namespaces, is
filtered per transport; the rest are re-queued and a thread is woken.

While nothing returns a class from svc_classify(), every transport is
on the anonymous client, a pool's client queue holds one entry, and
dispatch is in today's FIFO order.

Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h |  2 +-
 net/sunrpc/svc.c           |  2 +-
 net/sunrpc/svc_xprt.c      | 97 +++++++++++++++++++++++++++++---------
 3 files changed, 77 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index e45f4fdea20b..a27dc2942167 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -38,7 +38,7 @@ struct svc_pool {
 	unsigned int		sp_nrthreads;	/* # of threads currently running in pool */
 	unsigned int		sp_nrthrmin;	/* Min number of threads to run per pool */
 	unsigned int		sp_nrthrmax;	/* Max requested number of threads in pool */
-	struct lwq		sp_xprts;	/* pending transports */
+	struct lwq		sp_clients;	/* clients with ready transports */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct llist_head	sp_idle_threads; /* idle server threads */
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index cb2b7caaa627..4adf113d067b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -477,7 +477,7 @@ __svc_create(struct svc_program *prog, int nprogs, struct svc_stat *stats,
 				i, serv->sv_name);
 
 		pool->sp_id = i;
-		lwq_init(&pool->sp_xprts);
+		lwq_init(&pool->sp_clients);
 		INIT_LIST_HEAD(&pool->sp_all_threads);
 		init_llist_head(&pool->sp_idle_threads);
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c7da55335506..735f4d92bf5d 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -627,6 +627,7 @@ static bool svc_xprt_ready(struct svc_xprt *xprt)
  */
 void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
+	struct svc_client_pool *cp;
 	struct svc_pool *pool;
 
 	if (!svc_xprt_ready(xprt))
@@ -641,25 +642,56 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		return;
 
 	pool = svc_pool_for_cpu(xprt->xpt_server);
+	cp = &xprt->xpt_client->cl_pool[pool->sp_id];
 
 	percpu_counter_inc(&pool->sp_sockets_queued);
 	xprt->xpt_qtime = ktime_get();
-	lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts);
+	lwq_enqueue(&xprt->xpt_ready, &cp->cp_xprts);
+	if (!test_and_set_bit(SVC_CP_QUEUED, &cp->cp_flags))
+		lwq_enqueue(&cp->cp_ready, &pool->sp_clients);
 
 	svc_pool_wake_idle_thread(pool);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 
 /*
- * Dequeue the first transport, if there is one.
+ * Put @cp back on the pool's client queue if it still has ready
+ * transports.  Otherwise clear SVC_CP_QUEUED and look once more: an
+ * enqueue that found the bit set has left the client for us to queue.
+ */
+static void svc_client_pool_requeue(struct svc_pool *pool,
+				    struct svc_client_pool *cp)
+{
+	if (!lwq_empty(&cp->cp_xprts)) {
+		lwq_enqueue(&cp->cp_ready, &pool->sp_clients);
+		return;
+	}
+	clear_bit(SVC_CP_QUEUED, &cp->cp_flags);
+	/* the clear is visible before the re-test; see svc_xprt_enqueue() */
+	smp_mb__after_atomic();
+	if (!lwq_empty(&cp->cp_xprts) &&
+	    !test_and_set_bit(SVC_CP_QUEUED, &cp->cp_flags))
+		lwq_enqueue(&cp->cp_ready, &pool->sp_clients);
+}
+
+/*
+ * Dequeue the next transport: one from the client at the head of the
+ * pool's client queue, which then goes to the tail if it has more.
  */
 static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 {
-	struct svc_xprt	*xprt = NULL;
+	struct svc_client_pool *cp;
+	struct svc_xprt	*xprt;
 
-	xprt = lwq_dequeue(&pool->sp_xprts, struct svc_xprt, xpt_ready);
-	if (xprt)
-		svc_xprt_get(xprt);
+	do {
+		cp = lwq_dequeue(&pool->sp_clients, struct svc_client_pool,
+				 cp_ready);
+		if (!cp)
+			return NULL;
+		xprt = lwq_dequeue(&cp->cp_xprts, struct svc_xprt, xpt_ready);
+		svc_client_pool_requeue(pool, cp);
+	} while (!xprt);
+	svc_xprt_get(xprt);
 	return xprt;
 }
 
@@ -886,7 +918,7 @@ svc_thread_should_sleep(struct svc_rqst *rqstp)
 		return false;
 
 	/* was a socket queued? */
-	if (!lwq_empty(&pool->sp_xprts))
+	if (!lwq_empty(&pool->sp_clients))
 		return false;
 
 	/* are we shutting down? */
@@ -1338,28 +1370,49 @@ static int svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, st
 	return ret;
 }
 
-static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
+/*
+ * Delete the ready transports of @net that are queued on @cp; the rest go
+ * back in their order.
+ */
+static void svc_client_pool_clean(struct svc_client_pool *cp, struct net *net)
 {
+	struct llist_node *q, **t1, *t2;
 	struct svc_xprt *xprt;
+
+	q = lwq_dequeue_all(&cp->cp_xprts);
+	lwq_for_each_safe(xprt, t1, t2, &q, xpt_ready) {
+		if (xprt->xpt_net == net) {
+			set_bit(XPT_CLOSE, &xprt->xpt_flags);
+			svc_delete_xprt(xprt);
+			xprt = NULL;
+		}
+	}
+	if (q)
+		lwq_enqueue_batch(q, &cp->cp_xprts);
+}
+
+static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
+{
 	int i;
 
 	for (i = 0; i < svc_serv_nrpools(serv); i++) {
 		struct svc_pool *pool = &serv->sv_pools[i];
-		struct llist_node *q, **t1, *t2;
-
-		q = lwq_dequeue_all(&pool->sp_xprts);
-		lwq_for_each_safe(xprt, t1, t2, &q, xpt_ready) {
-			if (xprt->xpt_net == net) {
-				set_bit(XPT_CLOSE, &xprt->xpt_flags);
-				svc_delete_xprt(xprt);
-				xprt = NULL;
-			}
-		}
-
-		if (q) {
-			lwq_enqueue_batch(q, &pool->sp_xprts);
-			svc_pool_wake_idle_thread(pool);
+		struct svc_client_pool *cp;
+		struct svc_client *cl;
+		struct llist_node *q;
+
+		q = lwq_dequeue_all(&pool->sp_clients);
+		while (q) {
+			cp = container_of(q, struct svc_client_pool, cp_ready.node);
+			q = q->next;
+			/* Deleting the last transport frees the client. */
+			cl = svc_client_get(cp->cp_client);
+			if (cl->cl_net == net || cl == serv->sv_anon_client)
+				svc_client_pool_clean(cp, net);
+			svc_client_pool_requeue(pool, cp);
+			svc_client_put(serv, cl);
 		}
+		svc_pool_wake_idle_thread(pool);
 	}
 }
 
-- 
2.53.0

