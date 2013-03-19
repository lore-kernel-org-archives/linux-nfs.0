Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f173.google.com ([209.85.210.173]:55181 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507Ab3CSTBx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 15:01:53 -0400
Received: by mail-ia0-f173.google.com with SMTP id h37so711626iak.32
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 12:01:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Don't recognize RPC_AUTH_MAXFLAVOR
To: linux-nfs@vger.kernel.org
Date: Tue, 19 Mar 2013 15:01:37 -0400
Message-ID: <20130319190137.1203.1269.stgit@seurat.1015granger.net>
In-Reply-To: <20130319185944.1203.38377.stgit@seurat.1015granger.net>
References: <20130319185944.1203.38377.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC_AUTH_MAXFLAVOR is an invalid flavor, on purpose.  Don't allow
any processing whatsoever if a caller passes it to rpcauth_create()
or rpcauth_get_gssinfo().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2bc0cc2..ed2fdd2 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -82,7 +82,7 @@ MODULE_PARM_DESC(auth_hashtable_size, "RPC credential cache hashtable size");
 
 static u32
 pseudoflavor_to_flavor(u32 flavor) {
-	if (flavor >= RPC_AUTH_MAXFLAVOR)
+	if (flavor > RPC_AUTH_MAXFLAVOR)
 		return RPC_AUTH_GSS;
 	return flavor;
 }
@@ -173,6 +173,9 @@ rpcauth_get_gssinfo(rpc_authflavor_t pseudoflavor, struct rpcsec_gss_info *info)
 	const struct rpc_authops *ops;
 	int result;
 
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		return -EINVAL;
+
 	ops = auth_flavors[flavor];
 	if (ops == NULL)
 		request_module("rpc-auth-%u", flavor);

