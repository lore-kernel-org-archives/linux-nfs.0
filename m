Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35173 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbcDVAwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2016 20:52:11 -0400
Received: by mail-qg0-f46.google.com with SMTP id f74so48437943qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 21 Apr 2016 17:52:11 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/7] sunrpc: add rpc_lookup_generic_cred
Date: Thu, 21 Apr 2016 20:51:55 -0400
Message-Id: <1461286320-24601-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
References: <1461286320-24601-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Add function rpc_lookup_generic_cred, which allows lookups of a generic
credential that's not current_cred().

[jlayton: add gfp_t parm]

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/auth.h | 1 +
 net/sunrpc/auth_generic.c   | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 3b616aa7e4d2..16bd8f8fef8c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -167,6 +167,7 @@ void 			rpc_destroy_authunix(void);
 
 struct rpc_cred *	rpc_lookup_cred(void);
 struct rpc_cred *	rpc_lookup_cred_nonblock(void);
+struct rpc_cred *	rpc_lookup_generic_cred(struct auth_cred *, int, gfp_t);
 struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 6ed3e3df43e9..54dd3fdead54 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -38,6 +38,13 @@ struct rpc_cred *rpc_lookup_cred(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 
+struct rpc_cred *
+rpc_lookup_generic_cred(struct auth_cred *acred, int flags, gfp_t gfp)
+{
+	return rpcauth_lookup_credcache(&generic_auth, acred, flags, gfp);
+}
+EXPORT_SYMBOL_GPL(rpc_lookup_generic_cred);
+
 struct rpc_cred *rpc_lookup_cred_nonblock(void)
 {
 	return rpcauth_lookupcred(&generic_auth, RPCAUTH_LOOKUP_RCU);
-- 
2.5.5

