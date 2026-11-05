Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793844173;
	b=GA0Ud6gj30PVefTCbJMC7r4VpJuDApVY6V89EqSs2+g+/Zv83QcebHHmxpzKQ8/xzDvz
	 3dodwT9vTTkXIhz+qJOwsmETn1UFF1waS+YwZRQHtnlYPrILipqlOptyUedwODO+Dzt+Q
	 s56QyUGMJR7pJ3LKeHAYm8jdybwTnjecETGk88UFCm4vdygvHA8mcfbVtx/dkIRvmylhF
	 Hb463TP9W616HWQwiwrq68Tx28S64P9b21L1g7aRGLc5efXs0qPx2f2pKzb1LvCQ9qjMj
	 /Ongyqn2lFEQPd0B9+JfUguj0Fuc/j/xyMokUyzEpsqWNY+svwE1jHb7g9AwNauyaUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793844173;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=CIdaIZY8z1tsS2yki6WybLw4WOCkZmeRMYggi7nZ5LE=;
	b=pOZumXS3XA8aeyl2oFfVY3onz2dhiJvT9hTeQAQ4KAuvkJochVJ41BtAFTpAaZ5uo4lF
	 cowShSmE0ZwFQBXmD4IyjSd5PpqUVN6IWzUSrbg20/XGA+oYXFEifb/R9CifSSvekt7EX
	 AUOAEyjIJp4og3cB+F2q4ofmOY6MMJQJh4Nh7FUiSNwsSEcS+SEFQuH0ZB0tg3jzFsI4q
	 3JuRqWXHdrQWRGPW9XGTULTMnJBYfkxN4z5OoMuUKvZK7Ct/tO1oxHnEpJ52r2VGy8M2d
	 zkmueaUs8p0PAOOZMaqAjLvaTWt8jEd1ujdbOdmARWy+kXmQU/C7DAL9x3MZmlT/Rig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=purestorage.com;
	spf=pass smtp.mailfrom=purestorage.com;
	dkim=pass header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b="Wx9W/u52";
	arc=none smtp.remote-ip=209.85.222.227
Received: from mail-qk1-f227.google.com (mail-qk1-f227.google.com [209.85.222.227])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BECD606D82E
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 02:02:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4BECD606D82E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=Wx9W/u52
Received: by mail-qk1-f227.google.com with SMTP id af79cd13be357-93e503815adso122393385a.1
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 18:02:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1793844171; x=1794448971; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=CIdaIZY8z1tsS2yki6WybLw4WOCkZmeRMYggi7nZ5LE=;
        b=Wx9W/u52eNsR6V7JToB8Fjt8rdRg4XubbRH2hUXxzToYObqjL5ZldsaGPkE6Y/i2U0
         0EnSkNM/Kg8CGd33sFCwE3KgJA+df1aOWOs7meiJWaUUImpCrgYLNO3vmSzDjJNlqvLX
         zrrglk2XVauJkAxnO1DkCzrbUIzzphT/tEQG+BClADI20eg+7Fhz6IX96Nmcqwfs95NG
         7c7rApzcnBq3tghfF3tOTV8aSyUrekd39vkDNkfO80nH+KWiBLVU/44le4WzFE0MLJqG
         Fw5ZrbZgHjFY/dyEBaIaDqJHikA6c1BIoOAlPRTk3Saa7eJbIusEZo8i/TqqM6bfL7fq
         3AqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793844171; x=1794448971;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=CIdaIZY8z1tsS2yki6WybLw4WOCkZmeRMYggi7nZ5LE=;
        b=esQfV2AACHNo00YvsaLA0eJjM8yquYKmdGiLkIdSH8KUu31pSTUMcEsPIeDhNqw3tC
         ZUsxvmAI4tGL7z9rar0lzVLIhOpoRPA7ShAqpRsTz6+8B4sXFcqiOEYSSuoglsjAeL32
         H/zL5IxE67Gu52LXZz0K9atIjid/dQ7PWHNPe8X03BYPMSbpeXcWPZ8SeB7msyDfTeCj
         qlcqMeA7qXF04JTMTtchs9R+++buX10KPRNdWZbgKy9AzGHao+MtAUazLKF8EzeJPqbz
         7njeg8YhachMCLRnlihYCH1I/a4PhZk4acQJWEXxeSsWiZhgJuvkCQPDR5PLMmS9ZYTV
         VSnA==
X-Forwarded-Encrypted: i=1; AKwUvBxxkOqWtYqmuuc8IBobA2zVp1JNtC4x4rJgEqtj930xrQw1IAhCZLAkOqf97U07TIkGutXg49g3YTk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/zjajkcOz6GZ0hNKtz0UCmrVlfcGCGqhkpGV3GnmqBRJ9/4UNZ
	FDweaFgS5P4SdATBDToq5Lpjs95eo6t7LOeU5BXujZMdlYBC3ZL8XDO1g4JXwOuUhyC1bqoX7S7
	znCUrSfyeO0xl5kTHHuwWWHhB3KH4CSnQcAqV
