Received: from mail-oo2-f39.google.com (mail-oo2-f39.google.com [74.125.231.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 615864EB859
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 16:43:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790959383; cv=none; b=Vjh0H78UPQ/IWEQFAaFo9AQ4OBGrZ5SU1ZJaXmNqY/CnyJDsj+zNXSF5f/2/mbZhj2YbmQLrCTNLdIaFrxkXYxHRBGHz4E7e+36pHM/GHBCFUI+pvBQjOHu5ZTs5wBfFMSupW8gyK4W1vFzTdyMHY1xbiBcCrcLcg86RHmk1uCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790959383; c=relaxed/simple;
	bh=h1AAWwqYom3nql0RZS95uKjA3EQW2TDjD51ipG8VBNw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=et3QtqVjejOAH6WMy1mIiJWRBXnXXHeNmyLsxKYGK2L0syitr6I0dOyJbDsvjGvkrtwPEBoPuys38KWoXLkJpcetsW2JuvesedyhfQ+6Um3cAoyamzDTl7GFnIQ7M5AUjrOi4QeB7fM88RSN1/egkN/PXOY8GgkV2FsYLJUgymY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fD5dAhb2; arc=none smtp.client-ip=74.125.231.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fD5dAhb2"
Received: by mail-oo2-f39.google.com with SMTP id 006d021491bc7-6e02c25fadcso51977eaf.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 09:43:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790959380; x=1791564180; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jTY6eTnqbY5Akq85K1Ulgk31e6VBn0ZwecxBO8+uCi0=;
        b=fD5dAhb2HCI94anZRjKbbspDMQAsbAFOUxZjQawQ4qda6vHg8rysfKV0HgNeKBUPCy
         to+BhfRWPYCyLak1Yp/9eg0hSEIv2zUxljoApZKLYbzF13JNETDPFXNvnbHmDAHh9+oN
         nhw9KoBe4l8EfaaZ3k3wSyOrYWqxMWRtji/qHtqbmXBqrCU9Mk6aTDN0WgfE57ZYLqeV
         sN1R5VxWTWXD3HjxFcLep4oBDt8QmTsJZGkOt+M6aH8YN66IhVTDcWePjP7s1HXuLNKV
         1jt+D/KfSZExXD5RFAXaiJKUEXPR5mIsokBN+uGYSivt+/+QxplDDQnVStamNxthmN4H
         EmmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790959380; x=1791564180;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jTY6eTnqbY5Akq85K1Ulgk31e6VBn0ZwecxBO8+uCi0=;
        b=zolXO/2ROv30w/ShcnKzG5Ner9nO9nijOcBuf8Go573fmjOClBb+xxg9n+AHRQu5xl
         tPLYtoA46KW3WrdnQspZyN/djWq2z1ogcNwzhdW+vaGnt+v3d833Yy6Kce8bnJaEE9Iy
         Wm7jcZgFlSpyEbys60JymIIxCuKTI+RjA0Dpp+WPCcoKA4hFK1nVLqwCQ0p9vR1ESTzy
         OBOr+I1sLyvmFonlB1LcWHJnp/XmWEW4nRjnzMFWsUfSs54MLA3ly0WydtM9XUJf4ZpI
         BwgQETkxsjNd4RD4mEaYOUYDS3+xEa33ix+vVO1AlC+YzmJqVCPYHeKf85icWYLzGYdm
         ZMMA==
X-Gm-Message-State: AFuF++mG7yWf1OtiiwVCsfGgpVbJ5uzLst1oiFFjzFo1vIsvsw6XdcY/
	2fc337V0z84TGqqPIdMvJQFSJYX2/El6AFKvUefrBnx6tz+b5yI1Pf4o+c9YrOL5pmY=
X-Gm-Gg: AYBFou0jT1UZrD79wf13PKV5km3jgC5zyu7AtIn1DW9y2iBV3mbAfsYTXqYh5a6DIF0
	nzbo6hLLaMAlCKlFnPWUll8T+1L/aAqQA4CVYp93fiGzXHiDVGfoGSafSuXirP50gm29QqLTEfu
	2JXfk98/230Ti3ExQcHOwdVWr8fEN6pXs8RDt5ETlDyJwPLlkHmh1HkEgmfDDd6dUqDuyykmHMK
	z5RgOh54oLxrhJZWS2VC0HRLQl1sx1OjJdVSdoy3LINM3qhtQ1bwGJPeXomkagHaSQZLb+Ctn+7
	lB4d4v1cD1Y+IzE2v06JyWOCEvbIy6THyYJg3iJ0Ay9KrAB4p63Dk+POwsM6ZDOvU4BfxoXG8gd
	yDHFOCssoPpNBZEssmogyR5IPw5I4TmsvkI2CBFLmWEa17HrviwrMBXGz2Asc56zo+Km7Gy9dAJ
	tzlFLHKc/V6JunjdFV8T9FVR/PbhWh/J6ryz/cLtykXqpKeV/TkDnCOfqeJxHwWv0guGnblwFo/
	C6hOcB9C+ZI124tHPnvA4cQlQhBSuWfwHvD9nJ7kOE8
X-Received: by 2002:a05:6820:824:b0:6dc:e1c3:b2ac with SMTP id 006d021491bc7-6df3505d176mr2522969eaf.73.1790959379717;
        Fri, 02 Oct 2026 09:42:59 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8227a66c6dfsm3238524a34.23.2026.10.02.09.42.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 09:42:59 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>
Subject: [PATCH RFC 2/2] SUNRPC: dispatch ready transports round-robin across clients
Date: Fri,  2 Oct 2026 12:42:55 -0400
Message-ID: <585e69cb24666b241a2b0af94d506d6f4797e50e.1790953694.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1790953694.git.bcodding@hammerspace.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A pool keeps its ready transports in one FIFO and serves one RPC per
turn, so a peer is served in proportion to how many of its connections
are backlogged.  A client with K connections, or a deep NFSv4.1 slot
table spread over nconnect transports, takes K turns for every one a
single-connection client gets, and the single-connection client's
latency grows with everyone else's connection count.

Queue ready transports on their client instead, and have the pool
dispatch round-robin across clients: take the client at the head of
the pool's client queue, dispatch one of its transports, and put the
client back at the tail if it has more.  Every peer with work queued
gets one dispatch per round however many connections it holds, and a
peer's wait is bounded by the number of busy peers rather than by the
number of busy connections.  Within a client, transports are still
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

Peers are told apart by address, so everything behind one address
(NAT, several users on one host) shares one client's turns.

Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h |  2 +-
 net/sunrpc/svc.c           |  2 +-
 net/sunrpc/svc_xprt.c      | 94 ++++++++++++++++++++++++++++++--------
 3 files changed, 76 insertions(+), 22 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 496fd33da96f..6b8d9292cfb8 100644
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
index 51753aeeb0ba..93cbbbc8b766 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -616,6 +616,7 @@ static bool svc_xprt_ready(struct svc_xprt *xprt)
  */
 void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
+	struct svc_client_pool *cp;
 	struct svc_pool *pool;
 
 	if (!svc_xprt_ready(xprt))
@@ -630,25 +631,55 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
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
 
@@ -875,7 +906,7 @@ svc_thread_should_sleep(struct svc_rqst *rqstp)
 		return false;
 
 	/* was a socket queued? */
-	if (!lwq_empty(&pool->sp_xprts))
+	if (!lwq_empty(&pool->sp_clients))
 		return false;
 
 	/* are we shutting down? */
@@ -1325,26 +1356,49 @@ static int svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, st
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
-
-		if (q && lwq_enqueue_batch(q, &pool->sp_xprts))
-			svc_pool_wake_idle_thread(pool);
+		svc_pool_wake_idle_thread(pool);
 	}
 }
 
-- 
2.53.0

