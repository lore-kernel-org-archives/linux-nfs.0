Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 701D353B5FD;
	Wed, 23 Sep 2026 16:14:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790180092; cv=none; b=tZfk4VL0bib29A3U8o2/jw/y/P3xQVUJInPzoWkSmITSp82ODRs6or96jUSSnxEYUgvkhR8eii3DRWX1nyvqjBIDXcCDUelCJDwFwL6dVDDthG2ubj1r3LQuKPa0s1zZPgtzlMXrSG+tSzrb68fHENZZaFGAw61OCv5w4epNIyI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790180092; c=relaxed/simple;
	bh=/RwWDMsXzAclPxLm6EmJ4Teq6Mbe4f6cAJ3MUJiCJ/Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=d3tCBoFx+Ji9gTkPHQS24ruKqscTDDKRXuLeufpwmPTljn+LjlC22b4eD+wFDulXLcbtzNNg3GsEtpUHuLPVp22Y9OkRrQaKjer12+XOYbJNtOEf0qNjM1DPQAlZSLshglk1p+O2VUAiXPOQc7NB9+lycMheNGKQtsCwYRu+23A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JJkWB/gF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JJkWB/gF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3D3CF1F00898;
	Wed, 23 Sep 2026 16:14:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790180090;
	bh=aFxygYdGfP94b3sl4Z7KcPDLu1hauj44aNvCaXp+FAM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JJkWB/gFl2/5KPvRZrxogufT4yqsiHgKwenrauNuSVRy0W/1V1a4hdHl9x5D1kLcq
	 pPFOqiir5UBGPhdLqiJLQ7KflM/1q6UpTOMGIRo8/upSuYtnRcAPLJjVOp/e+jCSqO
	 uXX0myVdeDsSeWIdvJWTdrGgg9ll97puMGvkwHnt1bRdVibi2hLeFlNGUVn+bjFtVp
	 GLB0AOMe6KQ1dT/ScCV97B6ywlWIMTqanXfHr77Hvhazct0y08SVWHec3i9U/QXaFm
	 bax9Y3g5A2pzjka7hy31ETZTpwXDFVj8CEYhtkHU5aTY5oDI1GuuqrtgQqplmXGsCg
	 4xltFTI9V3ohg==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 12:14:22 -0400
Subject: [PATCH 2/2] nfsd: remove CONFIG_NFSD_LEGACY_CLIENT_TRACKING
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-nfsd-legacy-v1-2-8490c0c12ea5@kernel.org>
References: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
In-Reply-To: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=28884; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/RwWDMsXzAclPxLm6EmJ4Teq6Mbe4f6cAJ3MUJiCJ/Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/r3uG8SM3WMGkCZ0uQK/g9iHw3fPuTYworZq
 XjZaxeIN8eJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarP69wAKCRAADmhBGVaC
 FXIUD/0b6MbCYWBSIQ/hjT+qmI1Px80izmZr3vN7JVRa/FfXkElkwDCOOE7Gvey4bo1C2k4LJtl
 0HBAjgl1vxKB25XyNLCI11cDdGCH+Hynp+TJat4zPWOkYxMPtEVkxdc5fnzx2grA23GXrdL9dse
 vIm3NHY6GVVvVL4+pGtoovYSGfLlB4OkCvxQIm+4gYAi6IiUwkS+Q0JvPu4LqkNetGjbR6/o2Ge
 AMMkGvRmn8kzlNha8iYmAxHOYb8H9oZvW78+8QM/r2d0+YPNGWlRlmjZRx1GeD1PQGpP6/Cn5wo
 ixmD1zJ8Pjw3ge70yLYuHURGUokVteMSLOUqOwNwhKr/iXOX2eL+GSfA2Mvh5bwMw1Cyb9D6v+N
 9fkYc3bu7RGevvl0y/tOQCrm0UvlRpW2fBLE3LG6p9R8pe3/NDedGpEHzxejdFjCHGJ48NRCQy6
 fEYSuBnN3Cj9iPH9KMO8231fJ1zKXUF/DeDYyoZr83rh5Wd47Dt1o4lIn5TrGQlxZOODHGwZXJL
 PXxStR8DHrpMbfvpvN7c2u/zQxs8IjVgq6PZH+6yCibdqb9TuUTAS3ME4GS7YDmfAbwFLMmNOp/
 udtvUQaOtEGSNexreEnZQFgEXUDOIBumezFxPel1cJjyTeUptuNsC2WhHs+Wrty8DHrRsnLeNW/
 ka/tibTu7Q/m4rw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Remove the deprecated Kconfig option and the last legacy client
