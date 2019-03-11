Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A21BAC10F03
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 698D620652
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jYqwExmq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727017AbfCKBbJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 21:31:09 -0400
Received: from mail-io1-f44.google.com ([209.85.166.44]:44035 "EHLO
        mail-io1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727056AbfCKBbJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 21:31:09 -0400
Received: by mail-io1-f44.google.com with SMTP id u12so2594713iop.11
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 18:31:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KIMqOEZXsaH/c96izyKkwDtA5GObFaXLlPgQve2hVi4=;
        b=jYqwExmq5eNXAdE9IMde/mqPP4Z2EyaHqTweaj6IXwO4hsL77Sp9QM1thYpqL8F7TQ
         8ZMIoos4omrkPoy9sPDsaW66N+YwyNe1sJB9kEoLYMf7SbLy7F5ccfUlp6cQ0uCAhxjs
         8FTLNy6doWkd3/ntBuYlabx+EVmTHAMdA1vRI500UoFg3zr6ujDrecBhOYLTlA53HRYg
         XaU3vXVh9h21rs0ubgszk1ybFEpoPCGXS4Cv1SFfPGR/yk/1lrtsSBFhRQU4jGZXIF0y
         KU5ZH51l5anBIhUdH/9ho9PK+dpuBl8WjsnxmZZUFxi1ulQN8YID4SEP+JswYKvotWTl
         bvTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KIMqOEZXsaH/c96izyKkwDtA5GObFaXLlPgQve2hVi4=;
        b=JJGjupvMeC3HaD7AOCcG/v+epd9kn2it3wRms6DYuC5nt456CcSfiL/njkxwpAqU4T
         IeW8DXuSsi7PSdJRHhllf8EufBBnn2qdX8AP/b8yr/TtTs2ZGuMNuPniT5HmRLbdt2Y1
         d8daNhrNRQMClk2t7fQHgO2RJ4Xh6x5jTDh6j7S8wnuVmYouI1yYAQqsuX+XYFhbx24t
         cFE9cCdBQEyNu01ERiYHA3Ebks8DayYB4qmsQOZSewue6HNhxagZRvuKwkwOcKSbxR0S
         oEKoaTmQs+RbmHfiEnxdOGzD3xCVX4GjPP3kvZrMjwQVkfnSBqbpOKK/mackFV2h8g1Q
         HlvA==
X-Gm-Message-State: APjAAAUiJML3GQO4EHS8fAX2MIKCGlAehPuTbAr1HF5+toug+TgFeFNN
        StIMYvZcnn0+NvxqLMnq4CZewUU=
X-Google-Smtp-Source: APXvYqx4zQEiNbdbYnfh20jZRccDCiD75wh1go9+/We4nGqkk1IxrPW0rm4X1HVFYWbm+ofs+Qmnlg==
X-Received: by 2002:a6b:7708:: with SMTP id n8mr14075993iom.141.1552267867985;
        Sun, 10 Mar 2019 18:31:07 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id p79sm7515011itb.7.2019.03.10.18.31.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 18:31:07 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] SUNRPC: Micro-optimise when the task is known not to be sleeping
Date:   Sun, 10 Mar 2019 21:29:56 -0400
Message-Id: <20190311012957.3994-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190311012957.3994-3-trond.myklebust@hammerspace.com>
References: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
 <20190311012957.3994-2-trond.myklebust@hammerspace.com>
 <20190311012957.3994-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In cases where we know the task is not sleeping, try to optimise
away the indirect call to task->tk_action() by replacing it with
a direct call.
Only change tail calls, to allow gcc to perform tail call
elimination.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |  8 +++
 net/sunrpc/clnt.c            | 99 +++++++++++++++++++++++-------------
 2 files changed, 73 insertions(+), 34 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 52d41d0c1ae1..ec861cd0cfe8 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -304,4 +304,12 @@ rpc_clnt_swap_deactivate(struct rpc_clnt *clnt)
 }
 #endif /* CONFIG_SUNRPC_SWAP */
 
