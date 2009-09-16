From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/4] nfsd4: fix null dereference creating nfsv4 callback client
Date: Tue, 15 Sep 2009 21:07:55 -0400
Message-ID: <1253063278-30137-1-git-send-email-bfields@citi.umich.edu>
References: <20090916010604.GA29397@fieldses.org>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>, stable@kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33112 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037AbZIPBHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 21:07:54 -0400
In-Reply-To: <20090916010604.GA29397@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On setting up the callback to the client, we attempt to use the same
authentication flavor the client did.  We find an rpc cred to use by
calling rpcauth_lookup_credcache(), which assumes that the given
authentication flavor has a credentials cache.  However, this is not
required to be true--in particular, auth_null does not use one.
Instead, we should call the auth's lookup_cred() method.

Without this, a client attempting to mount using nfsv4 and auth_null
triggers a null dereference.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 63bb384..4abb882 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -437,6 +437,7 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
 	struct auth_cred acred = {
 		.machine_cred = 1
 	};
+	struct rpc_auth *auth = cb->cb_client->cl_auth;
 
 	/*
 	 * Note in the gss case this doesn't actually have to wait for a
@@ -444,8 +445,7 @@ static struct rpc_cred *lookup_cb_cred(struct nfs4_cb_conn *cb)
 	 * non-uptodate cred which the rpc state machine will fill in with
 	 * a refresh_upcall later.
 	 */
-	return rpcauth_lookup_credcache(cb->cb_client->cl_auth, &acred,
-							RPCAUTH_LOOKUP_NEW);
+	return auth->au_ops->lookup_cred(auth, &acred, RPCAUTH_LOOKUP_NEW);
 }
 
 void do_probe_callback(struct nfs4_client *clp)
-- 
1.6.0.4

