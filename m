Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C21CCC282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 81A6B20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uXdpQ0hq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726376AbfDGSBX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:23 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:36830 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726360AbfDGSBX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:23 -0400
Received: by mail-it1-f195.google.com with SMTP id y10so17367769itc.1
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xExJh72js22X6EmLvhYclmaSv1mMe/EiKVhznFesUJA=;
        b=uXdpQ0hqX44XrcWT1XZRB17rpJoI18KTSjIw6Lr8C3nuQgcJJ0BOupdhZ7gQxYbrPg
         QWelEnC4GJWGiXjA7EmpcTF4ljX28DXT9gKRv6jeazebA9SoIf4qLYBohfiUUtlBbT7Y
         EtKgkYUeJ+ws782V9M3OeY8nr+TDsPHMVDcpahPGVSzERYF1hYYMia0VcLVe6xUaNnHN
         AgEt2KvXd9fgjM4KCTpUHLRm87gDbzHImXSnup8hjZxPuzbSi5NwcBjp2YZFVcbf1Dlx
         G3/I/uDqpKcZ1qXKU34Ip4f7VFvEVy2ITwxP9e98xehHrCp1wNmYOKSmfy8QPGkj8nqi
         lvQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=xExJh72js22X6EmLvhYclmaSv1mMe/EiKVhznFesUJA=;
        b=mpCjQbUu9fIfRCG9GNCsshQx/XRUwalyA5IZcPt3pk7nQX65HFd2w27MVGgn/wCm3t
         wIyxosTc585oxYbeQRLzAsluVXcAKsItZN9h5F/ALL4BSrJ3JTNaOZQT73wPA0T9uh+9
         ATdM2g674sWpXPFTi7doR7BbrNn+jMebMqzW2JHS9XT2TEgPzTfgGgW22WPoL/eH3OdB
         kCvU7MqpMuJnpkoTLUmBb4RWFgfg37VSgpmgR91vEHwXraMXOP2VZsJvFU/slVzA0Qj1
         Vki6SmxFZacziIMYsG6Dr3p7f/2kNJEZCinij6j6OiBZ2dx1hEsqHwJHPPsjabctQhnN
         eKlg==
X-Gm-Message-State: APjAAAWSyA1SJH4QAQBB1X4l0YMTPkqYHXqWnfTyj2ggCIvtPtniU6Ay
        7xdfs/PyvUwsEe4CYnjQDQ==
X-Google-Smtp-Source: APXvYqyi9+YAjYiaOv3VvuPwGXBc44LTsPAWXZim/XJ3yRJdKaVi4F2qmVmxB6la71GKPB9oIxRPDg==
X-Received: by 2002:a02:2b1d:: with SMTP id h29mr19077023jaa.76.1554660082112;
        Sun, 07 Apr 2019 11:01:22 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:21 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 01/29] SUNRPC: Fix up task signalling
Date:   Sun,  7 Apr 2019 13:58:44 -0400
Message-Id: <20190407175912.23528-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The RPC_TASK_KILLED flag should really not be set from another context
because it can clobber data in the struct task when task->tk_flags is
changed non-atomically.
Let's therefore swap out RPC_TASK_KILLED with an atomic flag, and add
a function to set that flag and safely wake up the task.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/clntproc.c           |  4 ++--
 fs/nfsd/nfs4callback.c        |  4 ++--
 include/linux/sunrpc/sched.h  |  6 ++++--
 include/trace/events/sunrpc.h |  6 +++---
 net/sunrpc/clnt.c             | 14 ++------------
 net/sunrpc/sched.c            | 28 +++++++++++++++++++++++-----
 net/sunrpc/xprt.c             |  4 ++++
 7 files changed, 40 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index e8a004097d18..d9c32d1a20c0 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -715,7 +715,7 @@ static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)
 	struct nlm_rqst	*req = data;
 	u32 status = ntohl(req->a_res.status);
 
