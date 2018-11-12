Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D18B5C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:13:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 88EFE223AE
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:13:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="InI7Lro6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88EFE223AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726037AbeKMHH7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 02:07:59 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:51152 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725817AbeKMHH7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Nov 2018 02:07:59 -0500
Received: by mail-it1-f194.google.com with SMTP id k206-v6so14832687ite.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 13:13:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Hz7ViSnIuA2oINjvNWQqBVk7T5qLOAKYRfe/hJauvt8=;
        b=InI7Lro6oMvo0G5z8gx8wnlBHkhLUxc2tor1Fx6q/Eni/mvfvIbUZdChLw3zEJW6sp
         k83RI53jvqYrIsCEnO2NanUbf5IbgljUxVWIVDYIjrkMYmsfSJc8vcvlotwXSVaJ/Y90
         y/8Yb6OeW6u1KOTTjADqN6+YtHgfExDqlvqKxNPHXsdmJPjKhbcgcBZEipCVHwDm4O+G
         LpNDLFZ8mosFyynRMzzA6/DjOzGnIVW9lNfb5p6WxkB/vrFA0c8VsIhWxsWR+UnPPk9i
         qYPA4MdEu8pi0nEd7V73/Z6if1gtj4jWQFl3cO3nMDZpFkVCLcYCxCo2o0kGxbdOM8h+
         /Zmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Hz7ViSnIuA2oINjvNWQqBVk7T5qLOAKYRfe/hJauvt8=;
        b=QMu4iHzBWoeF6UKliu+2MHiTf4ZRX/CsxV9CQg+HLQ+ZG4a/jj4FCtCyBRIwlZ2kig
         6SZsCPXU2xK/2PQGWYJ6Y6Z4/GTu7IBzBEjRpbEnb4CDhMQbW8RgQkpzYsmUOUz0HqTq
         tPBUhyK2/98pY7ngDRgcLiiYrqdMa4BQQJULmPESbLBNBWUZr9Fqm2MxuEBfZNfBllb/
         NhaVoRct1ouuRDQKUY8WIpxB267FjGcYCykTL+XVoqnNgCGp0EgoUbz/xENnhvNAvgqS
         9S45dFeMbQ6IoNvpF92AdSwnQYgeJIVC36KUkYdIAhjkaaoxKBbyY77BnIhMigxJ655s
         x/zQ==
X-Gm-Message-State: AGRZ1gJNxydKwbITw60QV/5DHvDBeE9KBmDr7oPikrNFtMDMDJiTq9gs
        pLNyRDk0EK/1s7ueGqxlEg==
X-Google-Smtp-Source: AJdET5c5ey1l6bbd2tjn544B5UYTCJwuWmtumdz6DJ1HdD86qzdbxcz3hjknjOX7IFuMTtJVd7SQFw==
X-Received: by 2002:a24:de03:: with SMTP id d3-v6mr1239057itg.178.1542057180133;
        Mon, 12 Nov 2018 13:13:00 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id e80-v6sm5361207itc.35.2018.11.12.13.12.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 13:12:59 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Bruce Fields <bfields@fieldses.org>,
        Chuck Lever <chucklever@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] SUNRPC: Fix a Oops when destroying the RPCSEC_GSS credential cache
Date:   Mon, 12 Nov 2018 16:11:50 -0500
Message-Id: <20181112211151.119201-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 07d02a67b7fa causes a use-after free in the RPCSEC_GSS credential
destroy code, because the call to get_rpccred() in gss_destroying_context()
will now always fail to increment the refcount.

While we could just replace the get_rpccred() with a refcount_set(), that
would have the unfortunate consequence of resurrecting a credential in
the credential cache for which we are in the process of destroying the
RPCSEC_GSS context. Rather than do this, we choose to make a copy that
is never added to the cache and use that to destroy the context.

Fixes: 07d02a67b7fa ("SUNRPC: Simplify lookup code")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 61 +++++++++++++++++++++++-----------
 1 file changed, 42 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 30f970cdc7f6..5d3f252659f1 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1239,36 +1239,59 @@ gss_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	return &gss_auth->rpc_auth;
 }
 
+static struct gss_cred *
+gss_dup_cred(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
+{
+	struct gss_cred *new;
+
+	/* Make a copy of the cred so that we can reference count it */
+	new = kzalloc(sizeof(*gss_cred), GFP_NOIO);
+	if (new) {
+		struct auth_cred acred = {
+			.uid = gss_cred->gc_base.cr_uid,
+		};
+		struct gss_cl_ctx *ctx =
+			rcu_dereference_protected(gss_cred->gc_ctx, 1);
+
+		rpcauth_init_cred(&new->gc_base, &acred,
+				&gss_auth->rpc_auth,
+				&gss_nullops);
+		new->gc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
+		new->gc_service = gss_cred->gc_service;
+		new->gc_principal = gss_cred->gc_principal;
+		kref_get(&gss_auth->kref);
+		rcu_assign_pointer(new->gc_ctx, ctx);
+		gss_get_ctx(ctx);
+	}
+	return new;
+}
+
 /*
- * gss_destroying_context will cause the RPCSEC_GSS to send a NULL RPC call
+ * gss_send_destroy_context will cause the RPCSEC_GSS to send a NULL RPC call
  * to the server with the GSS control procedure field set to
  * RPC_GSS_PROC_DESTROY. This should normally cause the server to release
  * all RPCSEC_GSS state associated with that context.
  */
-static int
-gss_destroying_context(struct rpc_cred *cred)
+static void
+gss_send_destroy_context(struct rpc_cred *cred)
 {
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
 	struct gss_auth *gss_auth = container_of(cred->cr_auth, struct gss_auth, rpc_auth);
 	struct gss_cl_ctx *ctx = rcu_dereference_protected(gss_cred->gc_ctx, 1);
+	struct gss_cred *new;
 	struct rpc_task *task;
 
-	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
-		return 0;
-
-	ctx->gc_proc = RPC_GSS_PROC_DESTROY;
-	cred->cr_ops = &gss_nullops;
-
-	/* Take a reference to ensure the cred will be destroyed either
-	 * by the RPC call or by the put_rpccred() below */
-	get_rpccred(cred);
+	new = gss_dup_cred(gss_auth, gss_cred);
+	if (new) {
+		ctx->gc_proc = RPC_GSS_PROC_DESTROY;
 
-	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC|RPC_TASK_SOFT);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+		task = rpc_call_null(gss_auth->client, &new->gc_base,
+				RPC_TASK_ASYNC|RPC_TASK_SOFT);
+		if (!IS_ERR(task))
+			rpc_put_task(task);
 
-	put_rpccred(cred);
-	return 1;
+		put_rpccred(&new->gc_base);
+	}
 }
 
 /* gss_destroy_cred (and gss_free_ctx) are used to clean up after failure
@@ -1330,8 +1353,8 @@ static void
 gss_destroy_cred(struct rpc_cred *cred)
 {
 
-	if (gss_destroying_context(cred))
-		return;
+	if (test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0)
+		gss_send_destroy_context(cred);
 	gss_destroy_nullcred(cred);
 }
 
-- 
2.19.1

