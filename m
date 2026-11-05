Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.97
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793848034;
	b=ldhq4PRav+mPweCzC532Fros7OWYPpWuoMBsopx1s1td96WUST6zbLjmj519A5E8K767
	 3ONSLBvyuLKMQgInlVDZno9XN92LRiFf19g4f2unWfs2UvphjxrDm0ajtqVgld+3dvKc/
	 SGp3XMjaiC5z1BnniWWAqXpMUXqzFcTrENnkZPxBvcZ1rFNStWLqOO4lzlZTrh2OTjwBH
	 YN+zNg8PHSuUYNzBiD92SDwF7qfrm14XYVxZCQ0j0Fn4PaH2xjpH36AyYgsYuowR/S5EA
	 kv7kBusw/a0fw5Ct0H76O+6zXKe9vh+ADa9DwSdL++fnr5MUaEOwUECTFatFZ4RgjOw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793848034;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=gofCgoStwL+GGmvkx772mdWpX9NH6aCBFh77V0tI1nk=;
	b=YnUAqWzdkYNmd+Wh1f6QmjPcJzL+VhLnwk90dBFH2APOjilvubmBxD09Wu0hYleffN07
	 lQSwXDnCFGNV+i/oR2gOr/JeSeco+aIf3RItc5szikndcCRH3K9sII/nKacdv328YnM5Q
	 GVpn9AWhWuyvHr1qSFX32BNxJm7giOukEh0sLIT9Qvw6yWWSfRr/a98kIjkJ7kF5VPgyZ
	 nKWqoQwQTVn8WI3mXk3v0ArdiwlI2OepaM65p/LgfsQEQhRZQ8X564TwCfsk7cg7v3BaR
	 ayAtgjR7sqSjhmb4G650xmBgVG1SW8sXZTIV9CO/F/GFAWSDMufMLKURGbXnVnYeF5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=an9lTztR;
	arc=none smtp.remote-ip=209.85.128.97
Received: from mail-wm1-f97.google.com (mail-wm1-f97.google.com [209.85.128.97])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C4BC606A330
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 03:07:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9C4BC606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=an9lTztR
Received: by mail-wm1-f97.google.com with SMTP id 5b1f17b1804b1-4afe2d546f9so15883735e9.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 19:07:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793848032; x=1794452832; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gofCgoStwL+GGmvkx772mdWpX9NH6aCBFh77V0tI1nk=;
        b=an9lTztRrSc8awuaGF7XSnJfGHMtpLoc/LpdJwS+6MezKB6Cx+0JkzH9dUjJkN5/8V
         OyNxbLdogCKoHIxRjUis/Sh34jLMiPu9Li6mSD0+nPh5QrdnZZkkEaX+fvU0AhFXsaDE
         JXgEsL+ljsc3XZSnaZuhHpFpyhVTO0VbGuJq0NnQxUQYAwS7FzGcSnUJ8wHmGuAFXCia
         QxTj25JnuztSIz8lSTiSOacTIZxBpkceDKlBS1a6KPMgsN5y74zSDaJerO7hXc3KL4qa
         WGCjcTTiAj1vcVWDS2pKtVXXsQN8uQBVMhYisZqCT1UUR8zMWAJxSCq5pqxrUKOmOi0N
         W7mw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793848032; x=1794452832;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=gofCgoStwL+GGmvkx772mdWpX9NH6aCBFh77V0tI1nk=;
        b=fmZfj9KUeJyV8dUBcDE2NOw0b2xINg7blAUd/kmViywY03YsgOeyK1MDg63ww10nJK
         zyhUSZZqzbXhGW4hA75PEpJEEjfmdLeDz4DtstxJ7nm9q5jtb74ujbMUcuh9Yoy0CPzU
         /fAekJkWEFioviPnjLu2Nin7lJqC9ufvcvaehTlnGKyD305oLxztz19PW11Pu8iitzA9
         UWNz/u7VZkC2Pv7BN0JNo0UjEXK+sPvZu+9B6XkHVvcpy03lMijyHqY7UW1SwgE5LSSl
         ynglgFnWx7gb0nW/ns0zbmM8lJRED2Zw/fep2G3jN7qdUnD8UqM/+r7e1DifCDuLyXcK
         uGpQ==
