Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6B81C10F06
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 85CBC21850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XU91W2i9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726224AbfC1U4R (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:17 -0400
Received: from mail-io1-f51.google.com ([209.85.166.51]:32788 "EHLO
        mail-io1-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727068AbfC1U4R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:17 -0400
Received: by mail-io1-f51.google.com with SMTP id b6so20802iog.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=65qi2Mgtrv2QRf0+fXUsTBcWY9go3PzfM5PG7vyohIo=;
        b=XU91W2i9meL7g15PKZXqDusOXpZX0yV+F0kPD60Y+oZrvl4iFpv8rEA0V+qVdeMc/S
         O2Ezg0Eks0yeoL3Ed2O+y+wP+j5uCreWr5r29JAMHuxdSmHEGwcmuXUIGyMZGkVMWOJQ
         kLLK+NR9uu/3dePgEJIOxcR8mzMXeCfmgyqXwWlHLMqo1j7C+GYkh4ra9C7HmNKGfx/8
         SP/Y6tngJpZzcOZ9ZlhoEw7KyQNsmIwIlhuKPehjgQ5PC0qK4JQqW94oqZXON5Jtti8H
         vXmb1aBNbWUDieM4wA4djhm02CP0iwtNGjggDgOnbjburr/y9Rz1VqSWkhXZq81nrZ2b
         bWtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=65qi2Mgtrv2QRf0+fXUsTBcWY9go3PzfM5PG7vyohIo=;
        b=UHooSXPadP7oLb7t7cUD93eklyH77QBEswbYeJZvegnIvNTDkmt3JVYZNhxW4hu7cs
         23928bIjjtpbUC1S0/Owh3KB+uz4mSTWGDxCf36NKcbiYxo5YheI3E6wE9XWTcOmo7o5
         U6OTBlkmZZ2Hnu+d9ULnHUi5aJXnSF9PxNKA7FkobKafd7mj6phPj6S5VgG15W+r8IGk
         zRjQB3ZDEIppwh7VJ5m9j1IZ5+vpO867LjEJd+jb9Bpal3Y/ENio3GQnjHkoCcZyJB2s
         VaDHS04txF9P3Wwq1LNXOKkwcC9lVOirbkTGkv/5kTc9LfnpqB4Jk8ObNu4c4CA7Ljfx
         8RSw==
X-Gm-Message-State: APjAAAV/3rxzVNzqVUjYpBfoZv1YLuYMUJF7MHb46upQGdMZxQCz3B2C
        W/5IOpFFDKr7bv/rKwCOSgnLbro=
X-Google-Smtp-Source: APXvYqw/7sG33dwiy7uT/lQq6dA5FI/bZ6fe8rpl0fQqXgtEt0evugSDjvCvb5G34HapCnRC2EkoSQ==
X-Received: by 2002:a5d:899a:: with SMTP id m26mr33487067iol.268.1553806576150;
        Thu, 28 Mar 2019 13:56:16 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:15 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 09/25] SUNRPC: Add tracking of RPC level errors
Date:   Thu, 28 Mar 2019 16:52:23 -0400
Message-Id: <20190328205239.29674-10-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-9-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add variables to track RPC level errors so that we can distinguish
between issue that arose in the RPC transport layer as opposed to
those arising from the reply message.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h |  2 ++
 net/sunrpc/clnt.c            | 40 ++++++++++++++++++++++++------------
 net/sunrpc/xprtsock.c        |  1 +
 3 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0b7d333f624e..8ab942eb7c36 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -61,6 +61,8 @@ struct rpc_task {
 		struct rpc_wait		tk_wait;	/* RPC wait */
 	} u;
 
+	int			tk_rpc_status;	/* Result of last RPC operation */
+
 	/*
 	 * RPC call state
 	 */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3ab743c0e888..a9e5e81c67be 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1468,6 +1468,7 @@ static int
 __rpc_restart_call(struct rpc_task *task, void (*action)(struct rpc_task *))
 {
 	task->tk_status = 0;
+	task->tk_rpc_status = 0;
 	task->tk_action = action;
 	return 1;
 }
@@ -1510,6 +1511,19 @@ const char
 		return "no proc";
 }
 
