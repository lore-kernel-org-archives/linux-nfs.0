Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7DA4C4338F
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:09:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BBA4460F02
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:09:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232288AbhHISJq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Aug 2021 14:09:46 -0400
Received: from mail.kernel.org ([198.145.29.99]:52252 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230243AbhHISJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Aug 2021 14:09:46 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 80DFB60F02
        for <linux-nfs@vger.kernel.org>; Mon,  9 Aug 2021 18:09:25 +0000 (UTC)
Subject: [PATCH v1 1/4] SUNRPC: Add a /sys/kernel/debug/fail_sunrpc/ directory
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 09 Aug 2021 14:09:24 -0400
Message-ID: <162853256480.4752.1219884794743002339.stgit@klimt.1015granger.net>
In-Reply-To: <162853242223.4752.16344468003771993974.stgit@klimt.1015granger.net>
References: <162853242223.4752.16344468003771993974.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This directory will contain a set of administrative controls for
enabling error injection for kernel RPC consumers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/debugfs.c |   20 ++++++++++++++++++++
 net/sunrpc/fail.h    |   17 +++++++++++++++++
 2 files changed, 37 insertions(+)
 create mode 100644 net/sunrpc/fail.h

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 56029e3af6ff..7a9065b6a058 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -8,7 +8,9 @@
 #include <linux/debugfs.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
+
 #include "netns.h"
+#include "fail.h"
 
 static struct dentry *topdir;
 static struct dentry *rpc_clnt_dir;
@@ -297,6 +299,22 @@ static const struct file_operations fault_disconnect_fops = {
 	.release	= fault_release,
 };
 
+struct fail_sunrpc_attr fail_sunrpc = {
+	.attr			= FAULT_ATTR_INITIALIZER,
+};
+
+#if IS_ENABLED(CONFIG_FAULT_INJECTION_DEBUG_FS)
+static void fail_sunrpc_init(void)
+{
+	fault_create_debugfs_attr("fail_sunrpc", NULL,
+				  &fail_sunrpc.attr);
+}
+#else
+static inline void fail_sunrpc_init(void)
+{
+}
+#endif
+
 void __exit
 sunrpc_debugfs_exit(void)
 {
@@ -321,4 +339,6 @@ sunrpc_debugfs_init(void)
 
 	debugfs_create_file("disconnect", S_IFREG | 0400, rpc_fault_dir, NULL,
 			    &fault_disconnect_fops);
+
+	fail_sunrpc_init();
 }
diff --git a/net/sunrpc/fail.h b/net/sunrpc/fail.h
new file mode 100644
index 000000000000..96a46eff94e4
--- /dev/null
+++ b/net/sunrpc/fail.h
@@ -0,0 +1,17 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (C) 2021, Oracle. All rights reserved.
+ */
+
+#ifndef _NET_SUNRPC_FAIL_H_
+#define _NET_SUNRPC_FAIL_H_
+
+#include <linux/fault-inject.h>
+
+struct fail_sunrpc_attr {
+	struct fault_attr	attr;
+};
+
+extern struct fail_sunrpc_attr fail_sunrpc;
+
+#endif /* _NET_SUNRPC_FAIL_H_ */