X-Forwarded-Encrypted: i=1; AKwUvBzm9SPqB7/NfhhFhv2+705gQirYarlMIw+JnNa0B83/254wZNp2CoSbQ1y23DlJxFJ7d5onzqgU1KA=@vger.kernel.org
X-Gm-Message-State: APuU4Z8YNXSTDe2fNJNSvQcqjMBoEV5P8ShM8CZY0sleIvGwKZ59odIp
	iupu6Odl6dHh+Y8UBFHADw2zNZReJbgFYOROqh1oq0awBBzi+9fJ3o9BtBmeXSeR3uhECOIUlgX
	QPF4ZHKhh2vo41szUfxzx07WH+wflw9NWfSWD
X-Gm-Gg: AYBFou1SrltkUCtrUHhLhl3iSXjovuucSWtaQuOy8RzzFvtxHp8uBdRImENVeb8lC1O
	GCGuKmLpS2rhbW40O4DD6MpDwzV5S0h9wYuxwCKe34qaNHLCibTDBf868B0aKb4Ssov26D+2mPp
	WfJa9bvir8/OwkmXLWiYndg5L+2lPiGtRpuNElLtUJBlN+WAqyDvxxv+iWwkLgtAedK0cm8S/Xe
	f6MSwkSKmfYpDylCAans5B7uqeJs6NYWWSvryYJUJOxt0XDjkIpdwNgbdgwry2g8ZeNPs74WwrJ
	/4sU9mUrApIyvQFVmGuenfRl1VNvlHWsZy6Ij4DFlq4xH2s4QL1rk8B9/Z+4mdo0WsnAVDTQaLi
	4zaLG8QwT44VEtSpZFUiBzlT6TsdqDQrGTi91/AA=
X-Received: by 2002:a05:600c:c48e:b0:4a3:2f35:38b4 with SMTP id 5b1f17b1804b1-4ac16bc4829mr402811145e9.10.1793848031815;
        Wed, 04 Nov 2026 19:07:11 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-4b573b15f60sm2391255e9.11.2026.11.04.19.07.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2026 19:07:11 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 198933406CC;
	Wed,  4 Nov 2026 19:07:10 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: [PATCH 2/2] SUNRPC: let cancelled RPC/RDMA requests drain before release
Date: Thu,  5 Nov 2026 03:07:09 +0000
Message-ID: <20261105030710.2652306-3-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261105030710.2652306-1-tmenninger@everpuredata.com>
References: <20261105030710.2652306-1-tmenninger@everpuredata.com>
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

During pNFS/flexfiles recovery, cancellation can release a posted
RPC/RDMA request before the server has finished accessing its Read or
Write chunks. xprt_rdma_free() can then invalidate advertised rkeys
while the peer still uses them. Resulting QP errors disrupt other RPCs
and can sustain a cancellation/reconnect loop after the data server
recovers. This was observed on Linux 6.8.0, 6.18.34, and 7.3-rc4.

Allow transports to defer exit of cancelled asynchronous tasks while
their requests can still complete normally. RPC/RDMA opts in while
registered MRs remain on the same live connection. Keep these requests
available for reply-driven cleanup, preserving the cancellation error
while wake callbacks process their transport status.

Use the existing request timeout and transport timer. After normal
no-reply timeout handling, finish cancellation instead of re-entering
draining. Suppress a requested conditional disconnect when the reply
completed before release. Synchronous and signalled tasks skip the
optional wait; remaining reclamation uses the existing release path.

Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 include/linux/sunrpc/xprt.h     |   3 +
 include/trace/events/sunrpc.h   |   1 +
 net/sunrpc/sched.c              |  21 +++++-
 net/sunrpc/xprt.c               | 129 +++++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/transport.c |  33 ++++++++
 5 files changed, 180 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ad8ecf8ccfb48..8b5b99ee34207 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -177,6 +177,7 @@ struct rpc_xprt_ops {
 	void		(*wait_for_reply_request)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*release_request)(struct rpc_task *task);
