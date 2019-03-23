Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5636C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:02:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9C4B7206BA
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:02:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kuo/KB4+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727526AbfCWQCi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Mar 2019 12:02:38 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:55615 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727298AbfCWQCi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Mar 2019 12:02:38 -0400
Received: by mail-it1-f196.google.com with SMTP id z126so7905503itd.5
        for <linux-nfs@vger.kernel.org>; Sat, 23 Mar 2019 09:02:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=uJyEfztZDd1sv3Ok/PqOr9k1S8uMgnBCG5cZDPOhzkI=;
        b=kuo/KB4+OZ6E/q6VvuUGPay9bvPm+cEYfi4f4yYiGyWoZi3hqUageLzOev3zuFEs+3
         NEzh3p0MqEcXhE2mxXpeA9KU0RHNV0hfzrPpmxUnETh+iQmVO33vtHCjLyYptFNRIL7g
         bTozNQf04ce4lCO9VOkw0Zn/A53R2mWl6zQfcpo4flA9ZN//7UeBWBc00ULVUw6B4t66
         Kc8/Kvox094hZD/GhbT57H7b1Py9xEOO3IhbI/WCzwpBHjSnlVbKPHFDjd8cBGL/fClm
         8VwAQ4xq5u1ownziVJ4NlhmVGQCSXwmruzyZdgSNXB+Zjl7/I++1+C0reE+YoraLXueh
         2+aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=uJyEfztZDd1sv3Ok/PqOr9k1S8uMgnBCG5cZDPOhzkI=;
        b=LUxpNcWJVAh71VUlGlhVz2nHwx8I3VXjE6jswM7n/6ANtOIj3JmF8rRHO5l8FOM2U6
         /t6d0/savXSRaZugTRHCN3t8VXlYNwTwA89p9cKhFqw0XDKajFO2AGlg18UAZnwaQ8Wm
         zadNzuHKF4M9IoDwX+LlVy/N2dq5WcnVs6FUbEpo2FF22QOuWgCcoT8tuefn4GgYh2B6
         CPJomSusjD5B94zi67S5mwoD8EacgG0c63rWitnovELZwgtMo64Wgt4B3HbbGYP0p5LK
         UpyQ5fPGJuQaBFFCxL4MHBqMEZdX+7GYY4tSQUNMIGChnNCOVfXN+HaDgJgtkWmuCtdk
         wShg==
X-Gm-Message-State: APjAAAWtD+SsdxWvGDXJVJ9tGUfHG6pC6eI1BsrndZHhIURK5/OC77Bd
        QCdKZzWl3x1i8vQaO523UPdXeb8=
X-Google-Smtp-Source: APXvYqxXlqyhhPaSIiJXVmxXH/tY2GcGsOk9ZxtWY2SUF4Tn1JcvCsjeld+NNipdNWi8kde7N8/NlQ==
X-Received: by 2002:a24:4355:: with SMTP id s82mr5062945itb.176.1553356957047;
        Sat, 23 Mar 2019 09:02:37 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id u13sm4272473iog.80.2019.03.23.09.02.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 09:02:36 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Don't let RPC_SOFTCONN tasks time out if the transport is connected
Date:   Sat, 23 Mar 2019 11:59:10 -0400
Message-Id: <20190323155910.23092-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the transport is still connected, then we do want to allow
RPC_SOFTCONN tasks to retry. They should time out if and only if
the connection is broken.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 228970e6e52b..187d10443a15 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2311,6 +2311,15 @@ call_status(struct rpc_task *task)
 	rpc_exit(task, status);
 }
 
+static bool
+rpc_check_connected(const struct rpc_rqst *req)
+{
+	/* No allocated request or transport? return true */
+	if (!req || !req->rq_xprt)
+		return true;
+	return xprt_connected(req->rq_xprt);
+}
+
 static void
 rpc_check_timeout(struct rpc_task *task)
 {
@@ -2322,10 +2331,11 @@ rpc_check_timeout(struct rpc_task *task)
 	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
 	task->tk_timeouts++;
 
-	if (RPC_IS_SOFTCONN(task)) {
+	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
 		rpc_exit(task, -ETIMEDOUT);
 		return;
 	}
+
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty) {
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
-- 
2.20.1