X-Gm-Gg: AYBFou3DA3RB0vS6BfV6BjH3H7ACR1I9G6iFncgityPb6eXduSt7g449R4Mcvt8lZVx
	w9DOM7F3+cng/4ua9YnDHigClslgvZrWc5ocTTrfbfq3Cof6FfyBMM7Y6N9wlUN8jY7GHHaatZz
	k55dEzuEhXABTCX5bMWOkvuFJHe0oGHOKLd1EUsP7dWANc7F2tou9CFjFNVsBRWNN09KStneAkU
	LVHTmyKBSZSGitxHLCPT5O9uQYcbqk3wvo818xQ7uDHHaTS3wIHytSUEROqiEEGERtcJxRa3QgV
	IeHb04TNObj1/aYEgffMenT87UcXxQh3jlOSKkwPOKr28jXItE/3VRFEu+SD8NIr7bXZmxaNDvV
	O4d0GZdZwJLIldRs2nbU/OZoIHgtbYNQFVaNquA==
X-Received: by 2002:a05:620a:2849:b0:93e:95ce:53c7 with SMTP id af79cd13be357-9442156aaa8mr3050098185a.4.1793844171167;
        Wed, 04 Nov 2026 18:02:51 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id af79cd13be357-945d47853ddsm45440085a.8.2026.11.04.18.02.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2026 18:02:51 -0800 (PST)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 9B7DA3401C8;
	Wed,  4 Nov 2026 18:02:49 -0800 (PST)
From: tmenninger@purestorage.com
To: anna@kernel.org,
	trondmy@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com,
	Tim Menninger <tmenninger@everpuredata.com>
Subject: [PATCH v2 1/2] SUNRPC: add request-scoped disconnects when cancelling tasks
Date: Thu,  5 Nov 2026 02:02:48 +0000
Message-ID: <20261105020249.2607367-2-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261105020249.2607367-1-tmenninger@purestorage.com>
References: <20261105020249.2607367-1-tmenninger@purestorage.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Tim Menninger <tmenninger@everpuredata.com>

rpc_cancel_tasks() allows callers to cancel a selected set of RPC tasks,
but callers that also need to tear down the connection currently have to
disconnect at the rpc_clnt level.

That is broader than necessary for clients with multiple transports. A
cancelled request is associated with a specific rpc_xprt and records the
connection generation on which it was transmitted in rq_connect_cookie.

Add rpc_cancel_tasks_and_disconnect() to cancel matching tasks and mark
matching requests that remain on the transport transmit or receive queues
for conditional transport disconnect when the request is released.

Store the disconnect indication in struct rpc_rqst rather than struct
rpc_task. An RPC task can release one request and later acquire another,
so task-scoped state could otherwise be consumed by a successor request
and disconnect the wrong transport generation.

After cancelling matching tasks, walk the client's transports and mark
matching requests belonging to that client that remain on the transmit
or receive queues. An rpc_xprt may be shared by multiple rpc_clnt
instances, so requests belonging to other clients are left untouched.

When a marked request is released, use xprt_conditional_disconnect() with
its saved rq_connect_cookie. This disconnects the transport only if it is
still using the same connection generation on which the request was sent,
and leaves a replacement connection untouched.

Requests that were never transmitted do not require a disconnect.

Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 include/linux/sunrpc/sched.h |  4 ++
 include/linux/sunrpc/xprt.h  |  5 ++
 net/sunrpc/clnt.c            | 94 +++++++++++++++++++++++++++++-------
 net/sunrpc/sunrpc.h          |  5 ++
 net/sunrpc/xprt.c            | 76 +++++++++++++++++++++++++++++
 5 files changed, 167 insertions(+), 17 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0dbdf3722537f..dbaad8b5f181c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -230,6 +230,10 @@ unsigned long	rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
 				 bool (*fnmatch)(const struct rpc_task *,
 						 const void *),
 				 const void *data);
+unsigned long	rpc_cancel_tasks_and_disconnect(struct rpc_clnt *clnt, int error,
+						bool (*fnmatch)(const struct rpc_task *,
+								const void *),
+						const void *data);
 void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 005730623f3be..ad8ecf8ccfb48 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -112,6 +112,11 @@ struct rpc_rqst {
 
 	ktime_t			rq_xtime;	/* transmit time stamp */
 	int			rq_ntrans;
+	bool                    rq_disconnect_on_release;
+						/*
+						 * protected by rq_xprt->queue_lock
+						 * while the request is active
+						 */
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct lwq_node		rq_bc_list;	/* Callback service list */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf826..5c33bf3fb4c34 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -901,29 +901,36 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_killall_tasks);
 
