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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47361C10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 127F22184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lV4wtN6+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730137AbfC2WCE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:04 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:54504 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730144AbfC2WCD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:03 -0400
Received: by mail-it1-f195.google.com with SMTP id w18so6170940itj.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=lV4wtN6+/JZRC1cBqdMIDXN/KxK/0b7qHJ3EiOXw85+rvpvYxa1gTmvtfWeTODdOzt
         zSdh12ZcfCGmP+5Q6kCTb0G9hQDilnfxnxnnXuz6WXFDqPgAt87hkg3hx4Djk+FDveGO
         LbpwqRxBvUb/Nm6Ltd1qV/4TqW2TiZsCnmkpLl4PaaEDujF2nALiZCx39Fz2ywnM12fz
         liU60CTa+ClTVa2b+Ulmvp7zMZn6NtwCsOyE42Q3VU7uxn4xi0Hhn8vxcvXGbqyWIYNA
         RXVZRZzy/AnapimsfjSWf5LS4EBTyXQ+IjbruwjO3uZYHNMCMgnU6wQm0NWLPoa559bp
         vG+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=iV+yDHotVTZmbt0/g2z1IskJfmTPy2LhpUfUvIlyZu7LsfSunOGgrS63a/MMSlmJmG
         RVtGOvcinj5CoWARVQfJkqEXcmiI2yd8sNNYljFWMKM7niULKGGzc8WuCMRoECeECNsw
         Wvp97ZoiRkXRBFvY7b9m25zFSQYKjHP7G058VhY2U+5XdaCmgX8p0DE9bZsGqj7ugqL+
         7nM6NYyp3dI/swtrnPTlbKeRmAXe3ujkLIttoM8oiqMYiC3P+T5pQYezMf/qa33wVYHn
         Vga9BrzW0SWnr8fBMc6BW7G4kQ76RguEn979avB4EAgQd9za/Rwo3ReJFvOdOYP2IPrd
         52yw==
X-Gm-Message-State: APjAAAX6OTTFOjNDhPX3fDlaP2rtJgvgYcowksLGvmLSeG6MjhS23Z8N
        U0vB82leM69AwB0r3a+oRkvkSb4=
X-Google-Smtp-Source: APXvYqxQb4uqRCiJFD1QGL+rC4Uf0XrUrk4NBlAH7ttpAThpFiWzj+8MLDpm5pZJlWdHbozUI86pKg==
X-Received: by 2002:a24:9f45:: with SMTP id c66mr6645834ite.128.1553896922153;
        Fri, 29 Mar 2019 15:02:02 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:01 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/28] SUNRPC: Fix up tracking of timeouts
Date:   Fri, 29 Mar 2019 17:59:27 -0400
Message-Id: <20190329215948.107328-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-7-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a helper to ensure that debugfs and friends print out the
correct current task timeout value.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h  |  1 +
 include/trace/events/sunrpc.h |  2 +-
 net/sunrpc/clnt.c             |  2 +-
 net/sunrpc/debugfs.c          |  2 +-
 net/sunrpc/sched.c            | 14 ++++++++++++++
 5 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 81f5d93f7109..0b7d333f624e 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -226,6 +226,7 @@ void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_destroy_wait_queue(struct rpc_wait_queue *);
+unsigned long	rpc_task_timeout(const struct rpc_task *task);
 void		rpc_sleep_on_timeout(struct rpc_wait_queue *queue,
 					struct rpc_task *task,
 					rpc_action action,
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 5e3b77d9daa7..dd301db64521 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -186,7 +186,7 @@ DECLARE_EVENT_CLASS(rpc_task_queued,
 		__entry->client_id = task->tk_client ?
 				     task->tk_client->cl_clid : -1;
 		__entry->task_id = task->tk_pid;
-		__entry->timeout = task->tk_timeout;
+		__entry->timeout = rpc_task_timeout(task);
 		__entry->runstate = task->tk_runstate;
 		__entry->status = task->tk_status;
 		__entry->flags = task->tk_flags;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4d853b5420c8..3ab743c0e888 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2900,7 +2900,7 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
 
 	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%ps q:%s\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
-		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
+		clnt, task->tk_rqstp, rpc_task_timeout(task), task->tk_ops,
 		clnt->cl_program->name, clnt->cl_vers, rpc_proc_name(task),
 		task->tk_action, rpc_waitq);
 }
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 19bb356230ed..95ebd76b132d 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -33,7 +33,7 @@ tasks_show(struct seq_file *f, void *v)
 
 	seq_printf(f, "%5u %04x %6d 0x%x 0x%x %8ld %ps %sv%u %s a:%ps q:%s\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
-		clnt->cl_clid, xid, task->tk_timeout, task->tk_ops,
+		clnt->cl_clid, xid, rpc_task_timeout(task), task->tk_ops,
 		clnt->cl_program->name, clnt->cl_vers, rpc_proc_name(task),
 		task->tk_action, rpc_waitq);
 	return 0;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 7e0f7b83262f..40944c34a9e4 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -58,6 +58,20 @@ static struct rpc_wait_queue delay_queue;
 struct workqueue_struct *rpciod_workqueue __read_mostly;
 struct workqueue_struct *xprtiod_workqueue __read_mostly;
 
+unsigned long
+rpc_task_timeout(const struct rpc_task *task)
+{
+	unsigned long timeout = READ_ONCE(task->tk_timeout);
+
+	if (timeout != 0) {
+		unsigned long now = jiffies;
+		if (time_before(now, timeout))
+			return timeout - now;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_task_timeout);
+
 /*
  * Disable the timer for a given RPC task. Should be called with
  * queue->lock and bh_disabled in order to avoid races within
-- 
2.20.1

