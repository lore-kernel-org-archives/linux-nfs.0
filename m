Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42774C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11D8B20675
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FXV44NW4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726267AbfCHAri (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 19:47:38 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:40494 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726248AbfCHAri (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 19:47:38 -0500
Received: by mail-it1-f194.google.com with SMTP id l139so18907101ita.5
        for <linux-nfs@vger.kernel.org>; Thu, 07 Mar 2019 16:47:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GOLejrKBaBKNwAD9Yjefk59wxxyUttb+EopuXTNkvY4=;
        b=FXV44NW4jSZX0UG/IRFPVk0JRMtruog52z54K4fZKjpW5pU9mAgQOV6KMPnYbBnZs1
         vZA869tSP4aQMLgW974RHUoIx6uz4gEWj3cewdxo6dzCUSulaosyfWUrE9A9fYQxvWdL
         OF6lZ/FtF6nxWMBZ/L2kiKvhF1EBoMlnJvlpgqseVq6WdjdIVc8dmvyI3T/TeztXIs8D
         lkJ4/mkZvZ3ghXFFsh+Uf8DIv+LoFF3PvPFO24qEbUF5THqG4G1mtFz6jts4wQ0JvJCl
         jJaoQ5QgZooPCDOQQ8/j6W3gC9d3RDTjpfb08pKGFJJKTsX4DGWT37XYTFZyNHBEw7IV
         HXHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=GOLejrKBaBKNwAD9Yjefk59wxxyUttb+EopuXTNkvY4=;
        b=X1HALNo7jPYGfetCac+BaC3AZ6QqmLkn9ZuDim5xSjEIGsIps8J27EZjfSSBKe8bcn
         lsLr+GfnlCS6rYRq2Rh+xaYaYGmXcEDKhkLfO0surC85bcYekYPktEkLC7+zlC/vcM0c
         33BFsZ8qRczQ/vz31DxG3fwTBp2poJS497dIPmQBAIk0or340NaVt8ZYdnd8AMZdjK0C
         BDJXQqQ5WcstlsrQVEn+kKrLf9PUBe0MJVDCDSzQbS6van2KztNoDvd8VY0DEj44BzeW
         ThuuOUBbIRV2lm89wewQ1NdpTHc34NoexCjZz6lyBHn22k4XnsuHW8C1wcXyjZp0uBtD
         bglQ==
X-Gm-Message-State: APjAAAXDIe7F7IgSMODT5J/xwDiMEJtpx9NQD4tTyYy/oRRe4oJZLo3D
        CcwV6zybDpKm7LbnlJd1WAclf5k=
X-Google-Smtp-Source: APXvYqw4YtWHDfX9uQ5xx3zoShWCjaASt9IIAia7TkWgORFgg4xuNzrwFbS4nTtBuKfAFoEw/e7Lcg==
X-Received: by 2002:a24:6b57:: with SMTP id v84mr5527498itc.145.1552006056555;
        Thu, 07 Mar 2019 16:47:36 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r65sm3278223itb.19.2019.03.07.16.47.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 16:47:35 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] SUNRPC: Respect RPC call timeouts when retrying transmission
Date:   Thu,  7 Mar 2019 19:46:23 -0500
Message-Id: <20190308004623.10618-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190308004623.10618-2-trond.myklebust@hammerspace.com>
References: <20190308004623.10618-1-trond.myklebust@hammerspace.com>
 <20190308004623.10618-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix a regression where soft and softconn requests are not timing out
as expected.

Fixes: 89f90fe1ad8b ("SUNRPC: Allow calls to xprt_transmit() to drain...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 42 ++++++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b9558e10c6c1..311029b7c33a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -79,6 +79,7 @@ static int	rpc_encode_header(struct rpc_task *task,
 static int	rpc_decode_header(struct rpc_task *task,
 				  struct xdr_stream *xdr);
 static int	rpc_ping(struct rpc_clnt *clnt);
+static void	rpc_check_timeout(struct rpc_task *task);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
 {
@@ -1962,8 +1963,7 @@ call_connect_status(struct rpc_task *task)
 			break;
 		if (clnt->cl_autobind) {
 			rpc_force_rebind(clnt);
-			task->tk_action = call_bind;
-			return;
+			goto out_retry;
 		}
 		/* fall through */
 	case -ECONNRESET:
@@ -1983,16 +1983,19 @@ call_connect_status(struct rpc_task *task)
 		/* fall through */
 	case -ENOTCONN:
 	case -EAGAIN:
-		/* Check for timeouts before looping back to call_bind */
 	case -ETIMEDOUT:
-		task->tk_action = call_timeout;
-		return;
+		goto out_retry;
 	case 0:
 		clnt->cl_stats->netreconn++;
 		task->tk_action = call_transmit;
 		return;
 	}
 	rpc_exit(task, status);
+	return;
+out_retry:
+	/* Check for timeouts before looping back to call_bind */
+	task->tk_action = call_bind;
+	rpc_check_timeout(task);
 }
 
 /*
@@ -2069,7 +2072,7 @@ call_transmit_status(struct rpc_task *task)
 				trace_xprt_ping(task->tk_xprt,
 						task->tk_status);
 			rpc_exit(task, task->tk_status);
-			break;
+			return;
 		}
 		/* fall through */
 	case -ECONNRESET:
@@ -2081,6 +2084,7 @@ call_transmit_status(struct rpc_task *task)
 		task->tk_status = 0;
 		break;
 	}
+	rpc_check_timeout(task);
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
@@ -2217,7 +2221,7 @@ call_status(struct rpc_task *task)
 	case -EPIPE:
 	case -ENOTCONN:
 	case -EAGAIN:
-		task->tk_action = call_encode;
+		task->tk_action = call_timeout;
 		break;
 	case -EIO:
 		/* shutdown or soft timeout */
@@ -2231,20 +2235,13 @@ call_status(struct rpc_task *task)
 	}
 }
 
-/*
- * 6a.	Handle RPC timeout
- * 	We do not release the request slot, so we keep using the
- *	same XID for all retransmits.
- */
 static void
-call_timeout(struct rpc_task *task)
+rpc_check_timeout(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	if (xprt_adjust_timeout(task->tk_rqstp) == 0) {
-		dprintk("RPC: %5u call_timeout (minor)\n", task->tk_pid);
-		goto retry;
-	}
+	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
+		return;
 
 	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
 	task->tk_timeouts++;
@@ -2280,10 +2277,19 @@ call_timeout(struct rpc_task *task)
 	 * event? RFC2203 requires the server to drop all such requests.
 	 */
 	rpcauth_invalcred(task);
+}
 
-retry:
+/*
+ * 6a.	Handle RPC timeout
+ * 	We do not release the request slot, so we keep using the
+ *	same XID for all retransmits.
+ */
+static void
+call_timeout(struct rpc_task *task)
+{
 	task->tk_action = call_encode;
 	task->tk_status = 0;
+	rpc_check_timeout(task);
 }
 
 /*
-- 
2.20.1

