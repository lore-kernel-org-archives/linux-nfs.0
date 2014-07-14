Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53421 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbaGNBbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:31:18 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 3/7] sunrpc/auth: allow lockless (rcu) lookup of credential
 cache.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714012820.12562.81338.stgit@notabene.brown>
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new flag RPCAUTH_LOOKUP_RCU to credential lookup avoids locking,
does not take a reference on the returned credential, and returns
-ECHILD if a simple lookup was not possible.

The returned value can only be used within an rcu_read_lock protected
region.

The main user of this is the new rpc_lookup_cred_nonblock() which
returns a pointer to the current credential which is only rcu-safe (no
ref-count held), and might return -ECHILD if allocation was required.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/auth.h |    2 ++
 net/sunrpc/auth.c           |   17 +++++++++++++++--
 net/sunrpc/auth_generic.c   |    6 ++++++
 net/sunrpc/auth_null.c      |    2 ++
 4 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 790be1472792..28ffc8476875 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -103,6 +103,7 @@ struct rpc_auth_create_args {
 
 /* Flags for rpcauth_lookupcred() */
 #define RPCAUTH_LOOKUP_NEW		0x01	/* Accept an uninitialised cred */
+#define RPCAUTH_LOOKUP_RCU		0x02	/* lock-less lookup */
 
 /*
  * Client authentication ops
@@ -153,6 +154,7 @@ void			rpc_destroy_generic_auth(void);
 void 			rpc_destroy_authunix(void);
 
 struct rpc_cred *	rpc_lookup_cred(void);
+struct rpc_cred *	rpc_lookup_cred_nonblock(void);
 struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index f77366717420..794fc0f4fc4c 100644
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
 EXPORT_SYMBOL_GPL(rpcauth_lookupcred);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index ed04869b2d4f..6f6b829c9e8e 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -38,6 +38,12 @@ struct rpc_cred *rpc_lookup_cred(void)
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 
+struct rpc_cred *rpc_lookup_cred_nonblock(void)
+{
+	return rpcauth_lookupcred(&generic_auth, RPCAUTH_LOOKUP_RCU);
+}
+EXPORT_SYMBOL_GPL(rpc_lookup_cred_nonblock);
+
 /*
  * Public call interface for looking up machine creds.
  */
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
 


