Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34671 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753263AbdBGNs6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:48:58 -0500
Received: by mail-it0-f66.google.com with SMTP id o185so12361690itb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:48:58 -0800 (PST)
Subject: [PATCH 4/7] sunrpc: remove dead codes of cr_magic in rpc_cred
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <acb63381-22e6-1b15-7b5d-c5769c135759@gmail.com>
Date: Tue, 7 Feb 2017 21:48:49 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't found any place using the cr_magic.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/auth.h | 5 -----
 net/sunrpc/auth.c           | 3 ---
 net/sunrpc/auth_null.c      | 3 ---
 3 files changed, 11 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 39c85fb..8fd3504 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -64,9 +64,6 @@ struct rpc_cred {
 	struct rcu_head		cr_rcu;
 	struct rpc_auth *	cr_auth;
 	const struct rpc_credops *cr_ops;
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-	unsigned long		cr_magic;	/* 0x0f4aa4f0 */
-#endif
 	unsigned long		cr_expire;	/* when to gc */
 	unsigned long		cr_flags;	/* various flags */
 	atomic_t		cr_count;	/* ref count */
@@ -80,8 +77,6 @@ struct rpc_cred {
 #define RPCAUTH_CRED_HASHED	2
 #define RPCAUTH_CRED_NEGATIVE	3
 
-#define RPCAUTH_CRED_MAGIC	0x0f4aa4f0
-
 /* rpc_auth au_flags */
 #define RPCAUTH_AUTH_NO_CRKEY_TIMEOUT	0x0001 /* underlying cred has no key timeout */
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2bff63a..a7d03ea 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -646,9 +646,6 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	cred->cr_auth = auth;
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-	cred->cr_magic = RPCAUTH_CRED_MAGIC;
-#endif
 	cred->cr_uid = acred->uid;
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 4d17376..5f3d527 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -139,7 +139,4 @@ struct rpc_cred null_cred = {
 	.cr_ops		= &null_credops,
 	.cr_count	= ATOMIC_INIT(1),
 	.cr_flags	= 1UL << RPCAUTH_CRED_UPTODATE,
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-	.cr_magic	= RPCAUTH_CRED_MAGIC,
-#endif
 };
-- 
2.9.3

