Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD3CC67863
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7D18820652
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UOGwD/4q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D18820652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728270AbeJXA7Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:59:24 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:41255 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeJXA7Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:59:24 -0400
Received: by mail-io1-f65.google.com with SMTP id q4-v6so1277505iob.8
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 09:35:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A7VqkDtVWSBBm7nEzV3r4sy8vlNe3DgqVll3Xu3cCMg=;
        b=UOGwD/4q7IQCT+yCvHbUWeZFmg3bYGE9nB6VsWd5TburQrK78MhHYichyQXI3yAi1u
         8JaBwQAsRUrJ9dGSd4Ag6gowMMi8VxTjUiCGOq0DA+2etfu9VNNc2rw9FhqIcSc+AyVO
         TmiqK5F3X2ZeoF+qeQBObtVc/oInhzYAwR81tn9ZCmo3pR25uLjo91evQWAC0QEfoB5V
         ZsMysN6SV0wqZwnTOX4z2hE3WYug/aShS8GqHaBABMARTKj2+Vp2Cecx5w44CZQG0s78
         bKOW28rgDl3keCQB4ax/GN4FClcC1cYe35aEL4PQxvycA5+dD8yoU9TSnfD3eUMQPJbr
         dKfA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=A7VqkDtVWSBBm7nEzV3r4sy8vlNe3DgqVll3Xu3cCMg=;
        b=TseRUDpWglm1ZHFiD1ZSH/gOevuvg8VOgABIeRkkQ1bmw5uvHgYci8Gnu9ICeOs4eh
         TmxRS5T+5PBR79JFbiBIgEOidTYelKQ88sHze3WL22097G2qhokrE9iQdOc2WHdD8pDO
         xAggj5cYOJYg8o0jydRiHpFqkpexWYp/QFMBbwGgCrk4jALDpWLPY3Co6W5zcsiVr7E3
         wRKe2xc3YhyO8KrE4NgfNz7l77H4Jn6Om8WtQvN4yL4H/2laDAt0bTS1yWJKpf+6Xifr
         byJo4TMWWpCzkXDZhEE/8dyJh2PDwNvqbsmX15ngcpleLl5Tw5xWw2lr+DTygYpvrGx9
         hXtw==
X-Gm-Message-State: AGRZ1gIhzh7L7USvMu7a+hSKw1HhqBiWP7Vzz1vVQpvMcb54UlTTzqFx
        4M4/QmEa/nYup3LVvgN/kQL8cP4=
X-Google-Smtp-Source: AJdET5doa9ydGgeHCyO5Fevf7DLlDcoz4iGDNhzDYXdK/83LTLoU2BRpkyTSDTV/c0nNn5zb8Ofrhw==
X-Received: by 2002:a6b:de1a:: with SMTP id v26-v6mr11033042iog.86.1540312516151;
        Tue, 23 Oct 2018 09:35:16 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id w20-v6sm573065ioa.82.2018.10.23.09.35.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 09:35:15 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] SUNRPC: Convert the auth cred cache to use refcount_t
Date:   Tue, 23 Oct 2018 12:34:04 -0400
Message-Id: <20181023163404.27777-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20181023163404.27777-3-trond.myklebust@hammerspace.com>
References: <20181023163404.27777-1-trond.myklebust@hammerspace.com>
 <20181023163404.27777-2-trond.myklebust@hammerspace.com>
 <20181023163404.27777-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/auth.h    | 2 +-
 net/sunrpc/auth.c              | 2 +-
 net/sunrpc/auth_generic.c      | 2 +-
 net/sunrpc/auth_gss/auth_gss.c | 4 ++--
 net/sunrpc/auth_null.c         | 4 ++--
 net/sunrpc/auth_unix.c         | 4 ++--
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a71d4bd191e7..c4db9424b63b 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -100,7 +100,7 @@ struct rpc_auth {
 						 * differ from the flavor in
 						 * au_ops->au_flavor in gss
 						 * case) */
-	atomic_t		au_count;	/* Reference counter */
+	refcount_t		au_count;	/* Reference counter */
 
 	struct rpc_cred_cache *	au_credcache;
 	/* per-flavor data */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 4903eda5dd61..ad8ead738981 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -284,7 +284,7 @@ EXPORT_SYMBOL_GPL(rpcauth_create);
 void
 rpcauth_release(struct rpc_auth *auth)
 {
-	if (!atomic_dec_and_test(&auth->au_count))
+	if (!refcount_dec_and_test(&auth->au_count))
 		return;
 	auth->au_ops->destroy(auth);
 }
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f1df9837f1ac..d8831b988b1e 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -274,7 +274,7 @@ static const struct rpc_authops generic_auth_ops = {
 
 static struct rpc_auth generic_auth = {
 	.au_ops = &generic_auth_ops,
-	.au_count = ATOMIC_INIT(0),
+	.au_count = REFCOUNT_INIT(1),
 };
 
 static bool generic_key_to_expire(struct rpc_cred *cred)
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c898a7c75e84..30f970cdc7f6 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1058,7 +1058,7 @@ gss_create_new(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	auth->au_flavor = flavor;
 	if (gss_pseudoflavor_to_datatouch(gss_auth->mech, flavor))
 		auth->au_flags |= RPCAUTH_AUTH_DATATOUCH;
-	atomic_set(&auth->au_count, 1);
+	refcount_set(&auth->au_count, 1);
 	kref_init(&gss_auth->kref);
 
 	err = rpcauth_init_credcache(auth);
@@ -1187,7 +1187,7 @@ gss_auth_find_or_add_hashed(const struct rpc_auth_create_args *args,
 			if (strcmp(gss_auth->target_name, args->target_name))
 				continue;
 		}
-		if (!atomic_inc_not_zero(&gss_auth->rpc_auth.au_count))
+		if (!refcount_inc_not_zero(&gss_auth->rpc_auth.au_count))
 			continue;
 		goto out;
 	}
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index ea816d7000a4..2694a1bc026b 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -21,7 +21,7 @@ static struct rpc_cred null_cred;
 static struct rpc_auth *
 nul_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
-	atomic_inc(&null_auth.au_count);
+	refcount_inc(&null_auth.au_count);
 	return &null_auth;
 }
 
@@ -119,7 +119,7 @@ struct rpc_auth null_auth = {
 	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
-	.au_count	= ATOMIC_INIT(0),
+	.au_count	= REFCOUNT_INIT(1),
 };
 
 static
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 185e56d4f9ae..4c1c7e56288f 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -34,7 +34,7 @@ unx_create(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	dprintk("RPC:       creating UNIX authenticator for client %p\n",
 			clnt);
-	atomic_inc(&unix_auth.au_count);
+	refcount_inc(&unix_auth.au_count);
 	return &unix_auth;
 }
 
@@ -239,7 +239,7 @@ struct rpc_auth		unix_auth = {
 	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
-	.au_count	= ATOMIC_INIT(0),
+	.au_count	= REFCOUNT_INIT(1),
 };
 
 static
-- 
2.17.2

