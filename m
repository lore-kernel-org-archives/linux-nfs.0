Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:48704 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab3CPTyT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:54:19 -0400
Received: by mail-ia0-f177.google.com with SMTP id y25so4185734iay.22
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:54:18 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 01/15] SUNRPC: Missing module alias for auth_rpcgss.ko
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:54:16 -0400
Message-ID: <20130316195416.27329.31812.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit f344f6df "SUNRPC: Auto-load RPC authentication kernel
modules", Mon Mar 20 13:44:08 2006, adds a request_module() call
in rpcauth_create() to auto-load RPC security modules when a ULP
tries to create a credential of that flavor.

In rpcauth_create(), the name of the module to load is built like
this:

	request_module("rpc-auth-%u", flavor);

This means that for, say, RPC_AUTH_GSS, request_module() is looking
for a module or alias called "rpc-auth-6".

The GSS module is named "auth_rpcgss", and commit f344f6df does not
add any new module aliases.  There is also no such alias provided in
/etc/modprobe.d on my system (Fedora 16).  Without this alias, the
GSS module is not loaded on demand.

This is used by rpcauth_create().  The pseudoflavor_to_flavor() call
can return RPC_AUTH_GSS, which is passed to request_module().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth_gss/auth_gss.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5257d29..282dfb1 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1733,6 +1733,7 @@ static void __exit exit_rpcsec_gss(void)
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
+MODULE_ALIAS("rpc-auth-6");
 MODULE_LICENSE("GPL");
 module_param_named(expired_cred_retry_delay,
 		   gss_expired_cred_retry_delay,

