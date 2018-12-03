Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3907C64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B17D820834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B17D820834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725793AbeLCAct (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:49 -0500
Received: from mx2.suse.de ([195.135.220.15]:41074 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:49 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id C0483ADC0;
        Mon,  3 Dec 2018 00:32:41 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 07/23] SUNRPC: remove uid and gid from struct auth_cred
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703037.28598.9479511967056577427.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use cred->fsuid and cred->fsgid instead.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |   14 ++++++++------
 fs/nfsd/nfs4callback.c                 |    6 ++----
 include/linux/sunrpc/auth.h            |    3 ---
 net/sunrpc/auth.c                      |    6 +-----
 net/sunrpc/auth_generic.c              |   23 ++++++++---------------
 net/sunrpc/auth_gss/auth_gss.c         |    9 ++++-----
 net/sunrpc/auth_unix.c                 |   12 ++++++------
 7 files changed, 29 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c3eaa9d874c8..685b2639d42b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -414,6 +414,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		struct auth_cred acred = {};
 		struct rpc_cred	__rcu *cred;
 		struct cred *kcred;
+		kuid_t uid;
+		kgid_t gid;
 		u32 ds_count, fh_count, id;
 		int j;
 
@@ -481,14 +483,14 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		if (rc)
 			goto out_err_free;
 
-		acred.uid = make_kuid(&init_user_ns, id);
+		uid = make_kuid(&init_user_ns, id);
 
 		/* group */
 		rc = decode_name(&stream, &id);
 		if (rc)
 			goto out_err_free;
 
-		acred.gid = make_kgid(&init_user_ns, id);
+		gid = make_kgid(&init_user_ns, id);
 
 		if (gfp_flags & __GFP_FS)
 			kcred = prepare_kernel_cred(NULL);
@@ -500,8 +502,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		rc = -ENOMEM;
 		if (!kcred)
 			goto out_err_free;
-		kcred->fsuid = acred.uid;
-		kcred->fsgid = acred.gid;
+		kcred->fsuid = uid;
+		kcred->fsgid = gid;
 		acred.cred = kcred;
 
 		/* find the cred for it */
@@ -533,8 +535,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 		dprintk("%s: iomode %s uid %u gid %u\n", __func__,
 			lgr->range.iomode == IOMODE_READ ? "READ" : "RW",
-			from_kuid(&init_user_ns, acred.uid),
-			from_kgid(&init_user_ns, acred.gid));
+			from_kuid(&init_user_ns, uid),
+			from_kgid(&init_user_ns, gid));
 	}
 
 	p = xdr_inline_decode(&stream, 4);
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7c7e3510599d..c032e4c24a8d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -865,10 +865,8 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
 		if (!kcred)
 			return NULL;
 
-		acred.uid = ses->se_cb_sec.uid;
-		acred.gid = ses->se_cb_sec.gid;
-		kcred->uid = acred.uid;
-		kcred->gid = acred.gid;
+		kcred->uid = ses->se_cb_sec.uid;
+		kcred->gid = ses->se_cb_sec.gid;
 		acred.cred = kcred;
 		ret = auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
 		put_cred(kcred);
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 30eb9b9b9c8c..831ea65bd9f4 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -44,11 +44,8 @@ enum {
 					key will expire soon */
 };
 
-/* Work around the lack of a VFS credential */
 struct auth_cred {
 	const struct cred *cred;
-	kuid_t	uid;
-	kgid_t	gid;
 	const char *principal;
 	unsigned long ac_flags;
 	unsigned char machine_cred : 1;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index e1053b96e0e5..63e2d35c10d5 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -656,8 +656,6 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 		auth->au_ops->au_name);
 
 	memset(&acred, 0, sizeof(acred));
-	acred.uid = cred->fsuid;
-	acred.gid = cred->fsgid;
 	acred.cred = cred;
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
 	return ret;
@@ -675,7 +673,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
 	cred->cr_cred = get_cred(acred->cred);
-	cred->cr_uid = acred->uid;
+	cred->cr_uid = acred->cred->fsuid;
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
 
