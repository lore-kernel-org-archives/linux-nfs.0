Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7891C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E0BB20660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:57:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BlkYpza8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E0BB20660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726078AbeLAJHq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:07:46 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:36299 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAJHq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 04:07:46 -0500
Received: by mail-it1-f194.google.com with SMTP id c9so699199itj.1
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:57:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=BlkYpza8CS1/h4wAi8JoRGG5FyM0HbDi0501RZHvp2ODNuKDfuvk8SAr8C2FQ28mWY
         ASvPMypTg+ilropuDV8fT3+3ZHOPJvgOIN3cPiu3doz12fZrHxCp6Unr/ATkwV5FvVvO
         2FVomdSEUUoP/khusHhXAHV9aj14X0yPZR0obnEqDUN4v/1YnMzerVE8yz0NJVX3dmFw
         JHlgsplEuckry2l7CIpi5JflS/y35TmC7X7+OSo7jy+Zh7htsgNFsQPVeCe1wJBmisfa
         o4xcdpXNCSjs44hRBF3WH+AYLCK6q707D/2812Tptbjl81bZHJdJYiAMX5cYpe/Ugmtv
         kQWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=QDhr+GCsnCzkP2Vks75ji0GTGgNCypahBFur0LgvDfT5ARpYS86dYlcAIJdH7Lwh9+
         mKbv4Ivlbw0xn7xWETeEF8jYbY01i9u/CwFmGWrHwVTis7qoMdqL0wEj+jMZD7GwaTGr
         ScBb7771MYitR7mmBI3t2FAp/45BAgoX0jghmbkQS2sAXdNHP+2CBxlxkblgtcUlb2XI
         SyyuHzMgZ7UxuKvBo0we2wDXMoh8AHvPBNaekRKLjLUileGAe1crAWbyAKemrMH/lzu1
         U7xrAJQEen+ofkJHSEt7TsmHTdHppYIetWR6IJEB5eTTm8iI8pKO8JNUhnZtfvC2Lk4v
         TaMA==
X-Gm-Message-State: AA+aEWZ3Xxd0lOA6niHCV8uG6dlcPvF4KJfl9Qj+sh6ewgGVOpGMnmRs
        +aztbI28gu6ZmGqiAIS1NG07YpA=
X-Google-Smtp-Source: AFSGD/UVxupUjLc9VH6pGOh9qJPFa+/M14yZcES0xei+R3lcBCmjqH4DyI9HkicFapaMuMMbPaeMmA==
X-Received: by 2002:a24:2c1:: with SMTP id 184-v6mr464662itu.100.1543615023503;
        Fri, 30 Nov 2018 13:57:03 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id z23sm2659119iob.19.2018.11.30.13.57.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:57:02 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/3] SUNRPC: call_connect_status() must handle tasks that got transmitted
Date:   Fri, 30 Nov 2018 16:55:53 -0500
Message-Id: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a task failed to get the write lock in the call to xprt_connect(), then
it will be queued on xprt->sending. In that case, it is possible for it
to get transmitted before the call to call_connect_status(), in which
case it needs to be handled by call_transmit_status() instead.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ae3b8145da35..e35d642558e7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1915,6 +1915,13 @@ call_connect_status(struct rpc_task *task)
 	struct rpc_clnt *clnt = task->tk_client;
 	int status = task->tk_status;
 
+	/* Check if the task was already transmitted */
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		xprt_end_transmit(task);
+		task->tk_action = call_transmit_status;
+		return;
+	}
+
 	dprint_status(task);
 
 	trace_rpc_connect_status(task);
-- 
2.19.2