-	if (RPC_ASSASSINATED(task))
+	if (RPC_SIGNALLED(task))
 		goto die;
 
 	if (task->tk_status < 0) {
@@ -783,7 +783,7 @@ static void nlmclnt_cancel_callback(struct rpc_task *task, void *data)
 	struct nlm_rqst	*req = data;
 	u32 status = ntohl(req->a_res.status);
 
-	if (RPC_ASSASSINATED(task))
+	if (RPC_SIGNALLED(task))
 		goto die;
 
 	if (task->tk_status < 0) {
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d219159b98af..f7494be8dbe2 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1032,7 +1032,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 		 * the submission code will error out, so we don't need to
 		 * handle that case here.
 		 */
-		if (task->tk_flags & RPC_TASK_KILLED)
+		if (RPC_SIGNALLED(task))
 			goto need_restart;
 
 		return true;
@@ -1081,7 +1081,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 	dprintk("%s: freed slot, new seqid=%d\n", __func__,
 		clp->cl_cb_session->se_cb_seq_nr);
 
-	if (task->tk_flags & RPC_TASK_KILLED)
+	if (RPC_SIGNALLED(task))
 		goto need_restart;
 out:
 	return ret;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index ec861cd0cfe8..852ca0f2c56c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -125,7 +125,6 @@ struct rpc_task_setup {
 #define RPC_CALL_MAJORSEEN	0x0020		/* major timeout seen */
 #define RPC_TASK_ROOTCREDS	0x0040		/* force root creds */
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
-#define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
 #define RPC_TASK_SOFTCONN	0x0400		/* Fail if can't connect */
 #define RPC_TASK_SENT		0x0800		/* message was sent */
@@ -135,7 +134,6 @@ struct rpc_task_setup {
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
-#define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
@@ -146,6 +144,7 @@ struct rpc_task_setup {
 #define RPC_TASK_NEED_XMIT	3
 #define RPC_TASK_NEED_RECV	4
 #define RPC_TASK_MSG_PIN_WAIT	5
+#define RPC_TASK_SIGNALLED	6
 
 #define RPC_IS_RUNNING(t)	test_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
 #define rpc_set_running(t)	set_bit(RPC_TASK_RUNNING, &(t)->tk_runstate)
@@ -169,6 +168,8 @@ struct rpc_task_setup {
 
 #define RPC_IS_ACTIVATED(t)	test_bit(RPC_TASK_ACTIVE, &(t)->tk_runstate)
 
+#define RPC_SIGNALLED(t)	test_bit(RPC_TASK_SIGNALLED, &(t)->tk_runstate)
+
 /*
  * Task priorities.
  * Note: if you change these, you must also change
@@ -217,6 +218,7 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_put_task_async(struct rpc_task *);
+void		rpc_signal_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_exit(struct rpc_task *, int);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 7e899e635d33..5e3b77d9daa7 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -82,7 +82,6 @@ TRACE_DEFINE_ENUM(RPC_TASK_SWAPPER);
 TRACE_DEFINE_ENUM(RPC_CALL_MAJORSEEN);
 TRACE_DEFINE_ENUM(RPC_TASK_ROOTCREDS);
 TRACE_DEFINE_ENUM(RPC_TASK_DYNAMIC);
-TRACE_DEFINE_ENUM(RPC_TASK_KILLED);
 TRACE_DEFINE_ENUM(RPC_TASK_SOFT);
 TRACE_DEFINE_ENUM(RPC_TASK_SOFTCONN);
 TRACE_DEFINE_ENUM(RPC_TASK_SENT);
@@ -97,7 +96,6 @@ TRACE_DEFINE_ENUM(RPC_TASK_NO_RETRANS_TIMEOUT);
 		{ RPC_CALL_MAJORSEEN, "MAJORSEEN" },			\
 		{ RPC_TASK_ROOTCREDS, "ROOTCREDS" },			\
 		{ RPC_TASK_DYNAMIC, "DYNAMIC" },			\
-		{ RPC_TASK_KILLED, "KILLED" },				\
 		{ RPC_TASK_SOFT, "SOFT" },				\
 		{ RPC_TASK_SOFTCONN, "SOFTCONN" },			\
 		{ RPC_TASK_SENT, "SENT" },				\
@@ -111,6 +109,7 @@ TRACE_DEFINE_ENUM(RPC_TASK_ACTIVE);
 TRACE_DEFINE_ENUM(RPC_TASK_NEED_XMIT);
 TRACE_DEFINE_ENUM(RPC_TASK_NEED_RECV);
 TRACE_DEFINE_ENUM(RPC_TASK_MSG_PIN_WAIT);
+TRACE_DEFINE_ENUM(RPC_TASK_SIGNALLED);
 
 #define rpc_show_runstate(flags)					\
 	__print_flags(flags, "|",					\
@@ -119,7 +118,8 @@ TRACE_DEFINE_ENUM(RPC_TASK_MSG_PIN_WAIT);
 		{ (1UL << RPC_TASK_ACTIVE), "ACTIVE" },			\
 		{ (1UL << RPC_TASK_NEED_XMIT), "NEED_XMIT" },		\
 		{ (1UL << RPC_TASK_NEED_RECV), "NEED_RECV" },		\
-		{ (1UL << RPC_TASK_MSG_PIN_WAIT), "MSG_PIN_WAIT" })
+		{ (1UL << RPC_TASK_MSG_PIN_WAIT), "MSG_PIN_WAIT" },	\
+		{ (1UL << RPC_TASK_SIGNALLED), "SIGNALLED" })
 
 DECLARE_EVENT_CLASS(rpc_task_running,
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 187d10443a15..30f5995c6a68 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -827,14 +827,8 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 	 * Spin lock all_tasks to prevent changes...
 	 */
 	spin_lock(&clnt->cl_lock);
-	list_for_each_entry(rovr, &clnt->cl_tasks, tk_task) {
-		if (!RPC_IS_ACTIVATED(rovr))
-			continue;
-		if (!(rovr->tk_flags & RPC_TASK_KILLED)) {
-			rovr->tk_flags |= RPC_TASK_KILLED;
-			rpc_exit(rovr, -EIO);
-		}
-	}
+	list_for_each_entry(rovr, &clnt->cl_tasks, tk_task)
+		rpc_signal_task(rovr);
 	spin_unlock(&clnt->cl_lock);
 }
 EXPORT_SYMBOL_GPL(rpc_killall_tasks);
@@ -1477,8 +1471,6 @@ EXPORT_SYMBOL_GPL(rpc_force_rebind);
 int
 rpc_restart_call_prepare(struct rpc_task *task)
 {
-	if (RPC_ASSASSINATED(task))
-		return 0;
 	task->tk_action = call_start;
 	task->tk_status = 0;
 	if (task->tk_ops->rpc_call_prepare != NULL)
@@ -1494,8 +1486,6 @@ EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
 int
 rpc_restart_call(struct rpc_task *task)
 {
-	if (RPC_ASSASSINATED(task))
-		return 0;
 	task->tk_action = call_start;
 	task->tk_status = 0;
 	return 1;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 28956c70100a..3d6cb91ba598 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -759,8 +759,7 @@ static void
 rpc_reset_task_statistics(struct rpc_task *task)
 {
 	task->tk_timeouts = 0;
-	task->tk_flags &= ~(RPC_CALL_MAJORSEEN|RPC_TASK_KILLED|RPC_TASK_SENT);
-
+	task->tk_flags &= ~(RPC_CALL_MAJORSEEN|RPC_TASK_SENT);
 	rpc_init_task_statistics(task);
 }
 
@@ -773,7 +772,6 @@ void rpc_exit_task(struct rpc_task *task)
 	if (task->tk_ops->rpc_call_done != NULL) {
 		task->tk_ops->rpc_call_done(task, task->tk_calldata);
 		if (task->tk_action != NULL) {
-			WARN_ON(RPC_ASSASSINATED(task));
 			/* Always release the RPC slot and buffer memory */
 			xprt_release(task);
 			rpc_reset_task_statistics(task);
@@ -781,6 +779,19 @@ void rpc_exit_task(struct rpc_task *task)
 	}
 }
 
+void rpc_signal_task(struct rpc_task *task)
+{
+	struct rpc_wait_queue *queue;
+
+	if (!RPC_IS_ACTIVATED(task))
+		return;
+	set_bit(RPC_TASK_SIGNALLED, &task->tk_runstate);
+	smp_mb__after_atomic();
+	queue = READ_ONCE(task->tk_waitqueue);
+	if (queue)
+		rpc_wake_up_queued_task_set_status(queue, task, -ERESTARTSYS);
+}
+
 void rpc_exit(struct rpc_task *task, int status)
 {
 	task->tk_status = status;
@@ -836,6 +847,13 @@ static void __rpc_execute(struct rpc_task *task)
 		 */
 		if (!RPC_IS_QUEUED(task))
 			continue;
+
+		/*
+		 * Signalled tasks should exit rather than sleep.
+		 */
+		if (RPC_SIGNALLED(task))
+			rpc_exit(task, -ERESTARTSYS);
+
 		/*
 		 * The queue->lock protects against races with
 		 * rpc_make_runnable().
@@ -861,7 +879,7 @@ static void __rpc_execute(struct rpc_task *task)
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
 				RPC_TASK_QUEUED, rpc_wait_bit_killable,
 				TASK_KILLABLE);
-		if (status == -ERESTARTSYS) {
+		if (status < 0) {
 			/*
 			 * When a sync task receives a signal, it exits with
 			 * -ERESTARTSYS. In order to catch any callbacks that
@@ -869,7 +887,7 @@ static void __rpc_execute(struct rpc_task *task)
 			 * break the loop here, but go around once more.
 			 */
 			dprintk("RPC: %5u got signal\n", task->tk_pid);
-			task->tk_flags |= RPC_TASK_KILLED;
+			set_bit(RPC_TASK_SIGNALLED, &task->tk_runstate);
 			rpc_exit(task, -ERESTARTSYS);
 		}
 		dprintk("RPC: %5u sync task resuming\n", task->tk_pid);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d7117d241460..3a4156cb0134 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1337,6 +1337,10 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 			if (status < 0)
 				goto out_dequeue;
 		}
+		if (RPC_SIGNALLED(task)) {
+			status = -ERESTARTSYS;
+			goto out_dequeue;
+		}
 	}
 
 	/*
-- 
2.20.1

