Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A44B7C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:04:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 68D1E2146E
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:04:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iJ+yW8GR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726565AbfBSOEW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 09:04:22 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:56260 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725803AbfBSOEW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 09:04:22 -0500
Received: by mail-it1-f196.google.com with SMTP id z131so6177578itf.5
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 06:04:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=cF1uo5leOBOLaDcILucKAfhaCc+FAPHnGjky9gLvtI0=;
        b=iJ+yW8GR2Ia3PS/sf+1lo4DAMYIO6tfdUcCFYcuVnhkyNqpvno+OUaWd7m3//62S+V
         5TO8GvEPfW1Fuztf0vigN+++OcNTRQn9UiiRx5vtkkxSGqyRFdNCVXPfghVjejD/CItp
         Ia4ybt06eWmJ3D0JPbLhrtDAbz2O0hq4vNbt8QFHLorqvN8AXukJXbIAImD+WyQXE0gy
         hFjWOBgHJ31AGc5OA+Prw+EW2a43cQbvuRWyZpTmVAhqcFP8YufOdTlYZEbHbgifxBpR
         hmgiK9yP6YFe9PsFBHvlggtC/EFMuszWs0tl6Oxl6Did26h/RdLsgpBLxds5PoLO7oIQ
         ZM/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=cF1uo5leOBOLaDcILucKAfhaCc+FAPHnGjky9gLvtI0=;
        b=CG2r5ylWWXP9gyFG80pXGzjAe0wJziImai3btOAZ2DQnS6NIepcsECC0kXt/95uhF+
         eTBuUni8j0JfWrCrqp/VkE8kcRJA9sAMlsPYPMV5RSlGahqRO7wSKKUfzAzEvWmY/53y
         2aPfoAOCiQBNJwwpeHKPpedGKAsT3KJ6mlHWp3gBdl3w+BTPYL7WTRxVKd2E40ItnOs1
         i6/7TCsiCmI38r7AXwoPuc/VCm1jjZCzvjjIk8JF5j6uXiFiXmsM+6pKzcbbrBYpeFB/
         yZhJI9Fpvzu5Rc2mh2ZPIkLxdfaimpYJ5hy2J2WxsO+Qa5xIKbmOQGL4bncnzyKyCDkw
         ubmw==
X-Gm-Message-State: AHQUAuYjWshjc711fIv6zAeyHjnpFOKgwTA90JVw/dgUUqptta1mqmvz
        sD13tF9lS1mQXJZt2ZyPO5IUQps=
X-Google-Smtp-Source: AHgI3IZ2zXC6s3TpMlR6QIBVi01b400TyajyN1qXLs5qzfXOA+/RaHCMgxBg8QOmKVNZVmKxLtGi8Q==
X-Received: by 2002:a6b:e208:: with SMTP id z8mr17907625ioc.56.1550585061029;
        Tue, 19 Feb 2019 06:04:21 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f13sm6697292iol.82.2019.02.19.06.04.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 06:04:20 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Set memalloc_nofs_save() on all rpciod/xprtiod jobs
Date:   Tue, 19 Feb 2019 09:02:33 -0500
Message-Id: <20190219140233.120140-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Set memalloc_nofs_save() on all the rpciod/xprtiod jobs so that we
ensure memory allocations for asynchronous rpc calls don't ever end
up recursing back to the NFS layer for memory reclaim.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/sched.c    |  7 +++++++
 net/sunrpc/xprt.c     |  3 +++
 net/sunrpc/xprtsock.c | 10 +++++++---
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index adc3c40cc733..2168d4d9c09f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -19,6 +19,7 @@
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/freezer.h>
+#include <linux/sched/mm.h>
 
 #include <linux/sunrpc/clnt.h>
 
@@ -902,7 +903,10 @@ void rpc_execute(struct rpc_task *task)
 
 static void rpc_async_schedule(struct work_struct *work)
 {
+	unsigned int pflags = memalloc_nofs_save();
+
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
+	memalloc_nofs_restore(pflags);
 }
 
 /**
@@ -1067,7 +1071,10 @@ static void rpc_free_task(struct rpc_task *task)
 
 static void rpc_async_release(struct work_struct *work)
 {
+	unsigned int pflags = memalloc_nofs_save();
+
 	rpc_free_task(container_of(work, struct rpc_task, u.tk_work));
+	memalloc_nofs_restore(pflags);
 }
 
 static void rpc_release_resources_task(struct rpc_task *task)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f1ec2110efeb..b95f4452dbc6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -49,6 +49,7 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/rcupdate.h>
+#include <linux/sched/mm.h>
 
 #include <trace/events/sunrpc.h>
 
@@ -643,11 +644,13 @@ static void xprt_autoclose(struct work_struct *work)
 {
 	struct rpc_xprt *xprt =
 		container_of(work, struct rpc_xprt, task_cleanup);
+	unsigned int pflags = memalloc_nofs_save();
 
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt->ops->close(xprt);
 	xprt_release_write(xprt, NULL);
 	wake_up_bit(&xprt->state, XPRT_LOCKED);
+	memalloc_nofs_restore(pflags);
 }
 
 /**
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7754aa3e434f..f5d7dcd9e8d9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -50,6 +50,7 @@
 #include <linux/bvec.h>
 #include <linux/highmem.h>
 #include <linux/uio.h>
+#include <linux/sched/mm.h>
 
 #include <trace/events/sunrpc.h>
 
@@ -680,7 +681,10 @@ static void xs_stream_data_receive_workfn(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, recv_worker);
+	unsigned int pflags = memalloc_nofs_save();
+
 	xs_stream_data_receive(transport);
+	memalloc_nofs_restore(pflags);
 }
 
 static void
@@ -1378,7 +1382,10 @@ static void xs_udp_data_receive_workfn(struct work_struct *work)
 {
 	struct sock_xprt *transport =
 		container_of(work, struct sock_xprt, recv_worker);
+	unsigned int pflags = memalloc_nofs_save();
+
 	xs_udp_data_receive(transport);
+	memalloc_nofs_restore(pflags);
 }
 
 /**
@@ -1869,7 +1876,6 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		sk->sk_write_space = xs_udp_write_space;
 		sock_set_flag(sk, SOCK_FASYNC);
 		sk->sk_error_report = xs_error_report;
-		sk->sk_allocation = GFP_NOIO;
 
 		xprt_clear_connected(xprt);
 
@@ -2057,7 +2063,6 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_data_ready = xs_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sock_set_flag(sk, SOCK_FASYNC);
-		sk->sk_allocation = GFP_NOIO;
 
 		xprt_set_connected(xprt);
 
@@ -2220,7 +2225,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_write_space = xs_tcp_write_space;
 		sock_set_flag(sk, SOCK_FASYNC);
 		sk->sk_error_report = xs_error_report;
-		sk->sk_allocation = GFP_NOIO;
 
 		/* socket options */
 		sock_reset_flag(sk, SOCK_LINGER);
-- 
2.20.1