-/**
- * rpc_cancel_tasks - try to cancel a set of RPC tasks
- * @clnt: Pointer to RPC client
- * @error: RPC task error value to set
- * @fnmatch: Pointer to selector function
- * @data: User data
- *
- * Uses @fnmatch to define a set of RPC tasks that are to be cancelled.
- * The argument @error must be a negative error value.
- */
-unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
-			       bool (*fnmatch)(const struct rpc_task *,
-					       const void *),
-			       const void *data)
+struct rpc_cancel_disconnect_ctx {
+	bool (*fnmatch)(const struct rpc_task *task, const void *data);
+	const void *data;
+};
+
+static int rpc_mark_xprt_disconnect_on_release(struct rpc_clnt *clnt,
+					       struct rpc_xprt *xprt,
+					       void *arg)
+{
+	struct rpc_cancel_disconnect_ctx *ctx = arg;
+
+	xprt_mark_matching_reqs_disconnect_on_release(xprt, clnt,
+						      ctx->fnmatch,
+						      ctx->data);
+	return 0;
+}
+
+static unsigned long
+__rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
+		   bool (*fnmatch)(const struct rpc_task *,
+				   const void *),
+		   const void *data,
+		   bool disconnect)
 {
 	struct rpc_task *task;
 	unsigned long count = 0;
 
 	if (list_empty(&clnt->cl_tasks))
 		return 0;
-	/*
-	 * Spin lock all_tasks to prevent changes...
-	 */
+
 	spin_lock(&clnt->cl_lock);
 	list_for_each_entry(task, &clnt->cl_tasks, tk_task) {
 		if (!RPC_IS_ACTIVATED(task))
@@ -934,10 +941,63 @@ unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
 		count++;
 	}
 	spin_unlock(&clnt->cl_lock);
+
+	if (disconnect && count) {
+		struct rpc_cancel_disconnect_ctx ctx = {
+			.fnmatch = fnmatch,
+			.data = data,
+		};
+		rpc_clnt_iterate_for_each_xprt(clnt,
+					       rpc_mark_xprt_disconnect_on_release,
+					       &ctx);
+	}
 	return count;
 }
+
+/**
+ * rpc_cancel_tasks - try to cancel a set of RPC tasks
+ * @clnt: Pointer to RPC client
+ * @error: RPC task error value to set
+ * @fnmatch: Pointer to selector function
+ * @data: User data
+ *
+ * Uses @fnmatch to define a set of RPC tasks that are to be cancelled.
+ * The argument @error must be a negative error value.
+ */
+unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
+			       bool (*fnmatch)(const struct rpc_task *,
+					       const void *),
+			       const void *data)
+{
+	return __rpc_cancel_tasks(clnt, error, fnmatch, data, false);
+}
 EXPORT_SYMBOL_GPL(rpc_cancel_tasks);
 
