Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8986FC10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 568AD2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f8T9rrOa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730335AbfC2WCH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:07 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:40178 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730303AbfC2WCH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:07 -0400
Received: by mail-it1-f195.google.com with SMTP id y63so6249888itb.5
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=szWV0bEh14Y2lXFOW2CRvIr0pG73kCQUhlaPoTMI8Nk=;
        b=f8T9rrOadfCi6x3vdaUsXKlGZblUeXKt4MB8XJTlMFZcL6xpnbLQxxXUbCPsPxllSB
         j9IGwLip1nTS46lEcqCUKeoO9hz/CbUR8oHtO/fXBCz2WC54Ioi+eiGC9DuhZZUZSbNY
         NDE86wSija9pOxqah/oM/FstX7wb1WCcjxeeAgdk/A+pguz9J7mLX4jJGcjNB+eqXi2F
         5g/Y3w2Q/kaRQhrsvG1tV690EJbWdlr5loMZdiygahYS6veaAv9gJMbubfKo5dVb0YrE
         iyATXvOUmv0PQ8VbS7wVxilJ07k3rRUvv6ApFunjWIfeYg35cMpwr31iyDC6oQ+hoX8O
         m+ag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=szWV0bEh14Y2lXFOW2CRvIr0pG73kCQUhlaPoTMI8Nk=;
        b=tSOhiiPmLP3I88gtnpq5b8kC2mXsOqqLfh43rQBbFYMqhxn5Xo4H6JFv6L9EHa7fRh
         O+Ol1IWO9ZZVTIBOuto3Q4vdTSk3ZZSJK2r3qAHByn8zrG4HUFLwDGJxXR8Cpj3+DaWU
         3cPClQ5HM4s4GZ6ipy81NxYDrRjpBilkWfaaBm2eIPja9wMfjw6YArfYUIVeFqDzmFxf
         DDJDED+8Hgcm/fmRiEQ/bDOyo9WkjQT4xdyP2u0rfZuTmMXhpgdFoMWptEdhikNR15Nm
         rv0PAMJ+zJpz+5ePuE98ZM8l5EKPH5jPkpdPzYORaCw4SM0Aa2crWwes8mimJI3VvwWY
         gUPQ==
X-Gm-Message-State: APjAAAUOrOijy5Am05CLfvsTOK2xfh8xosQcvHU8CQYO4pSRtKX6SzAO
        rDTD8TwZt0+uJjbleSksP6uKEqI=
X-Google-Smtp-Source: APXvYqymr4dH4aaI6EnpIpv29zv70jKXw77G5bUi+uhp6NzhipbXvG2UHh1GCLsWE4FSTAA4enr7kA==
X-Received: by 2002:a24:4290:: with SMTP id i138mr6444200itb.24.1553896925365;
        Fri, 29 Mar 2019 15:02:05 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:04 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 11/28] SUNRPC: Add tracking of RPC level errors
Date:   Fri, 29 Mar 2019 17:59:31 -0400
Message-Id: <20190329215948.107328-12-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-11-trond.myklebust@hammerspace.com>
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
index c41f5f498b3b..f01990c6423d 100644
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

