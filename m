Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F56C64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3421120834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3421120834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725968AbeLCAcm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:42 -0500
Received: from mx2.suse.de ([195.135.220.15]:41040 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:42 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 488CBADC0;
        Mon,  3 Dec 2018 00:32:35 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 06/23] SUNRPC: remove groupinfo from struct auth_cred.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703032.28598.4796101096110371823.stgit@noble>
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

We can use cred->groupinfo (from the 'struct cred') instead.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |   14 +-------------
 include/linux/sunrpc/auth.h            |    1 -
 net/sunrpc/auth.c                      |    1 -
 net/sunrpc/auth_generic.c              |   17 +++++++----------
 net/sunrpc/auth_unix.c                 |   12 ++++++------
 5 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 8d1f60e38397..c3eaa9d874c8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -28,9 +28,6 @@
 #define FF_LAYOUT_POLL_RETRY_MAX     (15*HZ)
 #define FF_LAYOUTRETURN_MAXERR 20
 
-
-static struct group_info	*ff_zero_group;
-
 static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 		struct nfs_pgio_header *hdr);
 static int ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
@@ -414,7 +411,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 	for (i = 0; i < fls->mirror_array_cnt; i++) {
 		struct nfs4_ff_layout_mirror *mirror;
-		struct auth_cred acred = { .group_info = ff_zero_group };
+		struct auth_cred acred = {};
 		struct rpc_cred	__rcu *cred;
 		struct cred *kcred;
 		u32 ds_count, fh_count, id;
@@ -2398,11 +2395,6 @@ static int __init nfs4flexfilelayout_init(void)
 {
 	printk(KERN_INFO "%s: NFSv4 Flexfile Layout Driver Registering...\n",
 	       __func__);
-	if (!ff_zero_group) {
-		ff_zero_group = groups_alloc(0);
-		if (!ff_zero_group)
-			return -ENOMEM;
-	}
 	return pnfs_register_layoutdriver(&flexfilelayout_type);
 }
 
@@ -2411,10 +2403,6 @@ static void __exit nfs4flexfilelayout_exit(void)
 	printk(KERN_INFO "%s: NFSv4 Flexfile Layout Driver Unregistering...\n",
 	       __func__);
 	pnfs_unregister_layoutdriver(&flexfilelayout_type);
-	if (ff_zero_group) {
-		put_group_info(ff_zero_group);
-		ff_zero_group = NULL;
-	}
 }
 
 MODULE_ALIAS("nfs-layouttype4-4");
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 1f95bd612053..30eb9b9b9c8c 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -49,7 +49,6 @@ struct auth_cred {
 	const struct cred *cred;
 	kuid_t	uid;
 	kgid_t	gid;
-	struct group_info *group_info;
 	const char *principal;
 	unsigned long ac_flags;
 	unsigned char machine_cred : 1;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index a7e08e44f92b..e1053b96e0e5 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -658,7 +658,6 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	memset(&acred, 0, sizeof(acred));
 	acred.uid = cred->fsuid;
 	acred.gid = cred->fsgid;
-	acred.group_info = cred->group_info;
 	acred.cred = cred;
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
 	return ret;
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index 16a0a4b89bb4..a4ae7bd7ca7b 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -113,11 +113,8 @@ generic_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, g
 
 	gcred->acred.uid = acred->uid;
 	gcred->acred.gid = acred->gid;
-	gcred->acred.group_info = acred->group_info;
 	gcred->acred.cred = gcred->gc_base.cr_cred;
 	gcred->acred.ac_flags = 0;
-	if (gcred->acred.group_info != NULL)
-		get_group_info(gcred->acred.group_info);
 	gcred->acred.machine_cred = acred->machine_cred;
 	gcred->acred.principal = acred->principal;
 
@@ -135,8 +132,6 @@ generic_free_cred(struct rpc_cred *cred)
 	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
 
 	dprintk("RPC:       generic_free_cred %p\n", gcred);
-	if (gcred->acred.group_info != NULL)
-		put_group_info(gcred->acred.group_info);
 	put_cred(cred->cr_cred);
 	kfree(gcred);
 }
@@ -173,6 +168,7 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 {
 	struct generic_cred *gcred = container_of(cred, struct generic_cred, gc_base);
 	int i;
+	struct group_info *a, *g;
 
 	if (acred->machine_cred)
 		return machine_cred_match(acred, gcred, flags);
@@ -182,16 +178,17 @@ generic_match(struct auth_cred *acred, struct rpc_cred *cred, int flags)
 	    gcred->acred.machine_cred != 0)
 		goto out_nomatch;
 
+	a = acred->cred->group_info;
+	g = gcred->acred.cred->group_info;
 	/* Optimisation in the case where pointers are identical... */
-	if (gcred->acred.group_info == acred->group_info)
+	if (a == g)
 		goto out_match;
 
 	/* Slow path... */
-	if (gcred->acred.group_info->ngroups != acred->group_info->ngroups)
+	if (g->ngroups != a->ngroups)
 		goto out_nomatch;
-	for (i = 0; i < gcred->acred.group_info->ngroups; i++) {
-		if (!gid_eq(gcred->acred.group_info->gid[i],
-				acred->group_info->gid[i]))
+	for (i = 0; i < g->ngroups; i++) {
+		if (!gid_eq(g->gid[i], a->gid[i]))
 			goto out_nomatch;
 	}
 out_match:
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 36e01384f082..0a6397a099d6 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -79,14 +79,14 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 	rpcauth_init_cred(&cred->uc_base, acred, auth, &unix_credops);
 	cred->uc_base.cr_flags = 1UL << RPCAUTH_CRED_UPTODATE;
 
-	if (acred->group_info != NULL)
-		groups = acred->group_info->ngroups;
+	if (acred->cred && acred->cred->group_info != NULL)
+		groups = acred->cred->group_info->ngroups;
 	if (groups > UNX_NGROUPS)
 		groups = UNX_NGROUPS;
 
 	cred->uc_gid = acred->gid;
 	for (i = 0; i < groups; i++)
-		cred->uc_gids[i] = acred->group_info->gid[i];
+		cred->uc_gids[i] = acred->cred->group_info->gid[i];
 	if (i < UNX_NGROUPS)
 		cred->uc_gids[i] = INVALID_GID;
 
@@ -130,12 +130,12 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 	if (!uid_eq(cred->uc_uid, acred->uid) || !gid_eq(cred->uc_gid, acred->gid))
 		return 0;
 
-	if (acred->group_info != NULL)
-		groups = acred->group_info->ngroups;
+	if (acred->cred && acred->cred->group_info != NULL)
+		groups = acred->cred->group_info->ngroups;
 	if (groups > UNX_NGROUPS)
 		groups = UNX_NGROUPS;
 	for (i = 0; i < groups ; i++)
-		if (!gid_eq(cred->uc_gids[i], acred->group_info->gid[i]))
+		if (!gid_eq(cred->uc_gids[i], acred->cred->group_info->gid[i]))
 			return 0;
 	if (groups < UNX_NGROUPS && gid_valid(cred->uc_gids[groups]))
 		return 0;


