Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34059 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753224AbcLORNZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2016 12:13:25 -0500
Received: by mail-io0-f175.google.com with SMTP id p42so75102010ioo.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 09:13:14 -0800 (PST)
From: Seth Forshee <seth.forshee@canonical.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: Use current_real_cred() when looking up rpc credentials
Date: Thu, 15 Dec 2016 11:13:12 -0600
Message-Id: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since 4.8 follow_automount() overrides the credentials with
&init_cred before calling d_automount(). When
rpcauth_lookupcred() is called in this context it is now using
fs[ug]id from the override creds instead of from the user's
creds, which can cause authentication to fail. To fix this, take
the ids from current_real_cred() instead.

Cc: stable@vger.kernel.org # v4.8+
CC: Eric W. Biederman <ebiederm@xmission.com>
Fixes: aeaa4a79ff6a ("fs: Call d_automount with the filesystems creds")
Signed-off-by: Seth Forshee <seth.forshee@canonical.com>
---
 net/sunrpc/auth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 2bff63a73cf8..e6197b2bda86 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -622,7 +622,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 {
 	struct auth_cred acred;
 	struct rpc_cred *ret;
-	const struct cred *cred = current_cred();
+	const struct cred *cred = current_real_cred();
 
 	dprintk("RPC:       looking up %s cred\n",
 		auth->au_ops->au_name);
-- 
2.7.4

