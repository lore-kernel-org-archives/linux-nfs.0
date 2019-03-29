Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02389C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C40062184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="giqSYcal"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730352AbfC2WCJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:09 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:38952 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730303AbfC2WCI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:08 -0400
Received: by mail-it1-f193.google.com with SMTP id 139so6260480ita.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9TX7g4S7xzkondKf38t9AGk7m6l2VTWuVMxzRXlwvv0=;
        b=giqSYcalq0wcqxN9U3W5whRGLlApBTUtzWMtDmCxEuoLPzYmNPLrqQguKHVC5ahXtr
         CEY5Ne7zCAiv1OFy40eUA6YV694n7taOZRmFS6fPS2oT713iEtbGFoHjx/7qM0TUFNAo
         cL3QL6LyHSj524th/ttwi1sYdGRalpnA9BeyX0IUBcJ4ixK55byfDQoDK2p0BvXoaHbo
         smVjhT3gvvAd6gq93LqjVka6v+4bzIgMbsVRv38uHcxzas87rW6eQe9q++SdYbKS1QjN
         AShrts9fqt7F8ug0CKxOCdJWIG0Rq3+uzAPW72YzT+zn5BkJJvdMGGDBePLgx0Y5wzVb
         Xavg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=9TX7g4S7xzkondKf38t9AGk7m6l2VTWuVMxzRXlwvv0=;
        b=UfJSXPUkMJJT3/VUhQRqJblR7GwZOfWNBzOp4EF84GJtsIvT3xOyrJbUiUdCsMrBYU
         /A0juO2GhB1VNYi6MINBwMRJ5HI5PJu2Zym06VhDnwdFFGvIa11cGLcRrVx/m4ux7OSc
         QyW5KF1NHIRvZaJXG1J7sH+ZE2c92/kdXamhv11TrgNwKW5EeFF9fsKiH1yTfr6mlkOF
         hFijx60dVvDmin+NgUtIbkK5Ei8Fisi2rbAcgrhNTBi5Rm5KTvCwbaFj/w7Us2I5jNSl
         TGk6N2x30scKaGUOSgornnhp/B4HuBOi1SzmkrX1j/IkTd3d/RlQS57xhg7kO+b92GMi
         q0VQ==
X-Gm-Message-State: APjAAAVAO1dIYfGmEzSDEqDEAWX6LA6aSuKugp4rKCCs3hz78ukp4/Ay
        l+Hu5VZhbgArzZIW8KkQ0fNqsMI=
X-Google-Smtp-Source: APXvYqwanYtLd2cBoT7SxfMBUzt8fOMoCvh+27QLTZamsFRZ4FiK2GGoYccOgJaWfs0OXylBx05h6w==
X-Received: by 2002:a02:40c8:: with SMTP id n191mr12203625jaa.14.1553896926958;
        Fri, 29 Mar 2019 15:02:06 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.06
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:06 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 13/28] SUNRPC: Start the first major timeout calculation at task creation
Date:   Fri, 29 Mar 2019 17:59:33 -0400
Message-Id: <20190329215948.107328-14-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-13-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When calculating the major timeout for a new task, when we know that the
connection has been broken, use the task->tk_start to ensure that we also
take into account the time spent waiting for a slot or session slot. This
ensures that we fail over soft requests relatively quickly once the
connection has actually been broken, and the first requests have
started to fail.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 44 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 642cc0f64e44..bc1c8247750d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -569,18 +569,44 @@ bool xprt_write_space(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_write_space);
 
-static void xprt_reset_majortimeo(struct rpc_rqst *req)
+static unsigned long xprt_abs_ktime_to_jiffies(ktime_t abstime)
+{
+	s64 delta = ktime_to_ns(ktime_get() - abstime);
+	return likely(delta >= 0) ?
+		jiffies - nsecs_to_jiffies(delta) :
+		jiffies + nsecs_to_jiffies(-delta);
+}
+
+static unsigned long xprt_calc_majortimeo(struct rpc_rqst *req)
 {
 	const struct rpc_timeout *to = req->rq_task->tk_client->cl_timeout;
+	unsigned long majortimeo = req->rq_timeout;
 
-	req->rq_majortimeo = req->rq_timeout;
 	if (to->to_exponential)
-		req->rq_majortimeo <<= to->to_retries;
+		majortimeo <<= to->to_retries;
+	else
+		majortimeo += to->to_increment * to->to_retries;
+	if (majortimeo > to->to_maxval || majortimeo == 0)
+		majortimeo = to->to_maxval;
+	return majortimeo;
+}
+
+static void xprt_reset_majortimeo(struct rpc_rqst *req)
+{
+	req->rq_majortimeo += xprt_calc_majortimeo(req);
+}
+
+static void xprt_init_majortimeo(struct rpc_task *task, struct rpc_rqst *req)
+{
+	unsigned long time_init;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (likely(xprt && xprt_connected(xprt)))
+		time_init = jiffies;
 	else
-		req->rq_majortimeo += to->to_increment * to->to_retries;
-	if (req->rq_majortimeo > to->to_maxval || req->rq_majortimeo == 0)
-		req->rq_majortimeo = to->to_maxval;
-	req->rq_majortimeo += jiffies;
+		time_init = xprt_abs_ktime_to_jiffies(task->tk_start);
+	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
+	req->rq_majortimeo = time_init + xprt_calc_majortimeo(req);
 }
 
 /**
@@ -997,7 +1023,6 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	spin_unlock(&xprt->queue_lock);
 
-	xprt_reset_majortimeo(req);
 	/* Turn off autodisconnect */
 	del_singleshot_timer_sync(&xprt->timer);
 }
@@ -1631,7 +1656,6 @@ xprt_request_init(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_rqst	*req = task->tk_rqstp;
 
-	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
@@ -1644,7 +1668,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_snd_buf.bvec = NULL;
 	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
-	xprt_reset_majortimeo(req);
+	xprt_init_majortimeo(task, req);
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
 			req, ntohl(req->rq_xid));
 }
-- 
2.20.1

