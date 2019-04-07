Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F422C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E301C20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A8StWPQr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726456AbfDGSBf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:35 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:55256 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726415AbfDGSBf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:35 -0400
Received: by mail-it1-f193.google.com with SMTP id a190so17229772ite.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=9TX7g4S7xzkondKf38t9AGk7m6l2VTWuVMxzRXlwvv0=;
        b=A8StWPQrdvsPMGc98yx+7rccYuuIjU9JYx2/6oUnaVcrBqPD3JQn0v7/HvqrJucXt2
         NIeeJ1h3m29nBUHYqvWeUQVrhuD+yhsiKNNPkB5z2ECNSsMIs0Y6O6zaO71enfFZfdV8
         H0sfg7m8qbtuuQsBY+iNQAlbvYslq+efStTigR7yC1nw7fa7zwuw+Mwqglx90O8/KBuH
         oWLTJdMwfrwxGBCZc7RNvQFn+1y4OaqPoyNWGfUIf2Ltw8ea9QXZ2GfEowZOvpWec9zJ
         5i9c5JbjvmxXjtljDkYnIr7ocEFHE0f+zHVyLDZnjfjy+5mbbuU4307saWln6/E6FsEW
         oFiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=9TX7g4S7xzkondKf38t9AGk7m6l2VTWuVMxzRXlwvv0=;
        b=MHD0Z4bxUIVSGCDyeR9UoDwb9KZqldLx+CaXNugW9g3ePLok8Pwsnlbsekuf0iDvQ8
         BKMLaoMxI/ASRtn+ioFTFQCgTuLVPuFo2+40SP2RyQ/wxcNh0DTl8z9Sfo1UnV7mGXFS
         /im/Af9kxYm8XFC0MpSxJ32EwePa7bi7mmhIPBH9MxDhKibc7T2uaHa4bMGPnSvTGVKS
         WYIIFmOX3T3QsKmXcIrEE4huzhQBhs6IITkFb++/guQFOxp0e9iioF4efOYyy3AMyIBR
         oh/Jv39aASt3yxFPQIb1qhCc/whgIyQlIMtVwY2ym66ts6GPMmc8wYvk5paJ3pV/taGE
         w+4A==
X-Gm-Message-State: APjAAAWL68/eRPFFBjF0GjYQMESeLQklyzuot66GrSvyMamMFfUE7952
        zhs1d0DaiBbpLODRXqKSWQ==
X-Google-Smtp-Source: APXvYqwOcMaRRFD2fu7HJtz3xKg+K9Md9t13hPC4YdhmWsOSHY6LQiFGVH4fyEpCBO/NZVQP7XQX/Q==
X-Received: by 2002:a24:205:: with SMTP id 5mr16800418itu.150.1554660093612;
        Sun, 07 Apr 2019 11:01:33 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:32 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/29] SUNRPC: Start the first major timeout calculation at task creation
Date:   Sun,  7 Apr 2019 13:58:56 -0400
Message-Id: <20190407175912.23528-14-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-13-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
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

