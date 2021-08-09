Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F4C9C4338F
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:09:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 86D0D61004
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Aug 2021 18:09:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232875AbhHISKE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Aug 2021 14:10:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:52336 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230243AbhHISKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Aug 2021 14:10:04 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 6539A61004
        for <linux-nfs@vger.kernel.org>; Mon,  9 Aug 2021 18:09:43 +0000 (UTC)
Subject: [PATCH v1 4/4] SUNRPC: Add documentation for the fail_sunrpc/
 directory
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 09 Aug 2021 14:09:42 -0400
Message-ID: <162853258270.4752.4445102254929246927.stgit@klimt.1015granger.net>
In-Reply-To: <162853242223.4752.16344468003771993974.stgit@klimt.1015granger.net>
References: <162853242223.4752.16344468003771993974.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 Documentation/fault-injection/fault-injection.rst |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/Documentation/fault-injection/fault-injection.rst b/Documentation/fault-injection/fault-injection.rst
index f47d05ed0d94..4a25c5eb6f07 100644
--- a/Documentation/fault-injection/fault-injection.rst
+++ b/Documentation/fault-injection/fault-injection.rst
@@ -24,6 +24,10 @@ Available fault injection capabilities
 
   injects futex deadlock and uaddr fault errors.
 
+- fail_sunrpc
+
+  injects kernel RPC client and server failures.
+
 - fail_make_request
 
   injects disk IO errors on devices permitted by setting
@@ -151,6 +155,20 @@ configuration of fault-injection capabilities.
 	default is 'N', setting it to 'Y' will disable failure injections
 	when dealing with private (address space) futexes.
 
+- /sys/kernel/debug/fail_sunrpc/ignore-client-disconnect:
+
+	Format: { 'Y' | 'N' }
+
+	default is 'N', setting it to 'Y' will disable disconnect
+	injection on the RPC client.
+
+- /sys/kernel/debug/fail_sunrpc/ignore-server-disconnect:
+
+	Format: { 'Y' | 'N' }
+
+	default is 'N', setting it to 'Y' will disable disconnect
+	injection on the RPC server.
+
 - /sys/kernel/debug/fail_function/inject:
 
 	Format: { 'function-name' | '!function-name' | '' }


