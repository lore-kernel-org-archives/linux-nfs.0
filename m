Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=FUZZY_CREDIT,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 064D5C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE0F820834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE0F820834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725789AbeLCAcg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:36 -0500
Received: from mx2.suse.de ([195.135.220.15]:40962 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:36 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id D00EDAD90;
        Mon,  3 Dec 2018 00:32:28 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 05/23] SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703024.28598.12949984169065956916.stgit@noble>
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

The SUNRPC credential framework was put together before
Linux has 'struct cred'.  Now that we have it, it makes sense to
use it.
This first step just includes a suitable 'struct cred *' pointer
in every 'struct auth_cred' and almost every 'struct rpc_cred'.

The rpc_cred used for auth_null has a NULL 'struct cred *' as nothing
else really makes sense.

For rpc_cred, the pointer is reference counted.
For auth_cred it isn't.  struct auth_cred are either allocated on
the stack, in which case the thread owns a reference to the auth,
or are part of 'struct generic_cred' in which case gc_base owns the
reference, and "acred" shares it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |   17 +++++++++++++++++
 fs/nfsd/nfs4callback.c                 |   13 ++++++++++++-
 include/linux/sunrpc/auth.h            |    2 ++
 net/sunrpc/auth.c                      |    8 +++++++-
 net/sunrpc/auth_generic.c              |    8 +++++++-
 net/sunrpc/auth_gss/auth_gss.c         |    2 ++
 net/sunrpc/auth_unix.c                 |    1 +
 7 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 74b36ed883ca..8d1f60e38397 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -9,6 +9,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/module.h>
+#include <linux/sched/mm.h>
 
 #include <linux/sunrpc/metrics.h>
 
@@ -415,6 +416,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		struct nfs4_ff_layout_mirror *mirror;
 		struct auth_cred acred = { .group_info = ff_zero_group };
 		struct rpc_cred	__rcu *cred;
+		struct cred *kcred;
 		u32 ds_count, fh_count, id;
 		int j;
 
@@ -491,8 +493,23 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 		acred.gid = make_kgid(&init_user_ns, id);
 
+		if (gfp_flags & __GFP_FS)
+			kcred = prepare_kernel_cred(NULL);
+		else {
+			unsigned int nofs_flags = memalloc_nofs_save();
+			kcred = prepare_kernel_cred(NULL);
+			memalloc_nofs_restore(nofs_flags);
+		}
+		rc = -ENOMEM;
+		if (!kcred)
+			goto out_err_free;
+		kcred->fsuid = acred.uid;
+		kcred->fsgid = acred.gid;
+		acred.cred = kcred;
+
 		/* find the cred for it */
 		rcu_assign_pointer(cred, rpc_lookup_generic_cred(&acred, 0, gfp_flags));