+static inline bool
+rpc_task_need_resched(const struct rpc_task *task)
+{
+	if (RPC_IS_QUEUED(task) || task->tk_callback)
+		return true;
+	return false;
+}
+
 #endif /* _LINUX_SUNRPC_SCHED_H_ */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 67c955d8b21b..498dd6ad5bc5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1540,6 +1540,7 @@ call_start(struct rpc_task *task)
 	clnt->cl_stats->rpccnt++;
 	task->tk_action = call_reserve;
 	rpc_task_set_transport(task, clnt);
+	call_reserve(task);
 }
 
 /*
@@ -1553,6 +1554,9 @@ call_reserve(struct rpc_task *task)
 	task->tk_status  = 0;
 	task->tk_action  = call_reserveresult;
 	xprt_reserve(task);
+	if (rpc_task_need_resched(task))
+		return;
+	 call_reserveresult(task);
 }
 
 static void call_retry_reserve(struct rpc_task *task);
@@ -1575,6 +1579,7 @@ call_reserveresult(struct rpc_task *task)
 	if (status >= 0) {
 		if (task->tk_rqstp) {
 			task->tk_action = call_refresh;
+			call_refresh(task);
 			return;
 		}
 
@@ -1600,6 +1605,7 @@ call_reserveresult(struct rpc_task *task)
 		/* fall through */
 	case -EAGAIN:	/* woken up; retry */
 		task->tk_action = call_retry_reserve;
+		call_retry_reserve(task);
 		return;
 	case -EIO:	/* probably a shutdown */
 		break;
@@ -1622,6 +1628,9 @@ call_retry_reserve(struct rpc_task *task)
 	task->tk_status  = 0;
 	task->tk_action  = call_reserveresult;
 	xprt_retry_reserve(task);