tracking backend, the on-disk recoverydir, along with the
nfsv4recoverydir file, the nfsd_ctl_recoverydir tracepoint, and the
MD5-based hashed recdir names. nfsdcld is now the only client tracking
method.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 arch/s390/configs/debug_defconfig |   1 -
 arch/s390/configs/defconfig       |   1 -
 fs/nfsd/Kconfig                   |  17 -
 fs/nfsd/netns.h                   |   1 -
 fs/nfsd/nfs4ctl.h                 |   8 +-
 fs/nfsd/nfs4recover.c             | 653 +-------------------------------------
 fs/nfsd/nfsctl.c                  |  79 -----
 fs/nfsd/state.h                   |   4 -
 fs/nfsd/trace.h                   |  19 --
 9 files changed, 3 insertions(+), 780 deletions(-)

diff --git a/arch/s390/configs/debug_defconfig b/arch/s390/configs/debug_defconfig
index 3dae71474333..9f8d3b31bbc3 100644
--- a/arch/s390/configs/debug_defconfig
+++ b/arch/s390/configs/debug_defconfig
@@ -726,7 +726,6 @@ CONFIG_NFSD=m
 CONFIG_NFSD_V3_ACL=y
 CONFIG_NFSD_V4=y
 CONFIG_NFSD_V4_SECURITY_LABEL=y
-# CONFIG_NFSD_LEGACY_CLIENT_TRACKING is not set
 CONFIG_CIFS=m
 CONFIG_CIFS_UPCALL=y
 CONFIG_CIFS_XATTR=y
diff --git a/arch/s390/configs/defconfig b/arch/s390/configs/defconfig
index 6f5722634b4d..579ad7dcfd4b 100644
--- a/arch/s390/configs/defconfig
+++ b/arch/s390/configs/defconfig
@@ -712,7 +712,6 @@ CONFIG_NFSD=m
 CONFIG_NFSD_V3_ACL=y
 CONFIG_NFSD_V4=y
 CONFIG_NFSD_V4_SECURITY_LABEL=y
-# CONFIG_NFSD_LEGACY_CLIENT_TRACKING is not set
 CONFIG_CIFS=m
 CONFIG_CIFS_UPCALL=y
 CONFIG_CIFS_XATTR=y
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index ffb76761d6a8..3e4030b70194 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -5,7 +5,6 @@ config NFSD
 	depends on FILE_LOCKING
 	depends on FSNOTIFY
 	select CRC32
-	select CRYPTO_LIB_MD5 if NFSD_LEGACY_CLIENT_TRACKING
 	select CRYPTO_LIB_SHA256 if NFSD_V4
 	select CRYPTO # required by RPCSEC_GSS_KRB5 and signed filehandles
 	select LOCKD
@@ -161,22 +160,6 @@ config NFSD_V4_SECURITY_LABEL
 	If you do not wish to enable fine-grained security labels SELinux or
 	Smack policies on NFSv4 files, say N.
 