+	bool		(*release_needs_drain)(struct rpc_rqst *req);
 	void		(*close)(struct rpc_xprt *xprt);
 	void		(*destroy)(struct rpc_xprt *xprt);
 	void		(*set_connect_timeout)(struct rpc_xprt *xprt,
@@ -395,6 +396,8 @@ bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_transmit(struct rpc_task *task);
 int			xprt_request_enqueue_receive(struct rpc_task *task);
 void			xprt_request_wait_receive(struct rpc_task *task);
+bool			xprt_request_release_needs_wait(struct rpc_task *task);
+void			xprt_request_wait_for_drain(struct rpc_task *task);
 void			xprt_request_dequeue_xprt(struct rpc_task *task);
 bool			xprt_request_need_retransmit(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880de..263e8f6520ee3 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -410,6 +410,7 @@ DEFINE_RPC_RUNNING_EVENT(sync_wake);
 DEFINE_RPC_RUNNING_EVENT(complete);
 DEFINE_RPC_RUNNING_EVENT(timeout);
 DEFINE_RPC_RUNNING_EVENT(signalled);
+DEFINE_RPC_RUNNING_EVENT(exit_wait);
 DEFINE_RPC_RUNNING_EVENT(end);
 DEFINE_RPC_RUNNING_EVENT(call_done);
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 81890327d81a9..f1806f530fab7 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -932,6 +932,8 @@ static void __rpc_execute(struct rpc_task *task)
 	int task_is_async = RPC_IS_ASYNC(task);
 	int status = 0;
 	unsigned long pflags = current->flags;
+	bool task_draining;
+	s64 error_state;
 
 	WARN_ON_ONCE(RPC_IS_QUEUED(task));
 	if (RPC_IS_QUEUED(task))
@@ -939,6 +941,7 @@ static void __rpc_execute(struct rpc_task *task)
 
 	for (;;) {
 		void (*do_action)(struct rpc_task *);
+		task_draining = false;
 
 		/*
 		 * Perform the next FSM step or a pending callback.
@@ -949,8 +952,13 @@ static void __rpc_execute(struct rpc_task *task)
 		/* Tasks with an RPC error status should exit */
 		if (do_action && do_action != rpc_exit_task &&
 		    (status = rpc_task_rpc_status(task)) != 0) {
-			task->tk_status = status;
-			do_action = rpc_exit_task;
+			if (xprt_request_release_needs_wait(task)) {
+				task_draining = true;
+				do_action = xprt_request_wait_for_drain;
+			} else {
+				task->tk_status = status;
+				do_action = rpc_exit_task;
+			}
 		}
 		/* Callbacks override all actions */
 		if (task->tk_callback) {
@@ -989,8 +997,13 @@ static void __rpc_execute(struct rpc_task *task)
 			spin_unlock(&queue->lock);
 			continue;
 		}
-		/* Wake up any task that has an exit status */
-		if (rpc_task_rpc_status(task) != 0) {
+		/* Wake up any task that has an exit status. A task that has
+		 * deliberately gone to sleep to drain its request is exempted,
+		 * unless the task was signalled (i.e. urgently terminated).
+		 */
+		error_state = rpc_task_read_error_state(task);
+		if ((error_state & RPC_TASK_ERR_STATE_SIGNALLED) ||
+		    ((s32)error_state != 0 && !task_draining)) {
 			rpc_wake_up_task_queue_locked(queue, task);
 			spin_unlock(&queue->lock);
 			continue;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 66eca8e4690b6..cf24cb52667da 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1237,6 +1237,7 @@ static void xprt_timer(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
+	int status;
 
 	if (task->tk_status != -ETIMEDOUT)
 		return;
@@ -1245,6 +1246,13 @@ static void xprt_timer(struct rpc_task *task)
 	if (!req->rq_reply_bytes_recvd) {
 		if (xprt->ops->timer)
 			xprt->ops->timer(xprt, task);
+
+		/* An already-cancelled task should not drain again */
+		if (xprt->ops->release_needs_drain) {
+			status = rpc_task_rpc_status(task);
+			if (status)
+				rpc_exit(task, status);
+		}
 	} else
 		task->tk_status = 0;
 }
@@ -1528,6 +1536,114 @@ xprt_request_dequeue_xprt(struct rpc_task *task)
 	}
 }
 
+/**
+ * xprt_request_release_needs_wait - check whether request release must wait
+ * @task: RPC task being terminated
+ *
+ * Returns true if the request is pinned or its transport resources must
+ * drain before release. Removes pending transmissions when safe to do so.
+ *
+ * Context: Called from RPC task execution context. Acquires and releases
+ *          xprt->queue_lock. The transport's ->release_needs_drain() must not
+ *          sleep.
+ */
+bool xprt_request_release_needs_wait(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt;
+	bool defer = false;
+
+	if (!RPC_IS_ASYNC(task) || RPC_SIGNALLED(task))
+		return false;
+
+	if (!req)
+		return false;
+	xprt = req->rq_xprt;
+	if (!xprt->ops->release_needs_drain)
+		return false;
+
+	/* Has not been transmitted yet, no need to defer */
+	if (!test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate))
+		return false;
+
+	spin_lock(&xprt->queue_lock);
+	if (xprt_is_pinned_rqst(req))
+		defer = true;
+	else if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		xprt_request_dequeue_transmit_locked(task);
+	else
+		defer = xprt->ops->release_needs_drain(req);
+	spin_unlock(&xprt->queue_lock);
+
+	return defer;
+}
+
+/**
+ * xprt_request_wait_for_drain - wait until a failed request can be released
+ * @task: RPC task whose request may still be in flight
+ *
+ * Like xprt_request_wait_receive(), but for a task that has already
+ * been cancelled. The task keeps its request on the receive queue and
+ * sleeps on the pending queue until the reply arrives or the connection
+ * is lost. The wait is bounded by the request's retransmit timeout, at
+ * which point the transport's timer callback runs exactly as it would
+ * for an uncancelled request.
+ *
+ * Context: Called from RPC task execution context. May sleep while waiting
+ *          for a pinned request, with xprt->queue_lock released. Holds
+ *          queue_lock when checking request state and queuing the task.
+ */
+void xprt_request_wait_for_drain(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	trace_rpc_task_exit_wait(task, task->tk_action);
+
+	/*
+	 * Drop any send ownership handed to this task before waiting.
+	 */
+	xprt_release_write(xprt, task);
+
+	/*
+	 * Signals stop optional reply draining, but do not interrupt an
+	 * in-progress wait for request pins to be released.
+	 */
+	spin_lock(&xprt->queue_lock);
+	while (xprt_is_pinned_rqst(req) && !RPC_SIGNALLED(task)) {
+		set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+		spin_unlock(&xprt->queue_lock);
+		xprt_wait_on_pinned_rqst(req);
+		spin_lock(&xprt->queue_lock);
+		clear_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+	}
+
+	if (xprt_is_pinned_rqst(req) || RPC_SIGNALLED(task))
+		goto out_unlock;
+
+	/*
+	 * The pinned operation may have completed or failed while we waited.
+	 * Recheck whether the request needs to drain or can be dequeued.
+	 */
+	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		xprt_request_dequeue_transmit_locked(task);
+	} else if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) &&
+		   xprt->ops->release_needs_drain(req) &&
+		   !RPC_SIGNALLED(task)) {
+		rpc_sleep_on_timeout(&xprt->pending, task, xprt_timer,
+				     xprt_request_timeout(req));
+
+		if (RPC_SIGNALLED(task))
+			rpc_wake_up_queued_task(&xprt->pending, task);
+		else if (xprt_request_retransmit_after_disconnect(task))
+			rpc_wake_up_queued_task_set_status(&xprt->pending, task,
+							   -ENOTCONN);
+	}
+
+out_unlock:
+	spin_unlock(&xprt->queue_lock);
+}
+
 /**
  * xprt_request_prepare - prepare an encoded request for transport
  * @req: pointer to rpc_rqst
@@ -1609,11 +1725,13 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 	unsigned int connect_cookie;
 	int is_retrans = RPC_WAS_SENT(task);
 	int status;
+	s64 error_state;
 
 	if (test_bit(XPRT_CLOSE_WAIT, &xprt->state))
 		return -ENOTCONN;
 
 	if (!req->rq_bytes_sent) {
+		error_state = rpc_task_read_error_state(task);
 		if (xprt_request_data_received(task)) {
 			status = 0;
 			goto out_dequeue;
@@ -1623,10 +1741,14 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 			status = -EBADMSG;
 			goto out_dequeue;
 		}
-		if (RPC_SIGNALLED(task)) {
+		if (error_state & RPC_TASK_ERR_STATE_SIGNALLED) {
 			status = -ERESTARTSYS;
 			goto out_dequeue;
 		}
+		if (xprt->ops->release_needs_drain && (s32)error_state != 0) {
+			status = -ECANCELED;
+			goto out_dequeue;
+		}
 	}
 
 	/*
@@ -1695,7 +1817,7 @@ xprt_transmit(struct rpc_task *task)
 		xprt_pin_rqst(next);
 		spin_unlock(&xprt->queue_lock);
 		status = xprt_request_transmit(next, task);
-		if (status == -EBADMSG && next != req)
+		if ((status == -EBADMSG || status == -ECANCELED) && next != req)
 			status = 0;
 		spin_lock(&xprt->queue_lock);
 		xprt_unpin_rqst(next);
@@ -2061,7 +2183,8 @@ void xprt_release(struct rpc_task *task)
 	req->rq_disconnect_on_release = false;
 	spin_unlock(&xprt->queue_lock);
 
-	if (unlikely(disconnect && req->rq_ntrans > 0))
+	if (unlikely(disconnect && req->rq_ntrans > 0 &&
+		     !(xprt->ops->release_needs_drain && req->rq_reply_bytes_recvd)))
 		xprt_conditional_disconnect(xprt, req->rq_connect_cookie);
 
 	spin_lock(&xprt->transport_lock);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e38637c2ec787..ed521d9aa8953 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -434,6 +434,35 @@ xprt_rdma_timer(struct rpc_xprt *xprt, struct rpc_task *task)
 	xprt_force_disconnect(xprt);
 }
 
+/**
+ * xprt_rdma_release_needs_drain - decide whether a cancelled request must drain
+ * @rqst: transmitted RPC request whose task has been cancelled
+ *
+ * A Call posted on the current connection may have advertised chunks that the
+ * server is still reading or writing. Invalidating those MRs before the Reply
+ * arrives provokes a remote access error that tears down the QP. Keep a
+ * cancelled request available for reply-driven MR cleanup while its connection
+ * remains live. A false result leaves any remaining reclamation to the normal
+ * release path.
+ *
+ * Context: Called with xprt->queue_lock held and @rqst unpinned.
+ *          Must not sleep.
+ *
+ * Returns true if @rqst still has registered memory on the current connection.
+ */
+static bool
+xprt_rdma_release_needs_drain(struct rpc_rqst *rqst)
+{
+	struct rpc_xprt *xprt = rqst->rq_xprt;
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+
+	if (!xprt_connected(xprt) ||
+	    rqst->rq_connect_cookie != READ_ONCE(xprt->connect_cookie))
+		return false;
+
+	return !list_empty(&req->rl_registered);
+}
+
 /**
  * xprt_rdma_set_connect_timeout - set timeouts for establishing a connection
  * @xprt: controlling transport instance
@@ -655,6 +684,9 @@ xprt_rdma_free(struct rpc_task *task)
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 
+	/* Graceful draining can be skipped or end before all MRs are reclaimed.
+	 * Complete any remaining cleanup through the normal release path.
+	 */
 	if (unlikely(!list_empty(&req->rl_registered))) {
 		trace_xprtrdma_mrs_zap(task);
 		frwr_unmap_sync(rpcx_to_rdmax(rqst->rq_xprt), req);
@@ -795,6 +827,7 @@ static const struct rpc_xprt_ops xprt_rdma_procs = {
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.wait_for_reply_request	= xprt_wait_for_reply_request_def, /* ditto */
 	.timer			= xprt_rdma_timer,
+	.release_needs_drain	= xprt_rdma_release_needs_drain,
 	.rpcbind		= rpcb_getport_async,	/* sunrpc/rpcb_clnt.c */
 	.set_port		= xprt_rdma_set_port,
 	.connect		= xprt_rdma_connect,
-- 
2.53.0