+static void
+__rpc_call_rpcerror(struct rpc_task *task, int tk_status, int rpc_status)
+{
+	task->tk_rpc_status = rpc_status;
+	rpc_exit(task, tk_status);
+}
+
+static void
+rpc_call_rpcerror(struct rpc_task *task, int status)
+{
+	__rpc_call_rpcerror(task, status, status);
+}
+
 /*
  * 0.  Initial state
  *
@@ -1579,7 +1593,7 @@ call_reserveresult(struct rpc_task *task)
 
 		printk(KERN_ERR "%s: status=%d, but no request slot, exiting\n",
 				__func__, status);
-		rpc_exit(task, -EIO);
+		rpc_call_rpcerror(task, -EIO);
 		return;
 	}
 
@@ -1608,7 +1622,7 @@ call_reserveresult(struct rpc_task *task)
 				__func__, status);
 		break;
 	}
-	rpc_exit(task, status);
+	rpc_call_rpcerror(task, status);
 }
 
 /*
@@ -1684,7 +1698,7 @@ call_refreshresult(struct rpc_task *task)
 	}
 	dprintk("RPC: %5u %s: refresh creds failed with error %d\n",
 				task->tk_pid, __func__, status);
-	rpc_exit(task, status);
+	rpc_call_rpcerror(task, status);
 }
 
 /*
@@ -1741,7 +1755,7 @@ call_allocate(struct rpc_task *task)
 		return;
 	}
 	if (status != -ENOMEM) {
-		rpc_exit(task, status);
+		rpc_call_rpcerror(task, status);
 		return;
 	}
 
@@ -1810,7 +1824,7 @@ call_encode(struct rpc_task *task)
 			task->tk_action = call_refresh;
 			break;
 		default:
-			rpc_exit(task, task->tk_status);
+			rpc_call_rpcerror(task, task->tk_status);
 		}
 		return;
 	} else {
@@ -1950,7 +1964,7 @@ call_bind_status(struct rpc_task *task)
 				task->tk_pid, -task->tk_status);
 	}
 
-	rpc_exit(task, status);
+	rpc_call_rpcerror(task, status);
 	return;
 
 retry_timeout:
@@ -1986,7 +2000,7 @@ call_connect(struct rpc_task *task)
 	if (task->tk_status < 0)
 		return;
 	if (task->tk_flags & RPC_TASK_NOCONNECT) {
-		rpc_exit(task, -ENOTCONN);
+		rpc_call_rpcerror(task, -ENOTCONN);
 		return;
 	}
 	if (!xprt_prepare_transmit(task))
@@ -2047,7 +2061,7 @@ call_connect_status(struct rpc_task *task)
 		call_transmit(task);
 		return;
 	}
-	rpc_exit(task, status);
+	rpc_call_rpcerror(task, status);
 	return;
 out_retry:
 	/* Check for timeouts before looping back to call_bind */
@@ -2138,7 +2152,7 @@ call_transmit_status(struct rpc_task *task)
 			if (!task->tk_msg.rpc_proc->p_proc)
 				trace_xprt_ping(task->tk_xprt,
 						task->tk_status);
-			rpc_exit(task, task->tk_status);
+			rpc_call_rpcerror(task, task->tk_status);
 			return;
 		}
 		/* fall through */
@@ -2301,7 +2315,7 @@ call_status(struct rpc_task *task)
 	rpc_check_timeout(task);
 	return;
 out_exit:
-	rpc_exit(task, status);
+	rpc_call_rpcerror(task, status);
 }
 
 static bool
@@ -2325,7 +2339,7 @@ rpc_check_timeout(struct rpc_task *task)
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
-		rpc_exit(task, -ETIMEDOUT);
+		rpc_call_rpcerror(task, -ETIMEDOUT);
 		return;
 	}
 
@@ -2336,9 +2350,9 @@ rpc_check_timeout(struct rpc_task *task)
 				task->tk_xprt->servername);
 		}
 		if (task->tk_flags & RPC_TASK_TIMEOUT)
-			rpc_exit(task, -ETIMEDOUT);
+			rpc_call_rpcerror(task, -ETIMEDOUT);
 		else
-			rpc_exit(task, -EIO);
+			__rpc_call_rpcerror(task, -EIO, -ETIMEDOUT);
 		return;
 	}
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b4b4b8db143c..c69951ed2ebc 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2017,6 +2017,7 @@ static void xs_local_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		 * we'll need to figure out how to pass a namespace to
 		 * connect.
 		 */
+		task->tk_rpc_status = -ENOTCONN;
 		rpc_exit(task, -ENOTCONN);
 		return;
 	}
-- 
2.20.1

