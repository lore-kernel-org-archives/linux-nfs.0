Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AB4CC63697
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1E0A320809
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CWW9EF2w"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731982AbgKJX3X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Nov 2020 18:29:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:39182 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730894AbgKJX3W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Nov 2020 18:29:22 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 71EE420781
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2020 23:29:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605050961;
        bh=meypuo39sRui2/YKEKb9r1QSXStbQSXx9s+M+PX//8g=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=CWW9EF2w/uxEe7E2eVBeu4ncW0CS9uFPM/1UAfJpNQ8mkPOQPinqAoYzyx5A0Hdre
         IP+pP0khn5lTGIjAVQvO7bYFpcl+6eCwvJp8t5c/SKmbMTCq4XAVefSEB+67lyeOHJ
         LeTZlvy9dN0CzBe40qA7Wb8aYiZhVlNezFid7Le0=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/11] SUNRPC: Remove unused function xprt_load_transport()
Date:   Tue, 10 Nov 2020 18:19:00 -0500
Message-Id: <20201110231906.863446-6-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201110231906.863446-5-trondmy@kernel.org>
References: <20201110231906.863446-1-trondmy@kernel.org>
 <20201110231906.863446-2-trondmy@kernel.org>
 <20201110231906.863446-3-trondmy@kernel.org>
 <20201110231906.863446-4-trondmy@kernel.org>
 <20201110231906.863446-5-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 -
 net/sunrpc/xprt.c           | 15 ---------------
 2 files changed, 16 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index f7b75c72f80e..d2e97ee802af 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -385,7 +385,6 @@ xprt_disable_swap(struct rpc_xprt *xprt)
  */
 int			xprt_register_transport(struct xprt_class *type);
 int			xprt_unregister_transport(struct xprt_class *type);
-int			xprt_load_transport(const char *);
 int			xprt_find_transport_ident(const char *);
 void			xprt_wait_for_reply_request_def(struct rpc_task *task);
 void			xprt_wait_for_reply_request_rtt(struct rpc_task *task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1016265d5e53..9018d73575d6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -240,21 +240,6 @@ int xprt_find_transport_ident(const char *netid)
 }
 EXPORT_SYMBOL_GPL(xprt_find_transport_ident);
 
-/**
- * xprt_load_transport - load a transport implementation
- * @netid: transport to load
- *
- * Returns:
- * 0:		transport successfully loaded
- * -ENOENT:	transport module not available
- */
-int xprt_load_transport(const char *netid)
-{
-	int ret = xprt_find_transport_ident(netid);
-	return ret < 0 ? ret : 0;
-}
-EXPORT_SYMBOL_GPL(xprt_load_transport);
-
 static void xprt_clear_locked(struct rpc_xprt *xprt)
 {
 	xprt->snd_task = NULL;
-- 
2.28.0

