Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD7A5C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9E44021850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XcMZjOOX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726679AbfC1U4V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:21 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:55236 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726248AbfC1U4U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:20 -0400
Received: by mail-it1-f196.google.com with SMTP id w18so443612itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m7bjq1cHvI8y4UsWwuG6ENQSOhjMIBfuta9Msrttj4s=;
        b=XcMZjOOXaFYa+vJD/VdB8Eh3SW7JaEAQbBHrqFGiXQPx20YgJSLqvNK8632dy88C3b
         v/bmL4kqJUYRiDLaxPJL85MRDck2TYlIH0qtws7vW58REtrH+fveZbIi9641Avzu98wH
         iOqACuunT9A565ofvLl5arqLBb1NJ94jjrRozu0dF/zgd0EUTERxPRfjFHn5cWNycgM1
         qvLjU0w5oNuVQ5u2cMethTzVtwD/X1B76coI9HoPomUl4bS5six64SQjBHZw2s+Hzs5t
         yqOMgiiciXagLYWxTspCjZW21OkOP6de5TDDM8ft4O997Y8VxJQWaKnqFAGjUVczwao7
         UMBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=m7bjq1cHvI8y4UsWwuG6ENQSOhjMIBfuta9Msrttj4s=;
        b=UX7lSaHMjwNqNa3Ac7t48qpgmk58U0bMiRpPPMhq0A1DTZUbFYe8J/HY8HLiU//fMh
         Cor9L9CWkTBqptzhW1+1HnjoOkQawivmfdK+w03tWM2MwzKi/okU2D2LgNtQuyklSFP7
         +QgZDQxncFK22qd/j2cuTCoIies8eMndX773sxkHCm1vBCAf2GBj7nJSd+v5O5UPpNgw
         G3TvDQnITWv+ag0fqNro9mmp1HfJTi3WJj5gjqm9qZ6A40M+uEA8kY0RDGrrMNqro8z5
         ClRVZnXRspP5Lxc+8CtyGTQxscUK19cmxejux0hsqgBZrA4G/SUgPzPZ8tSGAEMDYryl
         ut3A==
X-Gm-Message-State: APjAAAXibHygHzF5Qm8BG3C5Jz67JKURu40emur5R8gIy2yZaD6yoNzD
        08ZR2/CVhr0+o8yPnTYdSncx6PM=
X-Google-Smtp-Source: APXvYqzyf1vJHJGTbv9YN2ILcva4vpfeBCPVFyZe9lmYJeCyb2dNq0kLzTFPyC405k/P+xpPRlZQwQ==
X-Received: by 2002:a24:424a:: with SMTP id i71mr1854629itb.135.1553806579014;
        Thu, 28 Mar 2019 13:56:19 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:18 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 12/25] SUNRPC: Add the 'softerr' rpc_client flag
Date:   Thu, 28 Mar 2019 16:52:26 -0400
Message-Id: <20190328205239.29674-13-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-12-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add the 'softerr' rpc client flag that sets the RPC_TASK_TIMEOUT
flag on all new rpc tasks that are attached to that rpc client.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/clnt.h | 2 ++
 net/sunrpc/clnt.c           | 8 +++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 98bc9883b230..943762acfcd4 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -50,6 +50,7 @@ struct rpc_clnt {
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
+				cl_softerr  : 1,/* Timeouts return errors */
 				cl_discrtry : 1,/* disconnect before retry */
 				cl_noretranstimeo: 1,/* No retransmit timeouts */
 				cl_autobind : 1,/* use getport() */
@@ -144,6 +145,7 @@ struct rpc_add_xprt_test {
 #define RPC_CLNT_CREATE_INFINITE_SLOTS	(1UL << 7)
 #define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 8)
 #define RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT	(1UL << 9)
+#define RPC_CLNT_CREATE_SOFTERR		(1UL << 10)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d943566a06b2..a46199251151 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -484,8 +484,11 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 	}
 
 	clnt->cl_softrtry = 1;
-	if (args->flags & RPC_CLNT_CREATE_HARDRTRY)
+	if (args->flags & (RPC_CLNT_CREATE_HARDRTRY|RPC_CLNT_CREATE_SOFTERR)) {
 		clnt->cl_softrtry = 0;
+		if (args->flags & RPC_CLNT_CREATE_SOFTERR)
+			clnt->cl_softerr = 1;
+	}
 
 	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
 		clnt->cl_autobind = 1;
@@ -623,6 +626,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	/* Turn off autobind on clones */
 	new->cl_autobind = 0;
 	new->cl_softrtry = clnt->cl_softrtry;
+	new->cl_softerr = clnt->cl_softerr;
 	new->cl_noretranstimeo = clnt->cl_noretranstimeo;
 	new->cl_discrtry = clnt->cl_discrtry;
 	new->cl_chatty = clnt->cl_chatty;
@@ -1001,6 +1005,8 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (clnt->cl_softerr)
+			task->tk_flags |= RPC_TASK_TIMEOUT;
 		if (clnt->cl_noretranstimeo)
 			task->tk_flags |= RPC_TASK_NO_RETRANS_TIMEOUT;
 		if (atomic_read(&clnt->cl_swapper))
-- 
2.20.1