-config NFSD_LEGACY_CLIENT_TRACKING
-	bool "Support legacy NFSv4 client tracking methods (DEPRECATED)"
-	depends on NFSD_V4
-	default n
-	help
-	  The NFSv4 server needs to store a small amount of information on
-	  stable storage in order to handle state recovery after reboot. Most
-	  modern deployments upcall to a userland daemon for this (nfsdcld),
-	  but older NFS servers may store information directly in a
-	  recoverydir, or spawn a process directly using a usermodehelper
-	  upcall.
-
-	  These legacy client tracking methods have proven to be problematic
-	  and will be removed in the future. Say Y here if you need support
-	  for them in the interim.
-
 config NFSD_V4_POSIX_ACLS
 	bool "Support NFSv4 POSIX draft ACLs"
 	depends on NFSD_V4
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index c1b068b63edd..1d32846b1836 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -135,7 +135,6 @@ struct nfsd_net {
 	/* protects blocked_locks_lru */
 	spinlock_t blocked_locks_lock;
 
-	struct file *rec_file;
 	const struct nfsd4_client_tracking_ops *client_tracking_ops;
 
 	time64_t nfsd4_lease;
diff --git a/fs/nfsd/nfs4ctl.h b/fs/nfsd/nfs4ctl.h
index bcec4c4ef1d5..e0d1246ca337 100644
--- a/fs/nfsd/nfs4ctl.h
+++ b/fs/nfsd/nfs4ctl.h
@@ -1,8 +1,8 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /*
  * Entry points by which the knfsd core drives the optional NFSv4
- * subsystem: state lifecycle, the laundromat workqueue, the recovery
- * directory, junctions, the CLD notifier, and leases-net setup.
+ * subsystem: state lifecycle, the laundromat workqueue, junctions,
+ * the CLD notifier, and leases-net setup.
  *
  * Separated from nfsd.h so that the many translation units that
  * include nfsd.h but call none of these -- among them the NFSv2 and
@@ -31,8 +31,6 @@ int nfs4_state_start(void);
 int nfs4_state_start_net(struct net *net);
 void nfs4_state_shutdown(void);
 void nfs4_state_shutdown_net(struct net *net);
-int nfs4_reset_recoverydir(char *recdir);
-char * nfs4_recoverydir(void);
 bool nfsd4_spo_must_allow(struct svc_rqst *rqstp);
 int nfsd4_create_laundry_wq(void);
 void nfsd4_destroy_laundry_wq(void);
@@ -54,8 +52,6 @@ static inline int nfs4_state_start(void) { return 0; }
 static inline int nfs4_state_start_net(struct net *net) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
 static inline void nfs4_state_shutdown_net(struct net *net) { }
-static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
-static inline char * nfs4_recoverydir(void) {return NULL; }
 static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 {
 	return false;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ecf8ced8074a..4df7940a2d59 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -32,7 +32,6 @@
 *
 */
 
-#include <crypto/md5.h>
 #include <crypto/sha2.h>
 #include <linux/file.h>
 #include <linux/slab.h>
@@ -69,566 +68,6 @@ struct nfsd4_client_tracking_ops {
 static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops;
 static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops_v2;
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-/* Globals */
-static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
-
-static int
-nfs4_save_creds(const struct cred **original_creds)
-{
-	struct cred *new;
-
-	new = prepare_creds();
-	if (!new)
-		return -ENOMEM;
-
-	new->fsuid = GLOBAL_ROOT_UID;
-	new->fsgid = GLOBAL_ROOT_GID;
-	*original_creds = override_creds(new);
-	return 0;
-}
-
-static void
-nfs4_reset_creds(const struct cred *original)
-{
-	put_cred(revert_creds(original));
-}
-
-static void
-nfs4_make_rec_clidname(char dname[HEXDIR_LEN], const struct xdr_netobj *clname)
-{
-	u8 digest[MD5_DIGEST_SIZE];
-
-	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
-			clname->len, clname->data);
-
-	md5(clname->data, clname->len, digest);
-
-	static_assert(HEXDIR_LEN == 2 * MD5_DIGEST_SIZE + 1);
-	sprintf(dname, "%*phN", MD5_DIGEST_SIZE, digest);
-}
-
-static void
-__nfsd4_create_reclaim_record_grace(struct nfs4_client *clp,
-				    char *dname, struct nfsd_net *nn)
-{
-	struct xdr_netobj name = { .len = strlen(dname), .data = dname };
-	struct xdr_netobj princhash = { .len = 0, .data = NULL };
-	struct nfs4_client_reclaim *crp;
-
-	crp = nfs4_client_to_reclaim(name, princhash, nn);
-	crp->cr_clp = clp;
-}
-
-static void
-nfsd4_create_clid_dir(struct nfs4_client *clp)
-{
-	const struct cred *original_cred;
-	char dname[HEXDIR_LEN];
-	struct dentry *dir, *dentry;
-	int status;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return;
-	if (!nn->rec_file)
-		return;
-
-	nfs4_make_rec_clidname(dname, &clp->cl_name);
-
-	status = nfs4_save_creds(&original_cred);
-	if (status < 0)
-		return;
-
-	status = mnt_want_write_file(nn->rec_file);
-	if (status)
-		goto out_creds;
-
-	dir = nn->rec_file->f_path.dentry;
-
-	dentry = start_creating(&nop_mnt_idmap, dir, &QSTR(dname));
-	if (IS_ERR(dentry)) {
-		status = PTR_ERR(dentry);
-		goto out;
-	}
-	if (d_really_is_positive(dentry))
-		/*
-		 * In the 4.1 case, where we're called from
-		 * reclaim_complete(), records from the previous reboot
-		 * may still be left, so this is OK.
-		 *
-		 * In the 4.0 case, we should never get here; but we may
-		 * as well be forgiving and just succeed silently.
-		 */
-		goto out_end;
-	dentry = vfs_mkdir(&nop_mnt_idmap, d_inode(dir), dentry, 0700, NULL);
-	if (IS_ERR(dentry))
-		status = PTR_ERR(dentry);
-out_end:
-	end_creating(dentry);
-out:
-	if (status == 0) {
-		if (test_bit(NFSD_NET_IN_GRACE, &nn->flags))
-			__nfsd4_create_reclaim_record_grace(clp, dname, nn);
-		vfs_fsync(nn->rec_file, 0);
-	} else {
-		printk(KERN_ERR "NFSD: failed to write recovery record"
-				" (err %d); please check that %s exists"
-				" and is writeable", status,
-				user_recovery_dirname);
-	}
-	mnt_drop_write_file(nn->rec_file);
-out_creds:
-	nfs4_reset_creds(original_cred);
-}
-
-typedef int (recdir_func)(struct dentry *, char *, struct nfsd_net *);
-
-struct name_list {
-	char name[HEXDIR_LEN];
-	struct list_head list;
-};
-
-struct nfs4_dir_ctx {
-	struct dir_context ctx;
-	struct list_head names;
-};
-
-static bool
-nfsd4_build_namelist(struct dir_context *__ctx, const char *name, int namlen,
-		loff_t offset, u64 ino, unsigned int d_type)
-{
-	struct nfs4_dir_ctx *ctx =
-		container_of(__ctx, struct nfs4_dir_ctx, ctx);
-	struct name_list *entry;
-
-	if (namlen != HEXDIR_LEN - 1)
-		return true;
-	entry = kmalloc_obj(struct name_list);
-	if (entry == NULL)
-		return false;
-	memcpy(entry->name, name, HEXDIR_LEN - 1);
-	entry->name[HEXDIR_LEN - 1] = '\0';
-	list_add(&entry->list, &ctx->names);
-	return true;
-}
-
-static int
-nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
-{
-	const struct cred *original_cred;
-	struct dentry *dir = nn->rec_file->f_path.dentry;
-	struct nfs4_dir_ctx ctx = {
-		.ctx.actor = nfsd4_build_namelist,
-		.names = LIST_HEAD_INIT(ctx.names)
-	};
-	struct name_list *entry, *tmp;
-	int status;
-
-	status = nfs4_save_creds(&original_cred);
-	if (status < 0)
-		return status;
-
-	status = vfs_llseek(nn->rec_file, 0, SEEK_SET);
-	if (status < 0) {
-		nfs4_reset_creds(original_cred);
-		return status;
-	}
-
-	status = iterate_dir(nn->rec_file, &ctx.ctx);
-
-	list_for_each_entry_safe(entry, tmp, &ctx.names, list) {
-		if (!status)
-			status = f(dir, entry->name, nn);
-
-		list_del(&entry->list);
-		kfree(entry);
-	}
-	nfs4_reset_creds(original_cred);
-
-	list_for_each_entry_safe(entry, tmp, &ctx.names, list) {
-		dprintk("NFSD: %s. Left entry %s\n", __func__, entry->name);
-		list_del(&entry->list);
-		kfree(entry);
-	}
-	return status;
-}
-
-static int
-nfsd4_unlink_clid_dir(char *name, struct nfsd_net *nn)
-{
-	struct dentry *dir, *dentry;
-	int status;
-
-	dprintk("NFSD: nfsd4_unlink_clid_dir. name %s\n", name);
-
-	dir = nn->rec_file->f_path.dentry;
-	dentry = start_removing(&nop_mnt_idmap, dir, &QSTR(name));
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-
-	status = vfs_rmdir(&nop_mnt_idmap, d_inode(dir), dentry, NULL);
-	end_removing(dentry);
-	return status;
-}
-
-static void
-__nfsd4_remove_reclaim_record_grace(const char *dname, int len,
-		struct nfsd_net *nn)
-{
-	struct xdr_netobj name;
-	struct nfs4_client_reclaim *crp;
-
-	name.data = kmemdup(dname, len, GFP_KERNEL);
-	if (!name.data) {
-		dprintk("%s: failed to allocate memory for name.data!\n",
-			__func__);
-		return;
-	}
-	name.len = len;
-	down_write(&nn->reclaim_str_hashtbl_lock);
-	crp = nfsd4_find_reclaim_client(name, nn);
-	if (crp)
-		nfs4_remove_reclaim_record(crp, nn);
-	up_write(&nn->reclaim_str_hashtbl_lock);
-	kfree(name.data);
-}
-
-static void
-nfsd4_remove_clid_dir(struct nfs4_client *clp)
-{
-	const struct cred *original_cred;
-	char dname[HEXDIR_LEN];
-	int status;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	if (!nn->rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return;
-
-	nfs4_make_rec_clidname(dname, &clp->cl_name);
-
-	status = mnt_want_write_file(nn->rec_file);
-	if (status)
-		goto out;
-	clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-
-	status = nfs4_save_creds(&original_cred);
-	if (status < 0)
-		goto out_drop_write;
-
-	status = nfsd4_unlink_clid_dir(dname, nn);
-	nfs4_reset_creds(original_cred);
-	if (status == 0) {
-		vfs_fsync(nn->rec_file, 0);
-		if (test_bit(NFSD_NET_IN_GRACE, &nn->flags))
-			__nfsd4_remove_reclaim_record_grace(dname,
-					HEXDIR_LEN, nn);
-	}
-out_drop_write:
-	mnt_drop_write_file(nn->rec_file);
-out:
-	if (status)
-		printk("NFSD: Failed to remove expired client state directory"
-				" %.*s\n", HEXDIR_LEN, dname);
-}
-
-static int
-purge_old(struct dentry *parent, char *cname, struct nfsd_net *nn)
-{
-	int status;
-	struct dentry *child;
-	struct xdr_netobj name;
-
-	if (strlen(cname) != HEXDIR_LEN - 1) {
-		printk("%s: illegal name %s in recovery directory\n",
-				__func__, cname);
-		/* Keep trying; maybe the others are OK: */
-		return 0;
-	}
-	name.data = kstrdup(cname, GFP_KERNEL);
-	if (!name.data) {
-		dprintk("%s: failed to allocate memory for name.data!\n",
-			__func__);
-		goto out;
-	}
-	name.len = HEXDIR_LEN;
-	if (nfs4_has_reclaimed_state(name, nn))
-		goto out_free;
-
-	child = start_removing_noperm(parent, &QSTR(cname));
-	if (!IS_ERR(child)) {
-		status = vfs_rmdir(&nop_mnt_idmap, d_inode(parent), child, NULL);
-		if (status)
-			printk("failed to remove client recovery directory %pd\n",
-			       child);
-	}
-	end_removing(child);
-
-out_free:
-	kfree(name.data);
-out:
-	/* Keep trying, success or failure: */
-	return 0;
-}
-
-static void
-nfsd4_recdir_purge_old(struct nfsd_net *nn)
-{
-	int status;
-
-	clear_bit(NFSD_NET_IN_GRACE, &nn->flags);
-	if (!nn->rec_file)
-		return;
-	status = mnt_want_write_file(nn->rec_file);
-	if (status)
-		goto out;
-	status = nfsd4_list_rec_dir(purge_old, nn);
-	if (status == 0)
-		vfs_fsync(nn->rec_file, 0);
-	mnt_drop_write_file(nn->rec_file);
-out:
-	nfs4_release_reclaim(nn);
-	if (status)
-		printk("nfsd4: failed to purge old clients from recovery"
-			" directory %pD\n", nn->rec_file);
-}
-
-static int
-load_recdir(struct dentry *parent, char *cname, struct nfsd_net *nn)
-{
-	struct xdr_netobj name = { .len = HEXDIR_LEN, .data = cname };
-	struct xdr_netobj princhash = { .len = 0, .data = NULL };
-
-	if (strlen(cname) != HEXDIR_LEN - 1) {
-		printk("%s: illegal name %s in recovery directory\n",
-				__func__, cname);
-		/* Keep trying; maybe the others are OK: */
-		return 0;
-	}
-	nfs4_client_to_reclaim(name, princhash, nn);
-	return 0;
-}
-
-static int
-nfsd4_recdir_load(struct net *net) {
-	int status;
-	struct nfsd_net *nn =  net_generic(net, nfsd_net_id);
-
-	if (!nn->rec_file)
-		return 0;
-
-	status = nfsd4_list_rec_dir(load_recdir, nn);
-	if (status)
-		printk("nfsd4: failed loading clients from recovery"
-			" directory %pD\n", nn->rec_file);
-	return status;
-}
-
-/*
- * Hold reference to the recovery directory.
- */
-
-static int
-nfsd4_init_recdir(struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	const struct cred *original_cred;
-	int status;
-
-	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
-			user_recovery_dirname);
-
-	BUG_ON(nn->rec_file);
-
-	status = nfs4_save_creds(&original_cred);
-	if (status < 0) {
-		printk("NFSD: Unable to change credentials to find recovery"
-		       " directory: error %d\n",
-		       status);
-		return status;
-	}
-
-	nn->rec_file = filp_open(user_recovery_dirname, O_RDONLY | O_DIRECTORY, 0);
-	if (IS_ERR(nn->rec_file)) {
-		printk("NFSD: unable to find recovery directory %s\n",
-				user_recovery_dirname);
-		status = PTR_ERR(nn->rec_file);
-		nn->rec_file = NULL;
-	}
-
-	nfs4_reset_creds(original_cred);
-	if (!status)
-		set_bit(NFSD_NET_IN_GRACE, &nn->flags);
-	return status;
-}
-
-static void
-nfsd4_shutdown_recdir(struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-
-	if (!nn->rec_file)
-		return;
-	fput(nn->rec_file);
-	nn->rec_file = NULL;
-}
-
-static int
-nfs4_legacy_state_init(struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	int i;
-
-	nn->reclaim_str_hashtbl = kmalloc_objs(struct list_head,
-					       CLIENT_HASH_SIZE);
-	if (!nn->reclaim_str_hashtbl)
-		return -ENOMEM;
-
-	for (i = 0; i < CLIENT_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
-	nn->reclaim_str_hashtbl_size = 0;
-	init_rwsem(&nn->reclaim_str_hashtbl_lock);
-
-	return 0;
-}
-
-static void
-nfs4_legacy_state_shutdown(struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-
-	kfree(nn->reclaim_str_hashtbl);
-}
-
-static int
-nfsd4_load_reboot_recovery_data(struct net *net)
-{
-	int status;
-
-	status = nfsd4_init_recdir(net);
-	if (status)
-		return status;
-
-	status = nfsd4_recdir_load(net);
-	if (status)
-		nfsd4_shutdown_recdir(net);
-
-	return status;
-}
-
-static int
-nfsd4_legacy_tracking_init(struct net *net)
-{
-	int status;
-
-	/* XXX: The legacy code won't work in a container */
-	if (net != &init_net) {
-		pr_warn("NFSD: attempt to initialize legacy client tracking in a container ignored.\n");
-		return -EINVAL;
-	}
-
-	status = nfs4_legacy_state_init(net);
-	if (status)
-		return status;
-
-	status = nfsd4_load_reboot_recovery_data(net);
-	if (status)
-		goto err;
-	pr_info("NFSD: Using legacy client tracking operations.\n");
-	return 0;
-
-err:
-	nfs4_legacy_state_shutdown(net);
-	return status;
-}
-
-static void
-nfsd4_legacy_tracking_exit(struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-
-	nfs4_release_reclaim(nn);
-	nfsd4_shutdown_recdir(net);
-	nfs4_legacy_state_shutdown(net);
-}
-
-/*
- * Change the NFSv4 recovery directory to recdir.
- */
-int
-nfs4_reset_recoverydir(char *recdir)
-{
-	int status;
-	struct path path;
-
-	status = kern_path(recdir, LOOKUP_FOLLOW, &path);
-	if (status)
-		return status;
-	status = -ENOTDIR;
-	if (d_is_dir(path.dentry)) {
-		strscpy(user_recovery_dirname, recdir,
-			sizeof(user_recovery_dirname));
-		status = 0;
-	}
-	path_put(&path);
-	return status;
-}
-
-char *
-nfs4_recoverydir(void)
-{
-	return user_recovery_dirname;
-}
-
-static int
-nfsd4_check_legacy_client(struct nfs4_client *clp)
-{
-	char dname[HEXDIR_LEN];
-	struct nfs4_client_reclaim *crp;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-	struct xdr_netobj name;
-
-	/* did we already find that this client is stable? */
-	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return 0;
-
-	nfs4_make_rec_clidname(dname, &clp->cl_name);
-
-	/* look for it in the reclaim hashtable otherwise */
-	name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
-	if (!name.data) {
-		dprintk("%s: failed to allocate memory for name.data!\n",
-			__func__);
-		goto out_enoent;
-	}
-	name.len = HEXDIR_LEN;
-	down_read(&nn->reclaim_str_hashtbl_lock);
-	crp = nfsd4_find_reclaim_client(name, nn);
-	if (crp) {
-		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-		crp->cr_clp = clp;
-	}
-	up_read(&nn->reclaim_str_hashtbl_lock);
-	kfree(name.data);
-	if (crp)
-		return 0;
-
-out_enoent:
-	return -ENOENT;
-}
-
-static const struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
-	.init		= nfsd4_legacy_tracking_init,
-	.exit		= nfsd4_legacy_tracking_exit,
-	.create		= nfsd4_create_clid_dir,
-	.remove		= nfsd4_remove_clid_dir,
-	.check		= nfsd4_check_legacy_client,
-	.grace_done	= nfsd4_recdir_purge_old,
-	.version	= 1,
-	.msglen		= 0,
-};
-#endif /* CONFIG_NFSD_LEGACY_CLIENT_TRACKING */
-
 /* Globals */
 #define NFSD_PIPE_DIR		"nfsd"
 #define NFSD_CLD_PIPE		"cld"
@@ -639,9 +78,6 @@ struct cld_net {
 	spinlock_t		 cn_lock;
 	struct list_head	 cn_list;
 	unsigned int		 cn_xid;
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	bool			 cn_has_legacy;
-#endif
 };
 
 struct cld_upcall {
@@ -761,15 +197,6 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 			name.data = namecopy;
 			name.len = namelen;
 		}
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-		if (name.len > 5 && memcmp(name.data, "hash:", 5) == 0) {
-			struct cld_net *cn = nn->cld_net;
-
-			name.len = name.len - 5;
-			name.data = name.data + 5;
-			cn->cn_has_legacy = true;
-		}
-#endif
 		if (!nfs4_client_to_reclaim(name, princhash, nn))
 			return -EFAULT;
 		return nn->client_tracking_ops->msglen;
@@ -965,9 +392,6 @@ __nfsd4_init_cld_pipe(struct net *net)
 	}
 	spin_lock_init(&cn->cn_lock);
 	INIT_LIST_HEAD(&cn->cn_list);
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	cn->cn_has_legacy = false;
-#endif
 
 	/*
 	 * The pipe's methods reach @cn through nn->cld_net, so set
@@ -1243,28 +667,6 @@ nfsd4_cld_check(struct nfs4_client *clp)
 	if (crp)
 		goto found;
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	if (nn->cld_net->cn_has_legacy) {
-		char dname[HEXDIR_LEN];
-		struct xdr_netobj name;
-
-		nfs4_make_rec_clidname(dname, &clp->cl_name);
-
-		name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
-		if (!name.data) {
-			dprintk("%s: failed to allocate memory for name.data!\n",
-				__func__);
-			up_read(&nn->reclaim_str_hashtbl_lock);
-			return -ENOENT;
-		}
-		name.len = HEXDIR_LEN;
-		crp = nfsd4_find_reclaim_client(name, nn);
-		kfree(name.data);
-		if (crp)
-			goto found;
-
-	}
-#endif
 	up_read(&nn->reclaim_str_hashtbl_lock);
 	return -ENOENT;
 found:
@@ -1277,9 +679,6 @@ static int
 nfsd4_cld_check_v2(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	struct cld_net *cn = nn->cld_net;
-#endif
 	struct nfs4_client_reclaim *crp;
 	unsigned int princhashlen;
 	char *principal = NULL;
@@ -1294,28 +693,6 @@ nfsd4_cld_check_v2(struct nfs4_client *clp)
 	if (crp)
 		goto found;
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	if (cn->cn_has_legacy) {
-		struct xdr_netobj name;
-		char dname[HEXDIR_LEN];
-
-		nfs4_make_rec_clidname(dname, &clp->cl_name);
-
-		name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
-		if (!name.data) {
-			dprintk("%s: failed to allocate memory for name.data\n",
-					__func__);
-			up_read(&nn->reclaim_str_hashtbl_lock);
-			return -ENOENT;
-		}
-		name.len = HEXDIR_LEN;
-		crp = nfsd4_find_reclaim_client(name, nn);
-		kfree(name.data);
-		if (crp)
-			goto found;
-
-	}
-#endif
 	up_read(&nn->reclaim_str_hashtbl_lock);
 	return -ENOENT;
 found:
@@ -1610,33 +987,6 @@ static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops_v2 = {
 	.msglen		= sizeof(struct cld_msg_v2),
 };
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-static inline int check_for_legacy_methods(int status, struct net *net)
-{
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	struct path path;
-
-	/*
-	 * See if the recoverydir exists and is a directory.
-	 * If it is, then use the legacy ops.
-	 */
-	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
-	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
-	if (!status) {
-		status = !d_is_dir(path.dentry);
-		path_put(&path);
-		if (status)
-			return -ENOTDIR;
-	}
-	return status;
-}
-#else
-static inline int check_for_legacy_methods(int status, struct net *net)
-{
-	return status;
-}
-#endif /* CONFIG_LEGACY_NFSD_CLIENT_TRACKING */
-
 int
 nfsd4_client_tracking_init(struct net *net)
 {
@@ -1659,7 +1009,6 @@ nfsd4_client_tracking_init(struct net *net)
 			return status;
 	}
 
