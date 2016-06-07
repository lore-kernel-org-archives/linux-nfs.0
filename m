Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbcFGTOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2016 15:14:51 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH RESEND] sunrpc: move NO_CRKEY_TIMEOUT to the auth->au_flags
Date: Tue,  7 Jun 2016 15:14:48 -0400
Message-Id: <1465326888-11185-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A generic_cred can be used to look up a unx_cred or a gss_cred, so it's
not really safe to use the the generic_cred->acred->ac_flags to store
the NO_CRKEY_TIMEOUT flag.  A lookup for a unx_cred triggered while the
KEY_EXPIRE_SOON flag is already set will cause both NO_CRKEY_TIMEOUT and
KEY_EXPIRE_SOON to be set in the ac_flags, leaving the user associated
with the auth_cred to be in a state where they're perpetually doing 4K
NFS_FILE_SYNC writes.

This can be reproduced as follows:

1. Mount two NFS filesystems, one with sec=krb5 and one with sec=sys.
They do not need to be the same export, nor do they even need to be from
the same NFS server.  Also, v3 is fine.
$ sudo mount -o v3,sec=krb5 server1:/export /mnt/krb5
$ sudo mount -o v3,sec=sys server2:/export /mnt/sys

2. As the normal user, before accessing the kerberized mount, kinit with
a short lifetime (but not so short that renewing the ticket would leave
you within the 4-minute window again by the time the original ticket
expires), e.g.
$ kinit -l 10m -r 60m

3. Do some I/O to the kerberized mount and verify that the writes are
wsize, UNSTABLE:
$ dd if=/dev/zero of=/mnt/krb5/file bs=1M count=1

4. Wait until you're within 4 minutes of key expiry, then do some more
I/O to the kerberized mount to ensure that RPC_CRED_KEY_EXPIRE_SOON gets
set.  Verify that the writes are 4K, FILE_SYNC:
$ dd if=/dev/zero of=/mnt/krb5/file bs=1M count=1

5. Now do some I/O to the sec=sys mount.  This will cause
RPC_CRED_NO_CRKEY_TIMEOUT to be set:
$ dd if=/dev/zero of=/mnt/sys/file bs=1M count=1

6. Writes for that user will now be permanently 4K, FILE_SYNC for that
user, regardless of which mount is being written to, until you reboot
the client.  Renewing the kerberos ticket (assuming it hasn't already
expired) will have no effect.  Grabbing a new kerberos ticket at this
point will have no effect either.

Move the flag to the auth->au_flags field (which is currently unused)
and rename it slightly to reflect that it's no longer associated with
the auth_cred->ac_flags.  Add the rpc_auth to the arg list of
rpcauth_cred_key_to_expire and check the au_flags there too.  Finally,
add the inode to the arg list of nfs_ctx_key_to_expire so we can
determine the rpc_auth to pass to rpcauth_cred_key_to_expire.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/file.c                  | 4 ++--
 fs/nfs/internal.h              | 2 +-
 fs/nfs/write.c                 | 6 ++++--
 include/linux/sunrpc/auth.h    | 6 ++++--
 net/sunrpc/auth.c              | 4 +++-
 net/sunrpc/auth_generic.c      | 9 +--------
 net/sunrpc/auth_gss/auth_gss.c | 1 +
 net/sunrpc/auth_null.c         | 1 +
 net/sunrpc/auth_unix.c         | 1 +
 9 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 717a8d6..6bcd891 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -432,7 +432,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 		return status;
 	NFS_I(mapping->host)->write_io += copied;
 
-	if (nfs_ctx_key_to_expire(ctx)) {
+	if (nfs_ctx_key_to_expire(ctx, mapping->host)) {
 		status = nfs_wb_all(mapping->host);
 		if (status < 0)
 			return status;
@@ -645,7 +645,7 @@ static int nfs_need_check_write(struct file *filp, struct inode *inode)
 
 	ctx = nfs_file_open_context(filp);
 	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags) ||
-	    nfs_ctx_key_to_expire(ctx))
+	    nfs_ctx_key_to_expire(ctx, inode))
 		return 1;
 	return 0;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5154fa6..ca87787 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -496,7 +496,7 @@ void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 		    struct inode *inode,
 		    struct nfs_direct_req *dreq);
 int nfs_key_timeout_notify(struct file *filp, struct inode *inode);
-bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx, struct inode *inode);
 void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio);
 
 #ifdef CONFIG_MIGRATION
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e1c74d3..0b949a0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1195,9 +1195,11 @@ nfs_key_timeout_notify(struct file *filp, struct inode *inode)
 /*
  * Test if the open context credential key is marked to expire soon.
  */
-bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx)
+bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx, struct inode *inode)
 {
-	return rpcauth_cred_key_to_expire(ctx->cred);
+	struct rpc_auth *auth = NFS_SERVER(inode)->client->cl_auth;
+
+	return rpcauth_cred_key_to_expire(auth, ctx->cred);
 }
 
 /*
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 8997915..f890a29 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -37,7 +37,6 @@ struct rpcsec_gss_info;
 
 /* auth_cred ac_flags bits */
 enum {
-	RPC_CRED_NO_CRKEY_TIMEOUT = 0, /* underlying cred has no key timeout */
 	RPC_CRED_KEY_EXPIRE_SOON = 1, /* underlying cred key will expire soon */
 	RPC_CRED_NOTIFY_TIMEOUT = 2,   /* nofity generic cred when underlying
 					key will expire soon */
@@ -82,6 +81,9 @@ struct rpc_cred {
 
 #define RPCAUTH_CRED_MAGIC	0x0f4aa4f0
 
+/* rpc_auth au_flags */
+#define RPCAUTH_AUTH_NO_CRKEY_TIMEOUT	0x0001 /* underlying cred has no key timeout */
+
 /*
  * Client authentication handle
  */
@@ -196,7 +198,7 @@ void			rpcauth_destroy_credcache(struct rpc_auth *);
 void			rpcauth_clear_credcache(struct rpc_cred_cache *);
 int			rpcauth_key_timeout_notify(struct rpc_auth *,
 						struct rpc_cred *);
-bool			rpcauth_cred_key_to_expire(struct rpc_cred *);
+bool			rpcauth_cred_key_to_expire(struct rpc_auth *, struct rpc_cred *);
 char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
 static inline
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 040ff62..696eb39 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -359,8 +359,10 @@ rpcauth_key_timeout_notify(struct rpc_auth *auth, struct rpc_cred *cred)
 EXPORT_SYMBOL_GPL(rpcauth_key_timeout_notify);
 
 bool
-rpcauth_cred_key_to_expire(struct rpc_cred *cred)
+rpcauth_cred_key_to_expire(struct rpc_auth *auth, struct rpc_cred *cred)
 {
+	if (auth->au_flags & RPCAUTH_AUTH_NO_CRKEY_TIMEOUT)
+		return false;
 	if (!cred->cr_ops->crkey_to_expire)
 		return false;
 	return cred->cr_ops->crkey_to_expire(cred);
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 54dd3fd..1682195 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -224,7 +224,7 @@ generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
 
 
 	/* Fast track for non crkey_timeout (no key) underlying credentials */
-	if (test_bit(RPC_CRED_NO_CRKEY_TIMEOUT, &acred->ac_flags))
+	if (auth->au_flags & RPCAUTH_AUTH_NO_CRKEY_TIMEOUT)
 		return 0;
 
 	/* Fast track for the normal case */
@@ -236,12 +236,6 @@ generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
 	if (IS_ERR(tcred))
 		return -EACCES;
 
-	if (!tcred->cr_ops->crkey_timeout) {
-		set_bit(RPC_CRED_NO_CRKEY_TIMEOUT, &acred->ac_flags);
-		ret = 0;
-		goto out_put;
-	}
-
 	/* Test for the almost error case */
 	ret = tcred->cr_ops->crkey_timeout(tcred);
 	if (ret != 0) {
@@ -257,7 +251,6 @@ generic_key_timeout(struct rpc_auth *auth, struct rpc_cred *cred)
 		set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
 	}
 
-out_put:
 	put_rpccred(tcred);
 	return ret;
 }
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e64ae93..813a3cd 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1015,6 +1015,7 @@ gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	auth = &gss_auth->rpc_auth;
 	auth->au_cslack = GSS_CRED_SLACK >> 2;
 	auth->au_rslack = GSS_VERF_SLACK >> 2;
+	auth->au_flags = 0;
 	auth->au_ops = &authgss_ops;
 	auth->au_flavor = flavor;
 	atomic_set(&auth->au_count, 1);
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 8d9eb4d..4d17376 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -115,6 +115,7 @@ static
 struct rpc_auth null_auth = {
 	.au_cslack	= NUL_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
+	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authnull_ops,
 	.au_flavor	= RPC_AUTH_NULL,
 	.au_count	= ATOMIC_INIT(0),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 9f65452..a99278c 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -228,6 +228,7 @@ static
 struct rpc_auth		unix_auth = {
 	.au_cslack	= UNX_CALLSLACK,
 	.au_rslack	= NUL_REPLYSLACK,
+	.au_flags	= RPCAUTH_AUTH_NO_CRKEY_TIMEOUT,
 	.au_ops		= &authunix_ops,
 	.au_flavor	= RPC_AUTH_UNIX,
 	.au_count	= ATOMIC_INIT(0),
-- 
2.4.11

