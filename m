Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C5AC4161D
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:22:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E2EE20684
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:22:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E2EE20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=codethink.co.uk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725961AbeKUEwr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 23:52:47 -0500
Received: from imap1.codethink.co.uk ([176.9.8.82]:39503 "EHLO
        imap1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726134AbeKUEwr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 23:52:47 -0500
Received: from [148.252.241.226] (helo=devhw0)
        by imap1.codethink.co.uk with esmtpsa (Exim 4.84_2 #1 (Debian))
        id 1gPAf7-0006JB-He; Tue, 20 Nov 2018 18:22:13 +0000
Received: from tpreston by devhw0 with local (Exim 4.89)
        (envelope-from <thomas.preston@codethink.co.uk>)
        id 1gPAJA-0007Fw-2j; Tue, 20 Nov 2018 17:59:32 +0000
From:   Thomas Preston <thomas.preston@codethink.co.uk>
To:     anna.schumaker@netapp.com, jlayton@kernel.org,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Cc:     ts001-upstream@lists.codethink.co.uk,
        Ben Dooks <ben.dooks@codethink.co.uk>,
        Thomas Preston <thomas.preston@codethink.co.uk>
Subject: [PATCH 1/1] SUNRPC: allow /proc entries without CONFIG_SUNRPC_DEBUG
Date:   Tue, 20 Nov 2018 17:59:30 +0000
Message-Id: <20181120175930.27853-2-thomas.preston@codethink.co.uk>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20181120175930.27853-1-thomas.preston@codethink.co.uk>
References: <20181120175930.27853-1-thomas.preston@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Ben Dooks <ben.dooks@codethink.co.uk>

If we want /proc/sys/sunrpc the current kernel also drags
in other debug features which we don't really want. Add the
option for the entries by adding CONFIG_SUNRPC_DEBUG.

/proc/sys/sunrpc/max_resvport
/proc/sys/sunrpc/min_resvport
/proc/sys/sunrpc/nfsd_debug
/proc/sys/sunrpc/nfs_debug
/proc/sys/sunrpc/nlm_debug
/proc/sys/sunrpc/rpc_debug
/proc/sys/sunrpc/tcp_fin_timeout

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
Signed-off-by: Thomas Preston <thomas.preston@codethink.co.uk>
---
 net/sunrpc/Kconfig    | 7 +++++++
 net/sunrpc/xprtsock.c | 6 +++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index ac09ca803296..0e23a7a6cce8 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -48,6 +48,13 @@ config SUNRPC_DEBUG
 
 	  If unsure, say Y.
 
+config SUNRPC_PROC
+	bool "RPC: Enable /proc/sys/sunrpc entries"
+	depends on SUNRPC && SYSCTL
+	help
+	  Enable /proc entires for tuning /proc/sys/sunrpc information
+	  without enabling all the debug features for the SUNRPC system.
+
 config SUNRPC_XPRT_RDMA
 	tristate "RPC-over-RDMA transport"
 	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..71b64402c070 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -68,7 +68,7 @@ static unsigned int xprt_max_tcp_slot_table_entries = RPC_MAX_SLOT_TABLE;
 static unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 static unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_SUNRPC_PROC)
 
 #define XS_TCP_LINGER_TO	(15U * HZ)
 static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
@@ -3114,7 +3114,7 @@ static struct xprt_class	xs_bc_tcp_transport = {
  */
 int init_socket_xprt(void)
 {
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_SUNRPC_PROC)
 	if (!sunrpc_table_header)
 		sunrpc_table_header = register_sysctl_table(sunrpc_table);
 #endif
@@ -3133,7 +3133,7 @@ int init_socket_xprt(void)
  */
 void cleanup_socket_xprt(void)
 {
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_SUNRPC_PROC)
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
 		sunrpc_table_header = NULL;
-- 
2.11.0

