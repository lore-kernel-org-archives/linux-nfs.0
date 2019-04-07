Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E155C282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6899B20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U7GOYa+c"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726388AbfDGSB2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:28 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:40745 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726409AbfDGSB2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:28 -0400
Received: by mail-io1-f68.google.com with SMTP id d201so9088186iof.7
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=U7GOYa+cfIxIyLjeXZM68CiEfM4HSOiLu2/tzA6G1JIu+JdhTRIFhZ1IGJToeLlS2q
         xNJXe9pV94ad5ctDQnOSj0TOwdbpUkqPYLBHgeVyTjzrl6h9+v1ZZJwtzN29Aup6pTZC
         6ZFdt/6Pjq+kHuB0Rt2wQguBx3odeWblgVqoOtd4RDZ7cJi9ccjAh2xHwEBFGsb5nsP9
         r7T53GfTVPbIjWfm9DQ3WwTvp2Sd+AjsHkQ24aL2EWJa56kfJ08eaVb5ik9K95A/FEO5
         BjnHmR3INEwaCvy3R0bgPX5Hq9+eWRJZXFiXTvYZGf7/k+2d+y9J+Wgrhwcj03SwfaAe
         1pSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=gpw41iijWBzhc0I5TDsDllXLnyVDwBiUz+r5DTcrJZg=;
        b=lNRGmoh0nh/pAe3aO9rAVjcAqx/Lmi7PINinMCuKTF08zVYh6lrnTHL8yE/NKF4vMS
         WPGLUzpYaUUOCCOwZayxf9zQlp6a45El63Kv6SYIyCmq7qutcEJVWcewR8PjsvPHeidt
         JZeK7ehmsu8orHTPiDKY6Ra5HeHtbrsNNDvSAYJn65yN3L0fJtSPfhTkHcpbzkdFQWyR
         AzZ+oPrXoJTTJbHq07BYXsSLB2TPA6g/GjeL7mdqW48jsvd1vRcViro77hLr/0T3+D7J
         N4wv2JKK8hNOslf4e47uWM+P6HOqnXlwvgUEdgOmgXjQutV0U7MgsQOd5qYGJmLaB+6B
         NLrQ==
X-Gm-Message-State: APjAAAXVrfo0RI0qo3ubi46z9RiWUE+S7GWir3HmtxMz/RLc1xmX/wIg
        Jbxv+6ffs4gm3VLrkGYJrw==
X-Google-Smtp-Source: APXvYqzOfW6o/amp+4+Pe9HSgudljX52VzmzfRdKrNVkmDW+Se6EE8daPi24bjlFksY/OLl3Q4Q42g==
X-Received: by 2002:a6b:c804:: with SMTP id y4mr16349417iof.196.1554660087481;
        Sun, 07 Apr 2019 11:01:27 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:26 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/29] SUNRPC: Fix up tracking of timeouts
Date:   Sun,  7 Apr 2019 13:58:50 -0400
Message-Id: <20190407175912.23528-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-7-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
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

