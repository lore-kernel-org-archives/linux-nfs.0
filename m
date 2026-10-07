Received: from mail-oo1-f43.google.com (mail-oo1-f43.google.com [209.85.161.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D32CA37F32D
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403190; cv=none; b=FUtcfFGmrVwj4Wyv8+nVjYdD4XlWqfFhXNDTLakNW8aD7cr6ev1B+D5Pe67HWhJUn5gytLJxSoyP8Nb2hIocPYogteqF5E2cscxJxMKzKBHWHbPZ5/M6KSSHx5Rq1LQEzdNlVzCzwLJ8avXtBDHXi767KOUV35lPI6MNsRfFaOA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403190; c=relaxed/simple;
	bh=loecUXXsYFkeWiRf9TOwlz7onjLqDUTh/DarvfQxAyE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JhxVhRPdbmtv/kvQ+X/vPyNs9nOqMfArHDISXXMldnijpErwtFkj0KQygyv4btyzedIL1ZXUZiks/nl5E2Q2wt7VpiRVCOBsaEZmVRymyvMKw3/SECmB8FHi54j0JzEsfOQw6XxuJ/hoNRFNbvw/LXHPDLg8Bubh5xy9elcRCYA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=JQvmDu84; arc=none smtp.client-ip=209.85.161.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="JQvmDu84"
Received: by mail-oo1-f43.google.com with SMTP id 006d021491bc7-6de1ca1b05aso1518831eaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403188; x=1792007988; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WcOvn26EZOk0zQ9+u6HfufVq1HUwiB8cekM2EcQEZHA=;
        b=JQvmDu84v0U+pIKE/bZY+EwLABjTO2/ryeoxCz9Qu0VA22Znq4FbszoZsQNCv/MR85
         ELIkVFQ4bQWvO6cqMkONd/NZPSIJNf37wjpEt+IP33BvvKWorXgal4nXmSyA01w1UmCM
         7gFRWMnFjdAKimP0hFMTAkjLSlnqymuZiPPkpa5p3iLhFH/zaPBI7RZjR2z7g0+r6FQk
         AAYkzmldxrXNBWLzc761u9aJ4BkU9ubsAIMXe/sV9RX7oe8q0SxY8D20Zr5+4mPLPoQT
         FE1AcmMGoOi6wzJKRc+KquuvEHVd7amlssf3YCYXox0nAVmn81NBjyYpkNG6gOkZOIOH
         JIBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403188; x=1792007988;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=WcOvn26EZOk0zQ9+u6HfufVq1HUwiB8cekM2EcQEZHA=;
        b=CUwnvXfe2J0S2io2Xej/bEoiU+Pq/wOB/imj2mByrzOdr8FraYOdsFqfrJGGbWFcXL
         NE44rFN3qVY6Rh8ZKHxlyDZR6cQ41/OuPQRvJIfKbTGMew9++NvWJKwce9sOYhOnm3kj
         Qhcqo5cz2AA0rWKjgtJHCKNdtxt4StYTf++qsG26CriRMW5QiCdTW0ch+4HocTVbvp8Q
         3lPf+O1WNzYP1P6y1CC36e0xJ6sRECzyFQ2/A3/0I5PQF52IU3iOM+GxzTF9J0j1orD2
         o7Wz79KSOwOeLbtGVDpOHml9hhZUctcmV0mz6MrGbVb6hDz6W6yE9MNb5vYuh6iyBY5r
         hW7A==
X-Gm-Message-State: AFuF++kXIUZfC+Rw55EyrRzE3hEY/QGbphtDzKW2rCguu8NG6ftxY60d
	GOe6jB0g+T1HvAqsMK2r3uhXuwRU4UVmsGtmC3xZHEmprd4WUgWBxODW32pIbwuXUC0=
X-Gm-Gg: AYBFou1D9i7qQt/BqsN94psPYUG/O9xVZ9YjrpvGafE7DHwsppEhDXmHM2bl1j2r01C
	slZUDbsFcYegauZFSl/bA4AyllzmlJsI80mEyvhcoRNlU6dFhWGgfr90hWONnPAIUIRpkCxuFbm
	zpnv8eS0joGnrXsmtkIMWidGeBUg/Q2VcTeOLc9hxsrdZfzExOkGr9NMztKf8/LtgcX1GDvJMDP
	x0mstKNDaiWKo+puZe+DT4VQZDa7rSbAGiiGJIgM0fiqKW7yeU1sQvxL3jfMxlqlM0MygovgXAK
	9wlUD3tENI+1L8Wvq+nDJP9onEP9TqUbfpLr3cFS9iSaQDWsYUVWEjhPC40C3zeLsQxIBE+4jVa
	Qi5MgQCjginYBJGzlelJ0sJRpDU8DPMPa4EJyUzTlJN5txXVPtWBw9wdWRqvFrYw/8bgHunri08
	VEmp0uLOON3xu79K0745U+aPK7jmuiAiEDlsPRFW1ZXcnTIciEhnpqnruW14EwKTgzh1p4GB1bw
	kNmMId/rDYi3VPvoHhZYSk5O2CmGKWPOlwc9dQ6Fnw=
X-Received: by 2002:a05:6820:7090:10b0:6d9:8fed:b732 with SMTP id 006d021491bc7-6e7a8bb924dmr2420950eaf.56.1791403187566;
        Wed, 07 Oct 2026 12:59:47 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:46 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 6/9] SUNRPC: keep the single transport queue while no classifier is attached
Date: Wed,  7 Oct 2026 15:59:31 -0400
Message-ID: <66560de3139aed32b820cef9921143edb5148777.1791402701.git.bcodding@hammerspace.com>
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

With no classifier attached every transport is on the anonymous client
and a pool's client queue holds one entry, so dispatch is in today's
order but takes one more lwq dequeue and a re-queue per request than
today's code.  That is about half a microsecond a dispatch on current
hardware, paid by every server whether or not it has asked for
anything.

Keep the pool's flat transport queue, sp_xprts, and use it while no
classifier is attached anywhere, switched by a static key that
attaching a classifier raises and detaching it drops.  The dispatcher
looks first at whichever queue is not in use, so transports queued
before a switch are served promptly after it and nothing is lost in
either direction; the thread's sleep test covers both queues, and
network namespace teardown cleans both.  With the key off the enqueue
and dequeue paths are today's, plus one empty test of the client queue
at dequeue.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 include/linux/sunrpc/svc.h      |  1 +
 include/linux/sunrpc/svc_xprt.h |  4 +++
 net/sunrpc/svc.c                |  1 +
 net/sunrpc/svc_classify.c       | 20 ++++++++++----
 net/sunrpc/svc_xprt.c           | 46 ++++++++++++++++++++++++++++++---
 5 files changed, 63 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 02a8eb5d3357..49c1cebe5702 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -38,6 +38,7 @@ struct svc_pool {
 	unsigned int		sp_nrthreads;	/* # of threads currently running in pool */
 	unsigned int		sp_nrthrmin;	/* Min number of threads to run per pool */
 	unsigned int		sp_nrthrmax;	/* Max requested number of threads in pool */
+	struct lwq		sp_xprts;	/* ready transports, no classifier */
 	struct lwq		sp_clients;	/* clients with ready transports */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct llist_head	sp_idle_threads; /* idle server threads */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index e05d7c8610ff..ef21b2e57b98 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@
 #ifndef SUNRPC_SVC_XPRT_H
 #define SUNRPC_SVC_XPRT_H
 
+#include <linux/jump_label.h>
 #include <linux/sunrpc/svc.h>
 
 struct module;
@@ -182,6 +183,9 @@ void	svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 			     bool unregister);
 void	svc_xprt_received(struct svc_xprt *xprt);
 
+/* Set while a classifier is attached anywhere: dispatch by client. */
+DECLARE_STATIC_KEY_FALSE(svc_classify_key);
+
 /* The class of an accepted transport; SVC_CLASS_* in svc.h. */
 #if IS_ENABLED(CONFIG_SUNRPC_BPF_CLASSIFY)
 u32	svc_classify(const struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 92c6737e5905..5f6a0fc06e66 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -478,6 +478,7 @@ __svc_create(struct svc_program *prog, int nprogs, struct svc_stat *stats,
 				i, serv->sv_name);
 
 		pool->sp_id = i;
+		lwq_init(&pool->sp_xprts);
 		lwq_init(&pool->sp_clients);
 		INIT_LIST_HEAD(&pool->sp_all_threads);
 		init_llist_head(&pool->sp_idle_threads);
diff --git a/net/sunrpc/svc_classify.c b/net/sunrpc/svc_classify.c
index aa63e0a3cb95..8d93d63157f5 100644
--- a/net/sunrpc/svc_classify.c
+++ b/net/sunrpc/svc_classify.c
@@ -36,16 +36,17 @@ u32 svc_classify(const struct svc_xprt *xprt)
 	return class;
 }
 
-/* Caller holds svc_classifier_lock. */
-static void svc_classifier_detach(struct svc_classifier *c)
+/* Caller holds svc_classifier_lock; the static key is dropped after. */
+static bool svc_classifier_detach(struct svc_classifier *c)
 {
 	struct sunrpc_net *sn;
 
 	if (!c->net)
-		return;
+		return false;
 	sn = net_generic(c->net, sunrpc_net_id);
 	RCU_INIT_POINTER(sn->svc_classifier, NULL);
 	c->net = NULL;
+	return true;
 }
 
 /**
@@ -58,13 +59,16 @@ void svc_classifier_exit_net(struct net *net)
 {
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	struct svc_classifier *c;
+	bool detached = false;
 
 	spin_lock(&svc_classifier_lock);
 	c = rcu_dereference_protected(sn->svc_classifier,
 				      lockdep_is_held(&svc_classifier_lock));
 	if (c)
-		svc_classifier_detach(c);
+		detached = svc_classifier_detach(c);
 	spin_unlock(&svc_classifier_lock);
+	if (detached)
+		static_branch_dec(&svc_classify_key);
 }
 
 static int svc_classifier_reg(void *kdata, struct bpf_link *link)
@@ -86,14 +90,20 @@ static int svc_classifier_reg(void *kdata, struct bpf_link *link)
 		rcu_assign_pointer(sn->svc_classifier, c);
 	}
 	spin_unlock(&svc_classifier_lock);
+	if (!err)
+		static_branch_inc(&svc_classify_key);
 	return err;
 }
 
 static void svc_classifier_unreg(void *kdata, struct bpf_link *link)
 {
+	bool detached;
+
 	spin_lock(&svc_classifier_lock);
-	svc_classifier_detach(kdata);
+	detached = svc_classifier_detach(kdata);
 	spin_unlock(&svc_classifier_lock);
+	if (detached)
+		static_branch_dec(&svc_classify_key);
 	synchronize_rcu();
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 14a7483886fc..e18fd20923cd 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -170,6 +170,8 @@ void svc_xprt_deferred_close(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_deferred_close);
 
+DEFINE_STATIC_KEY_FALSE(svc_classify_key);
+
 static unsigned int svc_client_hash(const struct net *net, u32 class,
 				    const struct sockaddr *sa)
 {
@@ -642,17 +644,22 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		return;
 
 	pool = svc_pool_for_cpu(xprt->xpt_server);
-	cp = &xprt->xpt_client->cl_pool[pool->sp_id];
 
 	percpu_counter_inc(&pool->sp_sockets_queued);
 	xprt->xpt_qtime = ktime_get();
+	if (!static_branch_unlikely(&svc_classify_key)) {
+		lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts);
+		goto wake;
+	}
+
+	cp = &xprt->xpt_client->cl_pool[pool->sp_id];
 	if (READ_ONCE(xprt->xpt_flags) & SVC_XPT_CTRL_EVENTS)
 		lwq_enqueue(&xprt->xpt_ready, &cp->cp_ctrl);
 	else
 		lwq_enqueue(&xprt->xpt_ready, &cp->cp_xprts);
 	if (!test_and_set_bit(SVC_CP_QUEUED, &cp->cp_flags))
 		lwq_enqueue(&cp->cp_ready, &pool->sp_clients);
-
+wake:
 	svc_pool_wake_idle_thread(pool);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
@@ -712,7 +719,7 @@ static struct svc_xprt *svc_client_pool_dequeue(struct svc_client_pool *cp)
  * Dequeue the next transport from the pool's client queue: one from the
  * client at the head, which then goes to the tail if it has more.
  */
-static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
+static struct svc_xprt *svc_client_dequeue(struct svc_pool *pool)
 {
 	struct svc_client_pool *cp;
 	struct svc_xprt	*xprt;
@@ -729,6 +736,36 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 	return xprt;
 }
 
+/*
+ * Dequeue the next transport.  Transports are queued flat on sp_xprts
+ * while no classifier is attached and by client otherwise; whichever
+ * queue is not in use is looked at first, so that what was queued
+ * before a switch is served promptly after it.
+ */
+static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
+{
+	struct svc_xprt	*xprt = NULL;
+
+	if (static_branch_unlikely(&svc_classify_key)) {
+		if (!lwq_empty(&pool->sp_xprts))
+			xprt = lwq_dequeue(&pool->sp_xprts, struct svc_xprt,
+					   xpt_ready);
+		if (xprt)
+			svc_xprt_get(xprt);
+		else
+			xprt = svc_client_dequeue(pool);
+		return xprt;
+	}
+	if (!lwq_empty(&pool->sp_clients))
+		xprt = svc_client_dequeue(pool);
+	if (!xprt) {
+		xprt = lwq_dequeue(&pool->sp_xprts, struct svc_xprt, xpt_ready);
+		if (xprt)
+			svc_xprt_get(xprt);
+	}
+	return xprt;
+}
+
 /**
  * svc_reserve - change the space reserved for the reply to a request.
  * @rqstp:  The request in question
@@ -952,7 +989,7 @@ svc_thread_should_sleep(struct svc_rqst *rqstp)
 		return false;
 
 	/* was a socket queued? */
-	if (!lwq_empty(&pool->sp_clients))
+	if (!lwq_empty(&pool->sp_xprts) || !lwq_empty(&pool->sp_clients))
 		return false;
 
 	/* are we shutting down? */
@@ -1441,6 +1478,7 @@ static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
 		struct svc_client *cl;
 		struct llist_node *q;
 
+		svc_xprt_lwq_clean(&pool->sp_xprts, net);
 		q = lwq_dequeue_all(&pool->sp_clients);
 		while (q) {
 			cp = container_of(q, struct svc_client_pool, cp_ready.node);
-- 
2.53.0