-	status = check_for_legacy_methods(status, net);
 	if (status)
 		goto out;
 do_init:
@@ -1667,7 +1016,7 @@ nfsd4_client_tracking_init(struct net *net)
 out:
 	if (status) {
 		pr_warn("NFSD: Unable to initialize client recovery tracking! (%d)\n", status);
-		pr_warn("NFSD: Is nfsdcld running? If not, enable CONFIG_NFSD_LEGACY_CLIENT_TRACKING.\n");
+		pr_warn("NFSD: Is nfsdcld running?\n");
 		nn->client_tracking_ops = NULL;
 	}
 	return status;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e2455a549e25..2ea9c43eb206 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -57,7 +57,6 @@ enum {
 	NFSD_Filecache,
 	NFSD_Leasetime,
 	NFSD_Gracetime,
-	NFSD_RecoveryDir,
 	NFSD_V4EndGrace,
 	NFSD_MaxReserved
 };
@@ -76,9 +75,6 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size);
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
-#endif
 static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size);
 #endif
 
@@ -94,9 +90,6 @@ static ssize_t (*const write_op[])(struct file *, char *, size_t) = {
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_Gracetime] = write_gracetime,
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	[NFSD_RecoveryDir] = write_recoverydir,
-#endif
 	[NFSD_V4EndGrace] = write_v4_end_grace,
 #endif
 };
