Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52097 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDBo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:44 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 4/8] sunrpc/auth: add 'rcu_walk' arg to rpc_lookup_cred.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.14840.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This arg causes rpc_lookup_cred to set RPCAUTH_LOOKUP_RCU when
performing the credential lookup.  Most callers pass '0',
except nfs_permission() which passes (mask & MAY_NOT_BLOCK).

This doesn't speed up nfs_permission yet as it is not yet
safe to call nfs_do_access with the returned cred.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c                |    8 ++++----
 fs/nfs/inode.c              |    2 +-
 fs/nfs/nfs4proc.c           |    2 +-
 fs/nfs/unlink.c             |    4 ++--
 include/linux/sunrpc/auth.h |    2 +-
 net/sunrpc/auth_generic.c   |    5 +++--
 6 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index dcec2c56fe13..36e12f545fd7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -102,7 +102,7 @@ nfs_opendir(struct inode *inode, struct file *filp)
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
-	cred = rpc_lookup_cred();
+	cred = rpc_lookup_cred(0);
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
 	ctx = alloc_nfs_open_dir_context(inode, cred);
@@ -2308,11 +2308,11 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
-	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
 
-	cred = rpc_lookup_cred();
+	cred = rpc_lookup_cred(mask & MAY_NOT_BLOCK);
 	if (!IS_ERR(cred)) {
+		if (mask & MAY_NOT_BLOCK)
+			return -ECHILD;
 		res = nfs_do_access(inode, cred, mask);
 		put_rpccred(cred);
 	} else
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 28a0a3cbd3b7..59e57cceeab5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -717,7 +717,7 @@ EXPORT_SYMBOL_GPL(nfs_close_context);
 struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
 {
 	struct nfs_open_context *ctx;
-	struct rpc_cred *cred = rpc_lookup_cred();
+	struct rpc_cred *cred = rpc_lookup_cred(0);
 	if (IS_ERR(cred))
 		return ERR_CAST(cred);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 42da6af77587..922b924f0a7c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4733,7 +4733,7 @@ nfs4_set_security_label(struct dentry *dentry, const void *buf, size_t buflen)
 	ilabel.label = (char *)buf;
 	ilabel.len = buflen;
 
-	cred = rpc_lookup_cred();
+	cred = rpc_lookup_cred(0);
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
 
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11d78944de79..34c0b878f2a8 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -258,7 +258,7 @@ nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 	if (data == NULL)
 		goto out;
 
-	data->cred = rpc_lookup_cred();
+	data->cred = rpc_lookup_cred(0);
 	if (IS_ERR(data->cred)) {
 		status = PTR_ERR(data->cred);
 		goto out_free;
@@ -418,7 +418,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 		return ERR_PTR(-ENOMEM);
 	task_setup_data.callback_data = data;
 
-	data->cred = rpc_lookup_cred();
+	data->cred = rpc_lookup_cred(0);
 	if (IS_ERR(data->cred)) {
 		struct rpc_task *task = ERR_CAST(data->cred);
 		kfree(data);
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 3f158ae1d6fd..ef354ccb709d 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -153,7 +153,7 @@ void			rpcauth_remove_module(void);
 void			rpc_destroy_generic_auth(void);
 void 			rpc_destroy_authunix(void);
 
-struct rpc_cred *	rpc_lookup_cred(void);
+struct rpc_cred *	rpc_lookup_cred(int rcu_walk);
 struct rpc_cred *	rpc_lookup_machine_cred(const char *service_name);
 int			rpcauth_register(const struct rpc_authops *);
 int			rpcauth_unregister(const struct rpc_authops *);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index ed04869b2d4f..ffbd66b94781 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -32,9 +32,10 @@ static const struct rpc_credops generic_credops;
 /*
  * Public call interface
  */
-struct rpc_cred *rpc_lookup_cred(void)
+struct rpc_cred *rpc_lookup_cred(int rcu_walk)
 {
-	return rpcauth_lookupcred(&generic_auth, 0);
+	return rpcauth_lookupcred(&generic_auth,
+				  rcu_walk ? RPCAUTH_LOOKUP_RCU : 0);
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 


