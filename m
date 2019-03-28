Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3546CC4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 05BD221855
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YjHWBaxy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726307AbfC1U4Q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:16 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:33202 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726290AbfC1U4P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:15 -0400
Received: by mail-io1-f68.google.com with SMTP id b6so20710iog.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=YjHWBaxy06vPmVkEODxC2cRANXOLfMN6Y4x5CaFKhc7syoSTEqKjpP6jn2lPd7Z1gg
         NdlKzKhdlh6ALgV9qOdfTJNqz1XipU3NAnfZ6b+Dv3xQ+Op4IkSmriKAJeruh1oo8bow
         4+V5h3RtKSs0t3ZrLSZWQiyKF+r1DY24BvmfzMDXjxRXX1bsQPSgGjYjOHayUyDJa/j7
         utL8a8MzQzkyVBbw11tdvPJhrO/gcGn3USdMrP3E3ZaDGDawoxptjuAUB2dkE5wFtubC
         rwtb2ACLNl3ZdR5g3bTp6/UomgyGjnWLBtqSPbxWm36CPnRegvsv0S1jVHKcxurLsoIc
         99iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=A2BYE4YBtU/4+Bk7Hy8APPZGDhNcXK5VR1KS0InIL4DmygRi8L39+fGFqFr8P87Gvj
         Js8eYwR9wKsD2qr4o4Cyo0ZXd+m4G56KP0VX4QFBVfpwMlvsaXKefxsWY1m0Frq1Ws9h
         OttIFHqD9AXYjCjBl46/Eu1FUIa06ibd2j6uhZyKlAUaykg1rjGLdjujYg4A8cCRm5Rb
         YvCA3fHFNhyxSnEi2rWdpQDpJKYqFBiaUXeBEmIBY3m5f4zvNmVPMcnsQ7i5QgYMIoxr
         FgPIewz84bPXM7I+npfD1l9UFsBcIYHiNHkSK3tLpoVVeONw6peKhc0FP3AnYjtVxhmf
         X7Uw==
X-Gm-Message-State: APjAAAV3UGYceVtJP2LuZ5M8VzfKqytE2s767egz8yIkXBXiF7Jemu3u
        y4LhYInoFAwXEai+p0cVnAyzz8Q=
X-Google-Smtp-Source: APXvYqzdA5Rnf+A6Y+r7X3ubdcC25iz5QAEcXpxyLicWpSUPITpSNe8nUJCV6sTKmaM8Rzd36iMC2w==
X-Received: by 2002:a6b:fa0b:: with SMTP id p11mr25904946ioh.36.1553806574255;
        Thu, 28 Mar 2019 13:56:14 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:13 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 07/25] SUNRPC: Fix up tracking of timeouts
Date:   Thu, 28 Mar 2019 16:52:21 -0400
Message-Id: <20190328205239.29674-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-7-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
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