@@ -1031,75 +1024,6 @@ static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
 	return nfsd4_write_time(file, buf, size, &nn->nfsd4_grace, nn);
 }
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size,
-				   struct nfsd_net *nn)
-{
-	char *mesg = buf;
-	char *recdir;
-	int len, status;
-
-	if (size > 0) {
-		if (nn->nfsd_serv)
-			return -EBUSY;
-		if (size > PATH_MAX || buf[size-1] != '\n')
-			return -EINVAL;
-		buf[size-1] = 0;
-
-		recdir = mesg;
-		len = qword_get(&mesg, recdir, size);
-		if (len <= 0)
-			return -EINVAL;
-		trace_nfsd_ctl_recoverydir(netns(file), recdir);
-
-		status = nfs4_reset_recoverydir(recdir);
-		if (status)
-			return status;
-	}
-
-	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%s\n",
-							nfs4_recoverydir());
-}
-
-/*
- * write_recoverydir - Set or report the pathname of the recovery directory
- *
- * Input:
- *			buf:		ignored
- *			size:		zero
- *
- * OR
- *
- * Input:
- *			buf:		C string containing the pathname
- *					of the directory on a local file
- *					system containing permanent NFSv4
- *					recovery data
- *			size:		non-zero length of C string in @buf
- * Output:
- *	On success:	passed-in buffer filled with '\n'-terminated C string
- *			containing the current recovery pathname setting;
- *			return code is the size in bytes of the string
- *	On error:	return code is zero or a negative errno value
- */
-static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
-{
-	ssize_t rv;
-	struct nfsd_net *nn = net_generic(netns(file), nfsd_net_id);
-
-	/*
-	 * nn->nfsd_mutex guards the nn->nfsd_serv check; the recovery
-	 * dirname itself is still shared between namespaces.
-	 */
-	mutex_lock(&nn->nfsd_mutex);
-	mutex_lock(&nfsd_global_mutex);
-	rv = __write_recoverydir(file, buf, size, nn);
-	mutex_unlock(&nfsd_global_mutex);
-	mutex_unlock(&nn->nfsd_mutex);
-	return rv;
-}
-#endif
-
 /*
  * write_v4_end_grace - release grace period for nfsd's v4.x lock manager
  *
@@ -1342,9 +1266,6 @@ static int nfsd_fill_super(struct super_block *sb, struct fs_context *fc)
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Gracetime] = {"nfsv4gracetime", &transaction_ops, S_IWUSR|S_IRUSR},
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
-#endif
 		[NFSD_V4EndGrace] = {"v4_end_grace", &transaction_ops, S_IWUSR|S_IRUGO},
 #endif
 		/* last one */ {""}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f024bb..7803945708d6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -35,7 +35,6 @@
 #ifndef _NFSD4_STATE_H
 #define _NFSD4_STATE_H
 
