Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 600D4C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A92620652
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TqkIx/bI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727053AbfCKBbH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 21:31:07 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:35191 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726901AbfCKBbH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 21:31:07 -0400
Received: by mail-io1-f68.google.com with SMTP id x4so2619698ion.2
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 18:31:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=QapxjmDMh3e4kgR0jm5KZjvtjNP0u9f3AxHVvc9E+i0=;
        b=TqkIx/bIcQQFsSAumIE0MACcw3yrU8XuEbbriU4ZeOAUqypoPlHSJeoPCU/TD65NmU
         2UjRkCVal7ODI/On0uXhcVNeKSsZjay9Xnzh6CIbHPioRMnO0gK7rzb1Vn/ZvFvTcPuA
         4MwP1BQTKKVsGpEczh4yAcAYNn19TzjuY/qjuhVEitqoSTqg8/h33oDVSZ4anizjUsIK
         4RkfFMTaEDhwdYm0JnhJG0Ze95tE2OJmpE3TUqQl6jexLqDjJqL3Y+B2m9XDccQnXVJB
         77jGef5eHbnP4HriRw2u28MhH1XgmDqJ8s0Fzsq2Wb5M3bJzI0KGHrQtXvYcANVLVwB/
         RkJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=QapxjmDMh3e4kgR0jm5KZjvtjNP0u9f3AxHVvc9E+i0=;
        b=H69zSXAz4ycjWyOB2jmxvMjH15HZ5/XB7HGArDn9JnbS3Nz1Nks1jTv+4bgfUR7oSg
         apQDnUJpHI75f22lZbM6ZsRcFD0KFaqlTtEkbhqXkcgE7TR7Zgbf69hCMvAS3SMTxuR6
         K9sufy5QAc+Tn3zVqKxuHfrAncVEI6IRb8Uif/B0sTJO6ztlG/LUR8owMCx925zTgToA
         lktmMtHbpf1VqO78kWu5xXvTlTP0o0cFTa7xNME+fLXaIRQXGVcXCqnjcrpjX2Q4BNBj
         wUCswdc3lUb0poN2n7oqQZ/ZTArkLr3/iuJKgTRGIPKb2PWSInKiWh46YFa1Mjsnoc/s
         8wyA==
X-Gm-Message-State: APjAAAWoeQ7sSSPD/u698la6i1tvosCEGtGiIEsF92YchV5OEA1wBM/r
        Z7iwwMG/Fk1RFKqjcIoZ6QibuZ0=
X-Google-Smtp-Source: APXvYqzNtAZsf46CuXGN4gtcAgfaBlC2S/z8L7n/RZX3ksQsRDC83WyzBRUA1cyUgzbwiag82tjdnw==
X-Received: by 2002:a6b:c544:: with SMTP id v65mr14685381iof.222.1552267865435;
        Sun, 10 Mar 2019 18:31:05 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id p79sm7515011itb.7.2019.03.10.18.31.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 18:31:04 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] SUNRPC: Clean up
Date:   Sun, 10 Mar 2019 21:29:53 -0400
Message-Id: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Replace remaining callers of call_timeout() with rpc_check_timeout().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 47 ++++++++++++++---------------------------------
 1 file changed, 14 insertions(+), 33 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 311029b7c33a..a0e7322fc171 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -70,7 +70,6 @@ static void	call_status(struct rpc_task *task);
 static void	call_transmit_status(struct rpc_task *task);
 static void	call_refresh(struct rpc_task *task);
 static void	call_refreshresult(struct rpc_task *task);
-static void	call_timeout(struct rpc_task *task);
 static void	call_connect(struct rpc_task *task);
 static void	call_connect_status(struct rpc_task *task);
 
@@ -1908,7 +1907,8 @@ call_bind_status(struct rpc_task *task)
 
 retry_timeout:
 	task->tk_status = 0;
-	task->tk_action = call_timeout;
+	task->tk_action = call_encode;
+	rpc_check_timeout(task);
 }
 
 /*
@@ -2197,10 +2197,8 @@ call_status(struct rpc_task *task)
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
 	case -EPERM:
-		if (RPC_IS_SOFTCONN(task)) {
-			rpc_exit(task, status);
-			break;
-		}
+		if (RPC_IS_SOFTCONN(task))
+			goto out_exit;
 		/*
 		 * Delay any retries for 3 seconds, then handle as if it
 		 * were a timeout.
@@ -2208,7 +2206,6 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 		/* fall through */
 	case -ETIMEDOUT:
-		task->tk_action = call_timeout;
 		break;
 	case -ECONNREFUSED:
 	case -ECONNRESET:
@@ -2221,18 +2218,21 @@ call_status(struct rpc_task *task)
 	case -EPIPE:
 	case -ENOTCONN:
 	case -EAGAIN:
-		task->tk_action = call_timeout;
 		break;
 	case -EIO:
 		/* shutdown or soft timeout */
-		rpc_exit(task, status);
-		break;
+		goto out_exit;
 	default:
 		if (clnt->cl_chatty)
 			printk("%s: RPC call returned error %d\n",
 			       clnt->cl_program->name, -status);
-		rpc_exit(task, status);
+		goto out_exit;
 	}
+	task->tk_action = call_encode;
+	rpc_check_timeout(task);
+	return;
+out_exit:
+	rpc_exit(task, status);
 }
 
 static void
@@ -2279,19 +2279,6 @@ rpc_check_timeout(struct rpc_task *task)
 	rpcauth_invalcred(task);
 }
 
-/*
- * 6a.	Handle RPC timeout
- * 	We do not release the request slot, so we keep using the
- *	same XID for all retransmits.
- */
-static void
-call_timeout(struct rpc_task *task)
-{
-	task->tk_action = call_encode;
-	task->tk_status = 0;
-	rpc_check_timeout(task);
-}
-
 /*
  * 7.	Decode the RPC reply
  */
@@ -2329,16 +2316,8 @@ call_decode(struct rpc_task *task)
 	WARN_ON(memcmp(&req->rq_rcv_buf, &req->rq_private_buf,
 				sizeof(req->rq_rcv_buf)) != 0);
 
-	if (req->rq_rcv_buf.len < 12) {
-		if (!RPC_IS_SOFT(task)) {
-			task->tk_action = call_encode;
-			goto out_retry;
-		}
-		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
-				clnt->cl_program->name, task->tk_status);
-		task->tk_action = call_timeout;
+	if (req->rq_rcv_buf.len < 12)
 		goto out_retry;
-	}
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf,
 			req->rq_rcv_buf.head[0].iov_base, req);
@@ -2361,6 +2340,8 @@ call_decode(struct rpc_task *task)
 				xprt_conditional_disconnect(req->rq_xprt,
 							    req->rq_connect_cookie);
 		}
+		task->tk_action = call_encode;
+		rpc_check_timeout(task);
 	}
 }
 
-- 
2.20.1

