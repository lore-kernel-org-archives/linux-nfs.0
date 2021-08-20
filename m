Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47B70C4338F
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 14:54:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 26FCE61102
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 14:54:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240925AbhHTOyp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Aug 2021 10:54:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:47370 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S240879AbhHTOyo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Aug 2021 10:54:44 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id A9D5961102
        for <linux-nfs@vger.kernel.org>; Fri, 20 Aug 2021 14:54:06 +0000 (UTC)
Subject: [PATCH v3 3/4] SUNRPC: Server-side disconnect injection
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 20 Aug 2021 10:54:06 -0400
Message-ID: <162947124599.3311.3587800309667501801.stgit@klimt.1015granger.net>
In-Reply-To: <162947112222.3311.9483898011770198455.stgit@klimt.1015granger.net>
References: <162947112222.3311.9483898011770198455.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Disconnect injection stress-tests the ability for both client and
server implementations to behave resiliently in the face of network
instability.

A file called /sys/kernel/debug/fail_sunrpc/ignore-server-disconnect
enables administrators to turn off server-side disconnect injection
while allowing other types of sunrpc errors to be injected. The
default setting is that server-side disconnect injection is enabled
(ignore=false).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/debugfs.c |    3 +++
 net/sunrpc/fail.h    |    2 ++
 net/sunrpc/svc.c     |    8 ++++++++
 3 files changed, 13 insertions(+)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 04e453ad3508..827bf3a28178 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -259,6 +259,9 @@ static void fail_sunrpc_init(void)
 
 	debugfs_create_bool("ignore-client-disconnect", S_IFREG | 0600, dir,
 			    &fail_sunrpc.ignore_client_disconnect);
+
+	debugfs_create_bool("ignore-server-disconnect", S_IFREG | 0600, dir,
+			    &fail_sunrpc.ignore_server_disconnect);
 }
 #else
 static void fail_sunrpc_init(void)
diff --git a/net/sunrpc/fail.h b/net/sunrpc/fail.h
index 62c1b9fd59e2..69dc30cc44b8 100644
--- a/net/sunrpc/fail.h
+++ b/net/sunrpc/fail.h
@@ -14,6 +14,8 @@ struct fail_sunrpc_attr {
 	struct fault_attr	attr;
 
 	bool			ignore_client_disconnect;
+
+	bool			ignore_server_disconnect;
 };
 
 extern struct fail_sunrpc_attr fail_sunrpc;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 5aa263326b6a..bfcbaf7b3822 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -31,6 +31,8 @@
 
 #include <trace/events/sunrpc.h>
 
+#include "fail.h"
+
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
 
 static void svc_unregister(const struct svc_serv *serv, struct net *net);
@@ -1524,6 +1526,12 @@ svc_process(struct svc_rqst *rqstp)
 	struct svc_serv		*serv = rqstp->rq_server;
 	u32			dir;
 
+#if IS_ENABLED(CONFIG_FAIL_SUNRPC)
+	if (!fail_sunrpc.ignore_server_disconnect &&
+	    should_fail(&fail_sunrpc.attr, 1))
+		svc_xprt_deferred_close(rqstp->rq_xprt);
+#endif
+
 	/*
 	 * Setup response xdr_buf.
 	 * Initially it has just one page


