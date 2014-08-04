Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52685 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053AbaHDGZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 02:25:23 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 04 Aug 2014 16:24:00 +1000
Subject: [PATCH 2/2] SUNRPC: remove all refcounting of groupinfo from
 rpcauth_lookupcred
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140804062400.7621.4909.stgit@notabene.brown>
In-Reply-To: <20140804062225.7621.70050.stgit@notabene.brown>
References: <20140804062225.7621.70050.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

current_cred() can only be changed by 'current', and
cred->group_info is never changed.  If a new group_info is
needed, a new 'cred' is created.

Consequently it is always safe to access
   current_cred()->group_info

without taking any further references.
So drop the refcounting and the incorrect rcu_dereference().

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/auth.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 794fc0f4fc4c..df2bd96f129d 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -595,14 +595,8 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	memset(&acred, 0, sizeof(acred));
 	acred.uid = cred->fsuid;
 	acred.gid = cred->fsgid;
-	if (flags & RPCAUTH_LOOKUP_RCU)
-		acred.group_info = rcu_dereference(cred->group_info);
-	else
-		acred.group_info = get_group_info(((struct cred *)cred)->group_info);
-
+	acred.group_info = cred->group_info;
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
-	if (!(flags & RPCAUTH_LOOKUP_RCU))
-		put_group_info(acred.group_info);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(rpcauth_lookupcred);


