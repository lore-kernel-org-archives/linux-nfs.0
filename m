Received: from mail-ed1-f99.google.com (mail-ed1-f99.google.com [209.85.208.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AE0F4DA548
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 20:45:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.99
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790282732; cv=none; b=nv/whk87BVFSKSz6IBsgVmvCpCeZvKXhjKo6dcXVhTfzNjBFrIzOBW8uEtlsCRC9S0h0gizR/pzc6oPFSv/vyHHaS5cWeckKpFaUWSxkmTJxZeWI9nu7eP3jDTlBUtZai9egkKJbV5jOpg8RFtr8/eNzh6Vvc25xmQHYFiRw9l4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790282732; c=relaxed/simple;
	bh=SQ61pMsL9cu3rsS6AuhP5gyJ0kLRVkZ2evR99Q7anzM=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=eBxTu5lj+mkn7WPYoyeLGRp334c+TTy2zh+cb4sbtvVhzaksLhxoafoNEn4mOzmOJXC1C0luJVeKsnD67Nelqyho54vYIR7jP9o/FqjLsP+0t/o7nuPedewOKqvu+iw2xjdUT8msCcQslSqnJnWpBwy9QSpVL3pH9t6pg8ilXSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=vvzkuR7W; arc=none smtp.client-ip=209.85.208.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="vvzkuR7W"
Received: by mail-ed1-f99.google.com with SMTP id 4fb4d7f45d1cf-6aa97edc48cso120979a12.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 13:45:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1790282727; x=1790887527; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=qRe+ei7knZtY8ctcL8LrqlkTZ019K5qeAeEFUbGMrhE=;
        b=vvzkuR7WU0OszCsi4Wgbo3Nb70uAyCt3qZ4Xm8fSdtr+k7I8UXyEZH4HPFGtzWv75Q
         OfhqmzPSBOqZNV0Kilul/eDqVvu/el/sCYTJmxVGf8cSjQyF25LYdDvVq8aewkpQmjEg
         tZ9wED952KLPagX82CGkRzzUP7Yn5arW2AZ+yy5gVYB/41M/VlTklrCjY+Cr94G8p5Or
         Wuk45Es0gf+anuHrZUjbvIy7DpxJSC3aKVjVK3mgjPudj97ikA/ppKlKZVxiwAlGeE10
         6mZ4kkD5TwEZZ2ulx1thrQajucTvt8KbI3pxT9JLH/tDH2sn7gQaL2G3ioNpcFzhSEdy
         UA3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790282727; x=1790887527;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=qRe+ei7knZtY8ctcL8LrqlkTZ019K5qeAeEFUbGMrhE=;
        b=v5oPj7iUonjYAlVywpHs8y1QHfQSQTeWBR5IvmLUMrRMXeEIdWYqLmMTqo1v8ed3RQ
         SBYkDYb05LEZcqlMKjSqVfOGOGE9KwGVC4OyOuv3Zz1JQI2TULY4wLRE4UKWK5/9ntR3
         SiMAs33fGSkUNlQTFdsogUqI2COwiuOBDtiLtBwEb3ZZAyYK93NrBsuEb6nv+pdQ0Clm
         XyXd7LIRZniS4XzZ6n2XPu0NJQc1cJzHkQc8Kz3uH6070G37eFXwJe/jRA24yMQIq3ol
         8rCPBJo1LETWG4cWdxiExN562fxQeIo22+0lQ40JGqVMwGMeHKr9poNLd031H90rXQZh
         sg2Q==
X-Forwarded-Encrypted: i=1; AKwUvBwrqdwvXvBmb8mjE4kcnwsUbUksKZY9TfVj0s788k7iaomWSYG0R3ybkJ21bQRZygxNQH/TVLK5ZN0=@vger.kernel.org
X-Gm-Message-State: AFuF++m5L/+JGsBrRgR7ZGWv23GwXe0+EMIMCoKakO8LINYkyGufJEZ9
	+3jhtiYN6oB/DvGgZzuFyUlMpWAx+/uMvkQUugEPTMVevS2iUAN8CRJpqA+P3s1hXL9xt7f7KGN
	JnlDzxS2gTMR57XlGQR3dCRr7qlfpXd7jO/xb
X-Gm-Gg: AYBFou3HalXcLKp2B2rnzwAhzUaiEw7v/HOcgaglO5wZ1ktNPVFK0TZuUc6Q/jZXrIS
	A//hFa4W1bRFxpuG55jR/h5edSJNOZNPAQIfayqU8ctVDwIKZ7+5VhbIwUWiwstrVWYKghBfB5w
	9Kua1w85nFjAmMtdN+VcEliZw437/0bsXJnwkY3CTrWaTLyAcpsHIXL9UxCHeQDmIgI3CV5lP7R
	SSjxeTuPVjqEJaQ2oLh+61LtM3eXUZyPbPhl1fi5KFiccDbnjqeCGC+VdC4tU1C7j1UTSUeOH1s
	MW8o0Oc/ri4hLxERj0WsEPByXB47yNlb5UKyNY/WvulmWCbZIXylNm+F88gED9GR+i1olKXtZ40
	wJgpaMKBvp28ExAKaJRyv3F1joYb8t78JQuQeYMI=
X-Received: by 2002:a05:6402:2b85:b0:6aa:9830:aa21 with SMTP id 4fb4d7f45d1cf-6aac8f8a446mr3400524a12.39.1790282727272;
        Thu, 24 Sep 2026 13:45:27 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 4fb4d7f45d1cf-6aae590e971sm148500a12.2.2026.09.24.13.45.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 13:45:27 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id A7370340290;
	Thu, 24 Sep 2026 13:45:25 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Shiva Lingappa <slingappa@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: [PATCH 1/2] SUNRPC: add request-scoped disconnects when cancelling tasks
Date: Thu, 24 Sep 2026 20:45:24 +0000
Message-Id: <20260924204525.3381590-2-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260924204525.3381590-1-tmenninger@everpuredata.com>
References: <20260924204525.3381590-1-tmenninger@everpuredata.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

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
index 0dbdf3722537..dbaad8b5f181 100644
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
index a82045804d34..617475f63561 100644
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
index 6cedc824cf82..5c33bf3fb4c3 100644
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
index e3c6e3b63f0b..2c0a4532891f 100644
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
index 48a3618cbb29..66eca8e4690b 100644
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
2.34.1

