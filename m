Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0EFDC43334
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Jul 2022 14:39:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233534AbiGAOj5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Jul 2022 10:39:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34694 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233327AbiGAOjp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jul 2022 10:39:45 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 389A545055
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2022 07:37:41 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id C6F06B83076
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jul 2022 14:37:39 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7760CC341C7;
        Fri,  1 Jul 2022 14:37:38 +0000 (UTC)
Subject: [PATCH v1] SUNRPC: Add ability to inject signals via fault injection
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     kolga@netapp.com
Date:   Fri, 01 Jul 2022 10:37:37 -0400
Message-ID: <165668625750.3724818.8474699462148567863.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signal injection can help exercise signal handling paths in the
SUNRPC scheduler and in transport implementations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 Documentation/fault-injection/fault-injection.rst |    7 +++++++
 net/sunrpc/debugfs.c                              |    3 +++
 net/sunrpc/fail.h                                 |    1 +
 net/sunrpc/sched.c                                |   10 ++++++++++
 4 files changed, 21 insertions(+)

diff --git a/Documentation/fault-injection/fault-injection.rst b/Documentation/fault-injection/fault-injection.rst
index 17779a2772e5..ff5c4db2198f 100644
--- a/Documentation/fault-injection/fault-injection.rst
+++ b/Documentation/fault-injection/fault-injection.rst
@@ -162,6 +162,13 @@ configuration of fault-injection capabilities.
 	default is 'N', setting it to 'Y' will disable disconnect
 	injection on the RPC client.
 
+- /sys/kernel/debug/fail_sunrpc/ignore-client-signals:
+
+	Format: { 'Y' | 'N' }
+
+	default is 'N', setting it to 'Y' will disable signal
+	injection on the RPC client.
+
 - /sys/kernel/debug/fail_sunrpc/ignore-server-disconnect:
 
 	Format: { 'Y' | 'N' }
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index a176d5a0b0ee..8df634e63f30 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -260,6 +260,9 @@ static void fail_sunrpc_init(void)
 	debugfs_create_bool("ignore-client-disconnect", S_IFREG | 0600, dir,
 			    &fail_sunrpc.ignore_client_disconnect);
 
+	debugfs_create_bool("ignore-client-signals", S_IFREG | 0600, dir,
+			    &fail_sunrpc.ignore_client_signals);
+
 	debugfs_create_bool("ignore-server-disconnect", S_IFREG | 0600, dir,
 			    &fail_sunrpc.ignore_server_disconnect);
 
diff --git a/net/sunrpc/fail.h b/net/sunrpc/fail.h
index 4b4b500df428..359ed0b2f600 100644
--- a/net/sunrpc/fail.h
+++ b/net/sunrpc/fail.h
@@ -14,6 +14,7 @@ struct fail_sunrpc_attr {
 	struct fault_attr	attr;
 
 	bool			ignore_client_disconnect;
+	bool			ignore_client_signals;
 	bool			ignore_server_disconnect;
 	bool			ignore_cache_wait;
 };
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 7f70c1e608b7..1b1de8906a91 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -26,6 +26,7 @@
 #include <linux/sunrpc/metrics.h>
 
 #include "sunrpc.h"
+#include "fail.h"
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/sunrpc.h>
@@ -959,6 +960,12 @@ static void __rpc_execute(struct rpc_task *task)
 		if (task_is_async)
 			goto out;
 
+#if IS_ENABLED(CONFIG_FAIL_SUNRPC)
+		if (!fail_sunrpc.ignore_client_signals &&
+		    should_fail(&fail_sunrpc.attr, 1))
+			goto signalled;
+#endif
+
 		/* sync task: sleep here */
 		trace_rpc_task_sync_sleep(task, task->tk_action);
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
@@ -971,6 +978,9 @@ static void __rpc_execute(struct rpc_task *task)
 			 * clean up after sleeping on some queue, we don't
 			 * break the loop here, but go around once more.
 			 */
+#if IS_ENABLED(CONFIG_FAIL_SUNRPC)
+signalled:
+#endif
 			trace_rpc_task_signalled(task, task->tk_action);
 			set_bit(RPC_TASK_SIGNALLED, &task->tk_runstate);
 			task->tk_rpc_status = -ERESTARTSYS;


