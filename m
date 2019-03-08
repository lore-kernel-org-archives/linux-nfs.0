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
	by smtp.lore.kernel.org (Postfix) with ESMTP id F031FC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B96C820675
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y/7wgoAz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726264AbfCHArg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 19:47:36 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:40964 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726227AbfCHArg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 19:47:36 -0500
Received: by mail-io1-f66.google.com with SMTP id 9so15332227iog.8
        for <linux-nfs@vger.kernel.org>; Thu, 07 Mar 2019 16:47:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vQhmTHL1q22DHQ7kf5/imWg6RVCD51JVSyNbLoonwCM=;
        b=Y/7wgoAzexIkMJUf4WY+RvWomcEL6Ij1hINsgExaIE67g4FxayjAnCPq497vBT0XyJ
         yA4Svgql2O9pgsby6fvueH/gZR9VbjgVOMhEnhJ0SQKtRHXHrujIhsfy6ph4/L8PzEnx
         RnmrVUT62Ct7U9CXOyuJx+b6ULTV7DqGsQrAe4xWXliXkT5FDZeisJQDL0uKpQ1vq5KB
         Uz49Q0jItYiWUdLT4jPw68VeMNi7VsXCgCjdbuQ63qW7lhPoDcebjgAZDnebtP/wBrzs
         8MIymoLcV5QmCvxu6S0QXbtAJ9qoYfshajqeD4MxK47jxO+QEfk4th2W6wWjBEN02ytk
         4iEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vQhmTHL1q22DHQ7kf5/imWg6RVCD51JVSyNbLoonwCM=;
        b=gOdcU1b2+y3nSLLcSBSFyMY3O6QYySRzOKLZAB7kKZcdAz6h6O7uIoJ1TJqF/mbBF+
         YG/k808Jp+uPt5O0wHZaKrQnOUr63uqSLTf2lPnl1dTk5v+wLDut6Wc9J8YXrglAjYKA
         oHBwlGMulNNf1AjX1+sfQ9swFHcEtGEyDtMASihDbN+eF1/R3vjG0OzSwZSzpcZToqMw
         3t44ohX8H9fWDwsJ7Rfh2FYZXveDEENuOqaiun2H96/6fuGVr4MTkvER54AP/c5Rye5O
         zdrYVslTerI0DQC6+iOenGjkLY1MfTJXESQbPaduj25WEpOv5hf+h6DfEE18l+0CTJhU
         TxSg==
X-Gm-Message-State: APjAAAV9vkrpjFxxt527wD3A0iBNAZaRKI5sqBEpHyqXqhBVOmTAbuH4
        mpNIdSRwjCM5tAZvpbJ0yn4Wv6I=
X-Google-Smtp-Source: APXvYqyN0D3WlS+2nigYFGu37GWfmfKqxzJzfK7yNJWiLBDoDsyz6MqC2V6UrUY0m+s4vlR+csAkrQ==
X-Received: by 2002:a5e:8701:: with SMTP id y1mr8932930ioj.78.1552006054261;
        Thu, 07 Mar 2019 16:47:34 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r65sm3278223itb.19.2019.03.07.16.47.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 16:47:31 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/3] SUNRPC: Prevent thundering herd when the socket is not connected
Date:   Thu,  7 Mar 2019 19:46:21 -0500
Message-Id: <20190308004623.10618-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the socket is not connected, then we want to initiate a reconnect
rather that trying to transmit requests. If there is a large number
of requests queued and waiting for the lock in call_transmit(),
then it can take a while for one of the to loop back and retake
the lock in call_connect.

Fixes: 89f90fe1ad8b ("SUNRPC: Allow calls to xprt_transmit() to drain...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 241e8423fd0c..7ab4da342ab5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1807,7 +1807,12 @@ call_encode(struct rpc_task *task)
 		xprt_request_enqueue_receive(task);
 	xprt_request_enqueue_transmit(task);
 out:
-	task->tk_action = call_bind;
+	task->tk_action = call_transmit;
+	/* Check that the connection is OK */
+	if (!xprt_bound(task->tk_xprt))
+		task->tk_action = call_bind;
+	else if (!xprt_connected(task->tk_xprt))
+		task->tk_action = call_connect;
 }
 
 /*
@@ -1999,13 +2004,19 @@ call_transmit(struct rpc_task *task)
 {
 	dprint_status(task);
 
-	task->tk_status = 0;
+	task->tk_action = call_transmit_status;
 	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
 		if (!xprt_prepare_transmit(task))
 			return;
-		xprt_transmit(task);
+		task->tk_status = 0;
+		if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+			if (!xprt_connected(task->tk_xprt)) {
+				task->tk_status = -ENOTCONN;
+				return;
+			}
+			xprt_transmit(task);
+		}
 	}
-	task->tk_action = call_transmit_status;
 	xprt_end_transmit(task);
 }
 
@@ -2067,6 +2078,8 @@ call_transmit_status(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOTCONN:
 	case -EPIPE:
+		task->tk_action = call_bind;
+		task->tk_status = 0;
 		break;
 	}
 }
-- 
2.20.1

