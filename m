Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4221FC55ABD
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E728E20809
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Gu/FvZin"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731954AbgKJX3V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Nov 2020 18:29:21 -0500
Received: from mail.kernel.org ([198.145.29.99]:39148 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730894AbgKJX3U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Nov 2020 18:29:20 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 196D9207E8
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2020 23:29:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605050959;
        bh=3AgrCRS9cu4eXlK3NSXaYZ2fXESWqxnt3bb6UHVHQJU=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=Gu/FvZiniVEV2mcl7oOs7FHQXeTNxE0K0ZTaoIhPbOONU1OnYcdVr4gKoDPsEKSFc
         fgf3obF8GdHdTkvwuouBdnXrCudQa6EJhT+h2pBrj/SibcnGuxQeSPAIbFh1Y/rIJN
         pCir1pfnOGNODsWZW7Kg4fBkWezwkwUHD+0odQ+E=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/11] SUNRPC: Close a race with transport setup and module put
Date:   Tue, 10 Nov 2020 18:18:57 -0500
Message-Id: <20201110231906.863446-3-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201110231906.863446-2-trondmy@kernel.org>
References: <20201110231906.863446-1-trondmy@kernel.org>
 <20201110231906.863446-2-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

After we've looked up the transport module, we need to ensure it can't
go away until we've finished running the transport setup code.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 44 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1660a4b03352..29de33ea53d6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -157,6 +157,32 @@ xprt_class_release(const struct xprt_class *t)
 	module_put(t->owner);
 }
 
+static const struct xprt_class *
+xprt_class_find_by_ident_locked(int ident)
+{
+	const struct xprt_class *t;
+
+	list_for_each_entry(t, &xprt_list, list) {
+		if (t->ident != ident)
+			continue;
+		if (!try_module_get(t->owner))
+			continue;
+		return t;
+	}
+	return NULL;
+}
+
+static const struct xprt_class *
+xprt_class_find_by_ident(int ident)
+{
+	const struct xprt_class *t;
+
+	spin_lock(&xprt_list_lock);
+	t = xprt_class_find_by_ident_locked(ident);
+	spin_unlock(&xprt_list_lock);
+	return t;
+}
+
 static const struct xprt_class *
 xprt_class_find_by_netid_locked(const char *netid)
 {
@@ -1929,21 +1955,17 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
 	struct rpc_xprt	*xprt;
-	struct xprt_class *t;
+	const struct xprt_class *t;
 
-	spin_lock(&xprt_list_lock);
-	list_for_each_entry(t, &xprt_list, list) {
-		if (t->ident == args->ident) {
-			spin_unlock(&xprt_list_lock);
-			goto found;
-		}
+	t = xprt_class_find_by_ident(args->ident);
+	if (!t) {
+		dprintk("RPC: transport (%d) not supported\n", args->ident);
+		return ERR_PTR(-EIO);
 	}
-	spin_unlock(&xprt_list_lock);
-	dprintk("RPC: transport (%d) not supported\n", args->ident);
-	return ERR_PTR(-EIO);
 
-found:
 	xprt = t->setup(args);
+	xprt_class_release(t);
+
 	if (IS_ERR(xprt))
 		goto out;
 	if (args->flags & XPRT_CREATE_NO_IDLE_TIMEOUT)
-- 
2.28.0