+		put_cred(kcred);
 		if (IS_ERR(cred)) {
 			rc = PTR_ERR(cred);
 			goto out_err_free;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 25987bcdf96f..7c7e3510599d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -858,10 +858,21 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
 	} else {
 		struct rpc_auth *auth = client->cl_auth;
 		struct auth_cred acred = {};
+		struct cred *kcred;
+		struct rpc_cred *ret;
+
+		kcred = prepare_kernel_cred(NULL);
+		if (!kcred)
+			return NULL;
 
 		acred.uid = ses->se_cb_sec.uid;
 		acred.gid = ses->se_cb_sec.gid;
-		return auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
+		kcred->uid = acred.uid;
+		kcred->gid = acred.gid;
+		acred.cred = kcred;
+		ret = auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
+		put_cred(kcred);
+		return ret;
 	}
 }
 
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index c4db9424b63b..1f95bd612053 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -46,6 +46,7 @@ enum {
 
 /* Work around the lack of a VFS credential */
 struct auth_cred {
+	const struct cred *cred;
 	kuid_t	uid;
 	kgid_t	gid;
 	struct group_info *group_info;
@@ -68,6 +69,7 @@ struct rpc_cred {
 	unsigned long		cr_expire;	/* when to gc */
 	unsigned long		cr_flags;	/* various flags */
 	refcount_t		cr_count;	/* ref count */
+	const struct cred	*cr_cred;
 
 	kuid_t			cr_uid;
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ad8ead738981..a7e08e44f92b 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -659,6 +659,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	acred.uid = cred->fsuid;
 	acred.gid = cred->fsgid;
 	acred.group_info = cred->group_info;
+	acred.cred = cred;
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
 	return ret;
 }
@@ -674,6 +675,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 	cred->cr_auth = auth;
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
+	cred->cr_cred = get_cred(acred->cred);
 	cred->cr_uid = acred->uid;
 }
 EXPORT_SYMBOL_GPL(rpcauth_init_cred);
@@ -694,11 +696,15 @@ rpcauth_bind_root_cred(struct rpc_task *task, int lookupflags)
 	struct auth_cred acred = {
 		.uid = GLOBAL_ROOT_UID,
 		.gid = GLOBAL_ROOT_GID,
+		.cred = get_task_cred(&init_task),
 	};
+	struct rpc_cred *ret;
 
 	dprintk("RPC: %5u looking up %s cred\n",
 		task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
-	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
+	ret = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
+	put_cred(acred.cred);
+	return ret;
 }
 
 static struct rpc_cred *
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index ab4a3be1542a..16a0a4b89bb4 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -61,11 +61,15 @@ struct rpc_cred *rpc_lookup_machine_cred(const char *service_name)
 		.gid = RPC_MACHINE_CRED_GROUPID,
 		.principal = service_name,
 		.machine_cred = 1,
+		.cred = get_task_cred(&init_task),
 	};
+	struct rpc_cred *ret;
 
 	dprintk("RPC:       looking up machine cred for service %s\n",
 			service_name);
-	return generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
+	ret = generic_auth.au_ops->lookup_cred(&generic_auth, &acred, 0);
+	put_cred(acred.cred);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(rpc_lookup_machine_cred);
 
@@ -110,6 +114,7 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 	gcred->acred.uid = acred->uid;
 	gcred->acred.gid = acred->gid;
 	gcred->acred.group_info = acred->group_info;
+	gcred->acred.cred = gcred->gc_base.cr_cred;
 	gcred->acred.ac_flags = 0;
 	if (gcred->acred.group_info != NULL)
 		get_group_info(gcred->acred.group_info);
@@ -132,6 +137,7 @@ generic_free_cred(struct rpc_cred *cred)
 	dprintk("RPC:       generic_free_cred %p\n", gcred);
 	if (gcred->acred.group_info != NULL)
 		put_group_info(gcred->acred.group_info);
+	put_cred(cred->cr_cred);
 	kfree(gcred);
 }
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5d3f252659f1..33267cb3b181 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1343,6 +1343,7 @@ gss_destroy_nullcred(struct rpc_cred *cred)
 	struct gss_cl_ctx *ctx = rcu_dereference_protected(gss_cred->gc_ctx, 1);
 
 	RCU_INIT_POINTER(gss_cred->gc_ctx, NULL);
+	put_cred(cred->cr_cred);
 	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
 	if (ctx)
 		gss_put_ctx(ctx);
@@ -1608,6 +1609,7 @@ static int gss_renew_cred(struct rpc_task *task)
 	struct rpc_auth *auth = oldcred->cr_auth;
 	struct auth_cred acred = {
 		.uid = oldcred->cr_uid,
+		.cred = oldcred->cr_cred,
 		.principal = gss_cred->gc_principal,
 		.machine_cred = (gss_cred->gc_principal != NULL ? 1 : 0),
 	};
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 4c1c7e56288f..36e01384f082 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -97,6 +97,7 @@ static void
 unx_free_cred(struct unx_cred *unx_cred)
 {
 	dprintk("RPC:       unx_free_cred %p\n", unx_cred);
+	put_cred(unx_cred->uc_base.cr_cred);
 	kfree(unx_cred);
 }
 