@@ -693,8 +691,6 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 {
 	struct rpc_auth *auth = task->tk_client->cl_auth;
 	struct auth_cred acred = {
-		.uid = GLOBAL_ROOT_UID,
-		.gid = GLOBAL_ROOT_GID,
 		.cred = get_task_cred(&init_task),
 	};
 	struct rpc_cred *ret;
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index a4ae7bd7ca7b..6c7c65da6063 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -18,9 +18,6 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define RPC_MACHINE_CRED_USERID		GLOBAL_ROOT_UID
-#define RPC_MACHINE_CRED_GROUPID	GLOBAL_ROOT_GID
-
 struct generic_cred {
 	struct rpc_cred gc_base;
 	struct auth_cred acred;
@@ -57,8 +54,6 @@ EXPORT_SYMBOL_GPL(rpc_lookup_cred_nonblock);
 struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
 {
 	struct auth_cred acred = {
-		.uid = RPC_MACHINE_CRED_USERID,
-		.gid = RPC_MACHINE_CRED_GROUPID,
 		.principal = service_name,
 		.machine_cred = 1,
 		.cred = get_task_cred(&init_task),
@@ -85,8 +80,8 @@ static struct rpc_cred *generic_bind_cred(struct rpc_task *task,
 static int
 generic_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 {
-	return hash_64(from_kgid(&init_user_ns, acred->gid) |
-		((u64)from_kuid(&init_user_ns, acred->uid) <<
+	return hash_64(from_kgid(&init_user_ns, acred->cred->fsgid) |
+		((u64)from_kuid(&init_user_ns, acred->cred->fsuid) <<
 			(sizeof(gid_t) * 8)), hashbits);
 }
 
@@ -111,8 +106,6 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 	rpcauth_init_cred(&gcred->gc_base, acred, &generic_auth, &generic_credops);
 	gcred->gc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
 
-	gcred->acred.uid = acred->uid;
-	gcred->acred.gid = acred->gid;
 	gcred->acred.cred = gcred->gc_base.cr_cred;
 	gcred->acred.ac_flags = 0;
 	gcred->acred.machine_cred = acred->machine_cred;
@@ -121,8 +114,8 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 	dprintk("RPC:       allocated %s cred %p for uid %d gid %d\n",
 			gcred->acred.machine_cred ? "machine" : "generic",
 			gcred,
-			from_kuid(&init_user_ns, acred->uid),
-			from_kgid(&init_user_ns, acred->gid));
+			from_kuid(&init_user_ns, acred->cred->fsuid),
+			from_kgid(&init_user_ns, acred->cred->fsgid));
 	return &gcred->gc_base;
 }
 
@@ -154,8 +147,8 @@ machine_cred_match(struct auth_cred *acred, struct generic_cred *gcred, int flag
 {
 	if (!gcred->acred.machine_cred ||
 	    gcred->acred.principal != acred->principal ||
-	    !uid_eq(gcred->acred.uid, acred->uid) ||
-	    !gid_eq(gcred->acred.gid, acred->gid))
+	    !uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
+	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid))
 		return 0;
 	return 1;
 }
@@ -173,8 +166,8 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	if (acred->machine_cred)
 		return machine_cred_match(acred, gcred, flags);
 
-	if (!uid_eq(gcred->acred.uid, acred->uid) ||
-	    !gid_eq(gcred->acred.gid, acred->gid) ||
+	if (!uid_eq(gcred->acred.cred->fsuid, acred->cred->fsuid) ||
+	    !gid_eq(gcred->acred.cred->fsgid, acred->cred->fsgid) ||
 	    gcred->acred.machine_cred != 0)
 		goto out_nomatch;
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 33267cb3b181..8c9e572aeea2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1248,7 +1248,7 @@ gss_dup_cred(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 	new = kzalloc(sizeof(*gss_cred), GFP_NOIO);
 	if (new) {
 		struct auth_cred acred = {
-			.uid = gss_cred->gc_base.cr_uid,
+			.cred = gss_cred->gc_base.cr_cred,
 		};
 		struct gss_cl_ctx *ctx =
 			rcu_dereference_protected(gss_cred->gc_ctx, 1);
@@ -1362,7 +1362,7 @@ gss_destroy_cred(struct rpc_cred *cred)
 static int
 gss_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 {
-	return hash_64(from_kuid(&init_user_ns, acred->uid), hashbits);
+	return hash_64(from_kuid(&init_user_ns, acred->cred->fsuid), hashbits);
 }
 
 /*
@@ -1382,7 +1382,7 @@ gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	int err = -ENOMEM;
 
 	dprintk("RPC:       %s for uid %d, flavor %d\n",
-		__func__, from_kuid(&init_user_ns, acred->uid),
+		__func__, from_kuid(&init_user_ns, acred->cred->fsuid),
 		auth->au_flavor);
 
 	if (!(cred = kzalloc(sizeof(*cred), gfp)))
@@ -1523,7 +1523,7 @@ gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 	}
 	if (gss_cred->gc_principal != NULL)
 		return 0;
-	ret = uid_eq(rc->cr_uid, acred->uid);
+	ret = uid_eq(rc->cr_uid, acred->cred->fsuid);
 
 check_expire:
 	if (ret == 0)
@@ -1608,7 +1608,6 @@ static int gss_renew_cred(struct rpc_task *task)
 						 gc_base);
 	struct rpc_auth *auth = oldcred->cr_auth;
 	struct auth_cred acred = {
-		.uid = oldcred->cr_uid,
 		.cred = oldcred->cr_cred,
 		.principal = gss_cred->gc_principal,
 		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 0a6397a099d6..7d4099fc18e7 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -48,8 +48,8 @@ unx_destroy(struct rpc_auth *auth)
 static int
 unx_hash_cred(struct auth_cred *acred, unsigned int hashbits)
 {
-	return hash_64(from_kgid(&init_user_ns, acred->gid) |
-		((u64)from_kuid(&init_user_ns, acred->uid) <<
+	return hash_64(from_kgid(&init_user_ns, acred->cred->fsgid) |
+		((u64)from_kuid(&init_user_ns, acred->cred->fsuid) <<
 			(sizeof(gid_t) * 8)), hashbits);
 }
 
@@ -70,8 +70,8 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	unsigned int i;
 
 	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
-			from_kuid(&init_user_ns, acred->uid),
-			from_kgid(&init_user_ns, acred->gid));
+			from_kuid(&init_user_ns, acred->cred->fsuid),
+			from_kgid(&init_user_ns, acred->cred->fsgid));
 
 	if (!(cred = kmalloc(sizeof(*cred), gfp)))
 		return ERR_PTR(-ENOMEM);
@@ -84,7 +84,7 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	if (groups > UNX_NGROUPS)
 		groups = UNX_NGROUPS;
 
-	cred->uc_gid = acred->gid;
+	cred->uc_gid = acred->cred->fsgid;
 	for (i = 0; i < groups; i++)
 		cred->uc_gids[i] = acred->cred->group_info->gid[i];
 	if (i < UNX_NGROUPS)
@@ -127,7 +127,7 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 	unsigned int i;
 
 
-	if (!uid_eq(cred->uc_uid, acred->uid) || !gid_eq(cred->uc_gid, acred->gid))
+	if (!uid_eq(cred->uc_uid, acred->cred->fsuid) || !gid_eq(cred->uc_gid, acred->cred->fsgid))
 		return 0;
 
 	if (acred->cred && acred->cred->group_info != NULL)


