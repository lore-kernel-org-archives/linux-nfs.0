Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1449 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab3H1Tkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 15:40:55 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v2 11/16] SUNRPC: Remove the obsolete auth-only interface for pipefs dentry management
Date: Wed, 28 Aug 2013 15:40:16 -0400
Message-ID: <1377718821-28159-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377718821-28159-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377718821-28159-10-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/auth.h |  2 --
 net/sunrpc/clnt.c           | 10 +---------
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a9ab577..6de26f2 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -107,8 +107,6 @@ struct rpc_authops {
 
 	struct rpc_cred *	(*lookup_cred)(struct rpc_auth *, struct auth_cred *, int);
 	struct rpc_cred *	(*crcreate)(struct rpc_auth*, struct auth_cred *, int);
-	int			(*pipes_create)(struct rpc_auth *);
-	void			(*pipes_destroy)(struct rpc_auth *);
 	int			(*list_pseudoflavors)(rpc_authflavor_t *, int);
 	rpc_authflavor_t	(*info2flavor)(struct rpcsec_gss_info *);
 	int			(*flavor2info)(rpc_authflavor_t,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c736031..e60b135 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -102,11 +102,8 @@ static void rpc_unregister_client(struct rpc_clnt *clnt)
 
 static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 {
-	if (clnt->cl_dentry) {
-		if (clnt->cl_auth && clnt->cl_auth->au_ops->pipes_destroy)
-			clnt->cl_auth->au_ops->pipes_destroy(clnt->cl_auth);
+	if (clnt->cl_dentry)
 		rpc_remove_client_dir(clnt->cl_dentry, clnt);
-	}
 	clnt->cl_dentry = NULL;
 }
 
@@ -189,11 +186,6 @@ static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 		if (IS_ERR(dentry))
 			return PTR_ERR(dentry);
 		clnt->cl_dentry = dentry;
-		if (clnt->cl_auth->au_ops->pipes_create) {
-			err = clnt->cl_auth->au_ops->pipes_create(clnt->cl_auth);
-			if (err)
-				__rpc_clnt_remove_pipedir(clnt);
-		}
 		break;
 	case RPC_PIPEFS_UMOUNT:
 		__rpc_clnt_remove_pipedir(clnt);
-- 
1.8.3.1

