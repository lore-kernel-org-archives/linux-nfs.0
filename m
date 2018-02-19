Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38535 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbeBSFEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:47 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 16/23] SUNRPC: remove RPCAUTH_AUTH_NO_CRKEY_TIMEOUT
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654931.17421.13039149078441048559.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is no longer used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/sunrpc/auth.h |    3 ---
 net/sunrpc/auth_null.c      |    1 -
 net/sunrpc/auth_unix.c      |    1 -
 3 files changed, 5 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 84614cb08ab1..0513db589739 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -69,9 +69,6 @@ struct rpc_cred {
 
 struct rpc_cred *rpc_machine_cred(void);
 
-/* rpc_auth au_flags */
-#define RPCAUTH_AUTH_NO_CRKEY_TIMEOUT	0x0001 /* underlying cred has no key timeout */
-
 /*
  * Client authentication handle
  */
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 75d72e109a04..c3d126adad4d 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -116,7 +116,6 @@ static
 struct rpc_auth null_auth = {
 	.au_cslack	= NUL_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
-	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
 	.au_count	= ATOMIC_INIT(0),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index d9d2f74ee44b..7b16dabd6575 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -237,7 +237,6 @@ static
 struct rpc_auth		unix_auth = {
 	.au_cslack	= UNX_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
-	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= ATOMIC_INIT(0),


