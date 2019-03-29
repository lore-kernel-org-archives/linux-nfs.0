Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0862C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 97EF52184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qp2JxkMz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730353AbfC2WCL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:11 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:40175 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730345AbfC2WCK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:10 -0400
Received: by mail-io1-f67.google.com with SMTP id d201so2986347iof.7
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uwZFtudjPJpcLf+agJX+83JrXTBVJ0C9DPLRNaWadmQ=;
        b=Qp2JxkMzsJIVkmpRcfknt4Vuo2xH94/oVg3kdDd58BjzTlDw6+MBRD2RmAIQWpsAbU
         6QqlydLCJQbgOoU9EPMMnZKys2bvOxuMdgCBAoGnmOgPUxTaksT8kU1lsnlek3LCQ14T
         YVD17hbbl+Ye2LH7mqBv8HYPs2bKMn1giDMrBer14vteZ68KBBJqG6opENphDSIglGLh
         4nOvScOkT7Jj21NOLhyQI8n6hy5jWlKhK22U/I3ONjcV85MZwqzZftpO/B2YVrU44MoV
         0GG7Mcwzfxcadj60iWOCv50+xUvBZPU0MqWdVGBUSw43BvKoYKwP3zQV4i6phWbItoV/
         RNqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=uwZFtudjPJpcLf+agJX+83JrXTBVJ0C9DPLRNaWadmQ=;
        b=qEi7Ne389Tl5IoPgJ1KJng5F65QJNbsW6sZGiBQA4CKJAu4WSErjpMUobwDg6naXHc
         GRQiIb4OX9LlUUMkpA+g8aTybbjBUJ2WaSKAdAAEND6PKq9WOw0w2daYlWFsOzM+HqPM
         MWpg1z9pPUoQV8X1ns7++3qouh866R50QGCFmF0WMklB6ApPJbt44wK/LWBfOjGukLqQ
         aovwDfg9XcKDYP1gB+BvxvI4v3RfFQF+vX45PCcMHiMalkGDOsFykiJUe+4z1zGpNGPI
         FNyJgHrJf9SmSXvCR7yBx4frkT6e0rqsu3iHLzhFZJgidc+1c7CDL+u56L1t2/KwVJ7N
         jCYQ==
X-Gm-Message-State: APjAAAVt97j+Ej8sRnCIE/4K22Yk1XO/OzSNdqa6lF8yLG3VYxI29McH
        XDfGQW6Vy9pziofaCok73pumNGo=
X-Google-Smtp-Source: APXvYqx7XAi1a1Od856yx/QpdXEz+sa9nGDqVT0GXCNjrwdaT/AjBhhCe/cXZT273OLfxdwHbTRPZg==
X-Received: by 2002:a5e:9b17:: with SMTP id j23mr1161118iok.60.1553896929308;
        Fri, 29 Mar 2019 15:02:09 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:08 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 15/28] SUNRPC: Add the 'softerr' rpc_client flag
Date:   Fri, 29 Mar 2019 17:59:35 -0400
Message-Id: <20190329215948.107328-16-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-15-trond.myklebust@hammerspace.com>
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
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
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
index c0b79d307579..fb809e1912e3 100644
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