-#include <crypto/md5.h>
 
 #include <linux/filelock.h>
 #include <linux/idr.h>
@@ -500,9 +499,6 @@ struct nfsd4_sessionid {
 	u32		reserved;
 };
 
-/* Length of MD5 digest as hex, plus terminating '\0' */
-#define HEXDIR_LEN	(2 * MD5_DIGEST_SIZE + 1)
-
 /*
  *       State                Meaning                  Where set
  * --------------------------------------------------------------------------
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 1febb42a008f..ad106d627fe7 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -2310,25 +2310,6 @@ TRACE_EVENT(nfsd_ctl_time,
 	)
 );
 
-TRACE_EVENT(nfsd_ctl_recoverydir,
-	TP_PROTO(
-		const struct net *net,
-		const char *recdir
-	),
-	TP_ARGS(net, recdir),
-	TP_STRUCT__entry(
-		__field(unsigned int, netns_ino)
-		__string(recdir, recdir)
-	),
-	TP_fast_assign(
-		__entry->netns_ino = net->ns.inum;
-		__assign_str(recdir);
-	),
-	TP_printk("recdir=%s",
-		__get_str(recdir)
-	)
-);
-
 TRACE_EVENT(nfsd_end_grace,
 	TP_PROTO(
 		const struct net *net

-- 
2.55.0

