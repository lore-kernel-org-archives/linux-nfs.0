Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52095 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:34 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 3/8] sunrpc/auth: allow lockless (rcu) lookup of credential
 cache.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.97801.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new flag RPCAUTH_LOOKUP_RCU to credential lookup avoids locking,
does not take a reference on the returned credential, and returns
-ECHILD if a simple lookup was not possible.

The returned value can only be used within an rcu_read_lock protected
region.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/auth.h |    1 +
 net/sunrpc/auth.c           |   17 +++++++++++++++--
 net/sunrpc/auth_null.c      |    2 ++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 790be1472792..3f158ae1d6fd 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -103,6 +103,7 @@ struct rpc_auth_create_args {
 
 /* Flags for rpcauth_lookupcred() */
 #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
+#define RPCAUTH_LOOKUP_RCU		0x02	/* lock-less lookup */
 
 /*
  * Client authentication ops
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead196c0..82459dd848ff 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -523,6 +523,12 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
+		if (flags & RPCAUTH_LOOKUP_RCU) {
+			if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) &&
+			    !test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags))
+				cred = entry;
+			break;
+		}
 		spin_lock(&cache->lock);
 		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
 			spin_unlock(&cache->lock);
@@ -537,6 +543,9 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred != NULL)
 		goto found;
 
+	if (flags & RPCAUTH_LOOKUP_RCU)
+		return ERR_PTR(-ECHILD);
+
 	new = auth->au_ops->crcreate(auth, acred, flags);
 	if (IS_ERR(new)) {
 		cred = new;
@@ -586,10 +595,14 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	memset(&acred, 0, sizeof(acred));
 	acred.uid = cred->fsuid;
 	acred.gid = cred->fsgid;
-	acred.group_info = get_group_info(((struct cred *)cred)->group_info);
+	if (flags & RPCAUTH_LOOKUP_RCU)
+		acred.group_info = rcu_dereference(cred->group_info);
+	else
+		acred.group_info = get_group_info(((struct cred *)cred)->group_info);
 
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
-	put_group_info(acred.group_info);
+	if (!(flags & RPCAUTH_LOOKUP_RCU))
+		put_group_info(acred.group_info);
 	return ret;
 }
 
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index f0ebe07978a2..712c123e04e9 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -35,6 +35,8 @@ nul_destroy(struct rpc_auth *auth)
 static struct rpc_cred *
 nul_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 {
+	if (flags & RPCAUTH_LOOKUP_RCU)
+		return &null_cred;
 	return get_rpccred(&null_cred);
 }
 


