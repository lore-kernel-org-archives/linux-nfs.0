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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52E07C65BAE
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 17B2520660
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:19:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Um0RbNfx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B2520660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726554AbeLAIad (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:30:33 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52323 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAIad (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:30:33 -0500
Received: by mail-it1-f196.google.com with SMTP id i7so630729iti.2
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:19:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=Um0RbNfxYjF4VHQF8YY6NsBKaELVqpqu8bjWjL0K+LPu20E9IJXbC236b8GUqJMayi
         Wedz6PszLujV9bJICXpzZmO2xI27kJF/WIqYgFVj4Ej2sJGgxPEJAVkmKZX4kfjiHFuW
         5vppugSndC9CgCVOvKDCeE+ECARjANkPejjDAGZGjdMAkc4o/60TLpHgXEkU5mKKXJcA
         Rw8QWOt7B6ntJgJEKIz98r3afBkC3poN8JBOExuIvxS6G70eSAlwTQ6vqHYkrnQtOzmk
         geu/IfEUg8nCCYuPM20a5tOx+PUuLzO1heRQJstlftF8LWXYj40b/MQ9ECH7xZWv00fa
         rFrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=BwG8E2OlVpt0hPV/xM3iu7QpfiLtnNZt5eQ50jIfyK1Dz3ryf3sJ/52ER66X8EHdLb
         ihBgTpypqPYNQft06wjiskBfauuLKyUqYVv/qPnZtVC22wdatmHIhXOnV0os5VJT/k08
         94/SrQZMjyQZxXqLo3N9DMQ+G8e4nmmB4hbVBE2XUqH6TIeaS8ZeQL5vNvRpQhW8tlI2
         /BGdjcL20846KBi0ajH4nRFUU/p6QP6R4+2DlOUvec2OI1fXD0ld/gLp9kS/e5iQcVJ/
         mDvGKuTuyfiITNRars30cfEivjgJvTdWBqWAk1OKxO7pPdZAKmjI9QFNpijFPsayByVE
         VPMQ==
X-Gm-Message-State: AA+aEWZ+IIwMefVxRacvxVob62BT4dibqwXkq+zoZgQ1ncZCNQ6PGktN
        TB6jMmkmYuLZSslFH6A2ng==
X-Google-Smtp-Source: AFSGD/Xao63mfvz4++VOGb4qcblrHp0cLcBLi6Ok7ZIURbcIkKkg7tOKchrtvQNHXH0LepbEHdGQ5Q==
X-Received: by 2002:a24:b604:: with SMTP id g4-v6mr349802itf.119.1543612795755;
        Fri, 30 Nov 2018 13:19:55 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id y1sm141393itb.29.2018.11.30.13.19.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:19:54 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: call_connect_status() must handle tasks that got transmitted
Date:   Fri, 30 Nov 2018 16:18:44 -0500
Message-Id: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
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