+	if (rpc_task_need_resched(task))
+		return;
+	call_reserveresult(task);
 }
 
 /*
@@ -1636,6 +1645,9 @@ call_refresh(struct rpc_task *task)
 	task->tk_status = 0;
 	task->tk_client->cl_stats->rpcauthrefresh++;
 	rpcauth_refreshcred(task);
+	if (rpc_task_need_resched(task))
+		return;
+	call_refreshresult(task);
 }
 
 /*
@@ -1654,6 +1666,7 @@ call_refreshresult(struct rpc_task *task)
 	case 0:
 		if (rpcauth_uptodatecred(task)) {
 			task->tk_action = call_allocate;
+			call_allocate(task);
 			return;
 		}
 		/* Use rate-limiting and a max number of retries if refresh
@@ -1672,6 +1685,7 @@ call_refreshresult(struct rpc_task *task)
 		task->tk_cred_retry--;
 		dprintk("RPC: %5u %s: retry refresh creds\n",
 				task->tk_pid, __func__);
+		call_refresh(task);
 		return;
 	}
 	dprintk("RPC: %5u %s: refresh creds failed with error %d\n",
@@ -1697,8 +1711,10 @@ call_allocate(struct rpc_task *task)
 	task->tk_status = 0;
 	task->tk_action = call_encode;
 
-	if (req->rq_buffer)
+	if (req->rq_buffer) {
+		call_encode(task);
 		return;
+	}
 
 	if (proc->p_proc != 0) {
 		BUG_ON(proc->p_arglen == 0);
@@ -1719,8 +1735,12 @@ call_allocate(struct rpc_task *task)
 
 	status = xprt->ops->buf_alloc(task);
 	xprt_inject_disconnect(xprt);
-	if (status == 0)
+	if (status == 0) {
+		if (rpc_task_need_resched(task))
+			return;
+		call_encode(task);
 		return;
+	}
 	if (status != -ENOMEM) {
 		rpc_exit(task, status);
 		return;
@@ -1803,12 +1823,8 @@ call_encode(struct rpc_task *task)
 		xprt_request_enqueue_receive(task);
 	xprt_request_enqueue_transmit(task);
 out:
-	task->tk_action = call_transmit;
-	/* Check that the connection is OK */
-	if (!xprt_bound(task->tk_xprt))
-		task->tk_action = call_bind;
-	else if (!xprt_connected(task->tk_xprt))
-		task->tk_action = call_connect;
+	task->tk_action = call_bind;
+	call_bind(task);
 }
 
 /*
@@ -1842,14 +1858,17 @@ call_bind(struct rpc_task *task)
 		return;
 	}
 
+	if (xprt_bound(xprt)) {
+		task->tk_action = call_connect;
+		call_connect(task);
+		return;
+	}
+
 	dprint_status(task);
 
-	task->tk_action = call_connect;
-	if (!xprt_bound(xprt)) {
-		task->tk_action = call_bind_status;
-		task->tk_timeout = xprt->bind_timeout;
-		xprt->ops->rpcbind(task);
-	}
+	task->tk_action = call_bind_status;
+	task->tk_timeout = xprt->bind_timeout;
+	xprt->ops->rpcbind(task);
 }
 
 /*
@@ -1869,6 +1888,7 @@ call_bind_status(struct rpc_task *task)
 		dprint_status(task);
 		task->tk_status = 0;
 		task->tk_action = call_connect;
+		call_connect(task);
 		return;
 	}
 
@@ -1949,21 +1969,24 @@ call_connect(struct rpc_task *task)
 		return;
 	}
 
+	if (xprt_connected(xprt)) {
+		task->tk_action = call_transmit;
+		call_transmit(task);
+		return;
+	}
+
 	dprintk("RPC: %5u call_connect xprt %p %s connected\n",
 			task->tk_pid, xprt,
 			(xprt_connected(xprt) ? "is" : "is not"));
 
-	task->tk_action = call_transmit;
-	if (!xprt_connected(xprt)) {
-		task->tk_action = call_connect_status;
-		if (task->tk_status < 0)
-			return;
-		if (task->tk_flags & RPC_TASK_NOCONNECT) {
-			rpc_exit(task, -ENOTCONN);
-			return;
-		}
-		xprt_connect(task);
+	task->tk_action = call_connect_status;
+	if (task->tk_status < 0)
+		return;
+	if (task->tk_flags & RPC_TASK_NOCONNECT) {
+		rpc_exit(task, -ENOTCONN);
+		return;
 	}
+	xprt_connect(task);
 }
 
 /*
@@ -2016,6 +2039,7 @@ call_connect_status(struct rpc_task *task)
 	case 0:
 		clnt->cl_stats->netreconn++;
 		task->tk_action = call_transmit;
+		call_transmit(task);
 		return;
 	}
 	rpc_exit(task, status);
@@ -2040,19 +2064,20 @@ call_transmit(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
+	if (!xprt_prepare_transmit(task))
+		return;
+	task->tk_status = 0;
 	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
-		if (!xprt_prepare_transmit(task))
+		if (!xprt_connected(task->tk_xprt)) {
+			task->tk_status = -ENOTCONN;
 			return;
-		task->tk_status = 0;
-		if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
-			if (!xprt_connected(task->tk_xprt)) {
-				task->tk_status = -ENOTCONN;
-				return;
-			}
-			xprt_transmit(task);
 		}
+		xprt_transmit(task);
 	}
 	xprt_end_transmit(task);
+	if (rpc_task_need_resched(task))
+		return;
+	call_transmit_status(task);
 }
 
 /*
@@ -2067,8 +2092,12 @@ call_transmit_status(struct rpc_task *task)
 	 * Common case: success.  Force the compiler to put this
 	 * test first.
 	 */
-	if (task->tk_status == 0) {
-		xprt_request_wait_receive(task);
+	if (rpc_task_transmitted(task)) {
+		if (task->tk_status == 0)
+			xprt_request_wait_receive(task);
+		if (rpc_task_need_resched(task))
+			return;
+		call_status(task);
 		return;
 	}
 
@@ -2129,6 +2158,7 @@ call_bc_encode(struct rpc_task *task)
 {
 	xprt_request_enqueue_transmit(task);
 	task->tk_action = call_bc_transmit;
+	call_bc_transmit(task);
 }
 
 /*
@@ -2219,6 +2249,7 @@ call_status(struct rpc_task *task)
 	status = task->tk_status;
 	if (status >= 0) {
 		task->tk_action = call_decode;
+		call_decode(task);
 		return;
 	}
 
-- 
2.20.1