+/**
+ * rpc_cancel_tasks_and_disconnect - cancel matching RPC tasks
+ * @clnt: Pointer to RPC client
+ * @error: RPC task error value to set
+ * @fnmatch: Pointer to selector function
+ * @data: User data
+ *
+ * Like rpc_cancel_tasks(), but after cancelling matching tasks, marks
+ * matching in-flight requests so that xprt_release() conditionally
+ * disconnects the connection generation on which each request was sent.
+ *
+ * @fnmatch is called while holding spinlocks and must not sleep.
+ *
+ * Returns the number of active tasks matched by @fnmatch.
+ */
+unsigned long
+rpc_cancel_tasks_and_disconnect(struct rpc_clnt *clnt, int error,
+				bool (*fnmatch)(const struct rpc_task *,
+						const void *),
+				const void *data)
+{
+	return __rpc_cancel_tasks(clnt, error, fnmatch, data, true);
+}
+EXPORT_SYMBOL_GPL(rpc_cancel_tasks_and_disconnect);
+
 static int rpc_clnt_disconnect_xprt(struct rpc_clnt *clnt,
 				    struct rpc_xprt *xprt, void *dummy)
 {
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index e3c6e3b63f0ba..2c0a4532891f0 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -43,4 +43,9 @@ void rpc_clients_notifier_unregister(void);
 void auth_domain_cleanup(void);
 void svc_sock_update_bufs(struct svc_serv *serv);
 enum svc_auth_status svc_authenticate(struct svc_rqst *rqstp);
+void xprt_mark_matching_reqs_disconnect_on_release(struct rpc_xprt *xprt,
+						   const struct rpc_clnt *clnt,
+						   bool (*fnmatch)(const struct rpc_task *,
+								   const void *),
+						   const void *data);
 #endif /* _NET_SUNRPC_SUNRPC_H */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48a3618cbb29f..66eca8e4690b6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1434,6 +1434,69 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+static bool
+xprt_request_matches(const struct rpc_rqst *req,
+		     const struct rpc_clnt *clnt,
+		     bool (*fnmatch)(const struct rpc_task *, const void *),
+		     const void *data)
+{
+	const struct rpc_task *task = req->rq_task;
+
+	return task && task->tk_client == clnt && fnmatch(task, data);
+}
+
+/**
+ * xprt_mark_matching_reqs_disconnect_on_release - mark matching in-flight
+ *                                     requests for connection-generation
+ *                                     teardown at release
+ * @xprt: transport whose queues to walk
+ * @clnt: RPC client whose requests are eligible
+ * @fnmatch: selector called with the request's owning rpc_task
+ * @data: caller data forwarded to @fnmatch
+ *
+ * @fnmatch must not sleep and must be safe to call while xprt->queue_lock
+ * is held.
+ *
+ * Walks the transmit queue (including per-owner rq_xmit2 chains) and the
+ * receive tree under xprt->queue_lock and marks each matching rpc_rqst so
+ * that xprt_release() will call xprt_conditional_disconnect() against that
+ * request's snapshotted rq_connect_cookie. Requests remain eligible for marking
+ * while they are present on a transport queue. xprt_release() removes queue
+ * membership under xprt->queue_lock before consuming the marker, so a marker
+ * installed before dequeue remains associated with that rpc_rqst and cannot be
+ * inherited by a later request using the same rpc_task.
+ *
+ * The @clnt qualification preserves the selection domain of
+ * rpc_cancel_tasks(). An rpc_xprt may be shared by multiple rpc_clnt
+ * instances, so requests belonging to other clients must not be marked.
+ */
+void
+xprt_mark_matching_reqs_disconnect_on_release(struct rpc_xprt *xprt,
+					      const struct rpc_clnt *clnt,
+					      bool (*fnmatch)(const struct rpc_task *,
+							      const void *),
+					      const void *data)
+{
+	struct rpc_rqst *req, *pos;
+	struct rb_node *n;
+
+	spin_lock(&xprt->queue_lock);
+	list_for_each_entry(req, &xprt->xmit_queue, rq_xmit) {
+		if (xprt_request_matches(req, clnt, fnmatch, data))
+			req->rq_disconnect_on_release = true;
+		list_for_each_entry(pos, &req->rq_xmit2, rq_xmit2) {
+			if (xprt_request_matches(pos, clnt, fnmatch, data))
+				pos->rq_disconnect_on_release = true;
+		}
+	}
+	for (n = rb_first(&xprt->recv_queue); n; n = rb_next(n)) {
+		req = rb_entry(n, struct rpc_rqst, rq_recv);
+		if (xprt_request_matches(req, clnt, fnmatch, data))
+			req->rq_disconnect_on_release = true;
+	}
+	spin_unlock(&xprt->queue_lock);
+}
+
 /**
  * xprt_request_dequeue_xprt - remove a task from the transmit+receive queue
  * @task: pointer to rpc_task
@@ -1915,6 +1978,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
 	req->rq_seqno_count = 0;
+	req->rq_disconnect_on_release = false;
 	xprt_init_majortimeo(task, req, task->tk_client->cl_timeout);
 
 	trace_xprt_reserve(req);
@@ -1979,6 +2043,7 @@ void xprt_release(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req = task->tk_rqstp;
+	bool disconnect;
 
 	if (req == NULL) {
 		if (task->tk_client) {
@@ -1990,12 +2055,22 @@ void xprt_release(struct rpc_task *task)
 
 	xprt = req->rq_xprt;
 	xprt_request_dequeue_xprt(task);
+
+	spin_lock(&xprt->queue_lock);
+	disconnect = req->rq_disconnect_on_release;
+	req->rq_disconnect_on_release = false;
+	spin_unlock(&xprt->queue_lock);
+
+	if (unlikely(disconnect && req->rq_ntrans > 0))
+		xprt_conditional_disconnect(xprt, req->rq_connect_cookie);
+
 	spin_lock(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
 		xprt->ops->release_request(task);
 	xprt_schedule_autodisconnect(xprt);
 	spin_unlock(&xprt->transport_lock);
+
 	if (req->rq_buffer)
 		xprt->ops->buf_free(task);
 	if (req->rq_cred != NULL)
@@ -2020,6 +2095,7 @@ xprt_init_bc_request(struct rpc_rqst *req, struct rpc_task *task,
 	task->tk_rqstp = req;
 	req->rq_task = task;
 	xprt_init_connect_cookie(req, req->rq_xprt);
+	req->rq_disconnect_on_release = false;
 	/*
 	 * Set up the xdr_buf length.
 	 * This also indicates that the buffer is XDR encoded already.
-- 
2.53.0

