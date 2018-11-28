Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB89C43610
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 15:06:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 84485208E7
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 15:06:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84485208E7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=codethink.co.uk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727726AbeK2CID (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 21:08:03 -0500
Received: from imap1.codethink.co.uk ([176.9.8.82]:55740 "EHLO
        imap1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727941AbeK2CID (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 21:08:03 -0500
Received: from office.codethink.co.uk ([148.252.241.226] helo=devhw0)
        by imap1.codethink.co.uk with esmtpsa (Exim 4.84_2 #1 (Debian))
        id 1gS1Pb-0004yx-TR; Wed, 28 Nov 2018 15:06:00 +0000
Received: from tpreston by devhw0 with local (Exim 4.89)
        (envelope-from <thomas.preston@codethink.co.uk>)
        id 1gS1Pb-0002TC-8g; Wed, 28 Nov 2018 15:05:59 +0000
From:   Thomas Preston <thomas.preston@codethink.co.uk>
To:     anna.schumaker@netapp.com, jlayton@kernel.org,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Cc:     linux-kernel@lists.codethink.co.uk,
        Ben Dooks <ben.dooks@codethink.co.uk>,
        Thomas Preston <thomas.preston@codethink.co.uk>
Subject: [PATCH v2 1/1] SUNRPC: allow /proc entries without CONFIG_SUNRPC_DEBUG
Date:   Wed, 28 Nov 2018 15:05:58 +0000
Message-Id: <20181128150558.9455-2-thomas.preston@codethink.co.uk>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20181128150558.9455-1-thomas.preston@codethink.co.uk>
References: <20181128150558.9455-1-thomas.preston@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Ben Dooks <ben.dooks@codethink.co.uk>

If we want /proc/sys/sunrpc the current kernel also drags in other debug
features which we don't really want. Instead, we should always show the
following entries:

/proc/sys/sunrpc/udp_slot_table_entries
/proc/sys/sunrpc/tcp_slot_table_entries
/proc/sys/sunrpc/tcp_max_slot_table_entries
/proc/sys/sunrpc/min_resvport
/proc/sys/sunrpc/max_resvport
/proc/sys/sunrpc/tcp_fin_timeout

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
Signed-off-by: Thomas Preston <thomas.preston@codethink.co.uk>
---
 net/sunrpc/xprtsock.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..c6c07fa410d1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -68,8 +68,6 @@ static unsigned int xprt_max_tcp_slot_table_entries = RPC_MAX_SLOT_TABLE;
 static unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 static unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-
 #define XS_TCP_LINGER_TO	(15U * HZ)
 static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
@@ -159,8 +157,6 @@ static struct ctl_table sunrpc_table[] = {
 	{ },
 };
 
-#endif
-
 /*
  * Wait duration for a reply from the RPC portmapper.
  */
@@ -3114,10 +3110,8 @@ static struct xprt_class	xs_bc_tcp_transport = {
  */
 int init_socket_xprt(void)
 {
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	if (!sunrpc_table_header)
 		sunrpc_table_header = register_sysctl_table(sunrpc_table);
-#endif
 
 	xprt_register_transport(&xs_local_transport);
 	xprt_register_transport(&xs_udp_transport);
@@ -3133,12 +3127,10 @@ int init_socket_xprt(void)
  */
 void cleanup_socket_xprt(void)
 {
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
 		sunrpc_table_header = NULL;
 	}
-#endif
 
 	xprt_unregister_transport(&xs_local_transport);
 	xprt_unregister_transport(&xs_udp_transport);
-- 
2.11.0

