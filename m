Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 767723E49C7
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 16:23:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784650991; cv=none; b=p0xZ+wVqAJXHQOiR17kT5CGNXBykMZ5Nj17JpEe9k7iDxEERhToUCnBkVcd/n3t0gN+t5IUvqVW+3TlneoXll0MuVEOSnjs7+OAtZDV4TIxq2o6mnW5+EbRzEhOWUoldOQ0cNZh17KBUVEkIzq4xiRDeArX7GjoRCsyOmUPIe2Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784650991; c=relaxed/simple;
	bh=LoOGbx2u8O3JWWvW1lV1wpNqtnZuGq5VaQO+y2lgWbA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JJAfUSRIVkmuJnv1/zR1nbCvGD4Bs82YUGc/Q4K0G0jfRxO71hQBp+EVeGHnT+QYYG2Y5KC7qTlmeWSggkIkOe7kLo+ut1yQ18p4eOl+aTeTAlAIUYgf5W12Ue2o1sZY4IOaA7EtRjz3bofC4DkiIbMh7Opga6gQhd6EJYy8CIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W9muWOYY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W9muWOYY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A0EDB1F000E9;
	Tue, 21 Jul 2026 16:23:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784650990;
	bh=dP6uRI4Y8Y5rnKAU426UJ897Nhv6g5a8qAPkhRF9XvY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W9muWOYYi4o6vo8dbk0vTpNY/NMuA4PEjL5/3Qsk3K5OjB6WNq8OOT+3HC++DQs6P
	 CTYOixDKBEcbU0qJGkJpZ0R33NbSeZJzPsX/fyLAVt7ofqyokRWTuTCt0ktfC5v4Lh
	 UU3nEnzOW2v4K6cHlROEDlRQM0J8aYxleRcRicpFOYHEReo1M2u51V/YzNM5oDm4Br
	 ANqzf59vX30I+aCMJitfBko3a9JcbpHmqUTpdhuhn7eaOpNDTPMbEtBQm8pS+2mTdB
	 yZvsZt/0h2KZbDJQDOfZDM+5FnYtPnlOl2V35JosXXhRj+gk+Rk/5qnqbvsFmg85EZ
	 QZAIIpmDfHQeQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] nfs_common: Remove unused nfs_ssc_client_ops infrastructure
Date: Tue, 21 Jul 2026 12:23:03 -0400
Message-ID: <20260721162306.894558-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260721162306.894558-1-cel@kernel.org>
References: <20260721162306.894558-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: Commit 75333d48f922 ("NFSD: fix use-after-free in
__nfs42_ssc_open()") addressed a use-after-free bug by removing the
nfsd4_interssc_disconnect() function. Post-copy clean-up was then
delegated to NFSD's laundromat.

Since that commit, the nfs_do_sb_deactive() wrapper function and the
entire nfs_ssc_client_ops infrastructure no longer have any
consumers. This includes nfs_do_sb_deactive(), struct
nfs_ssc_client_ops, nfs_ssc_register(), nfs_ssc_unregister(), and
related registrations in the NFS client.

Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/super.c          | 25 ------------------------
 fs/nfs_common/nfs_ssc.c | 42 -----------------------------------------
 fs/nfsd/nfs4proc.c      |  2 --
 include/linux/nfs_ssc.h | 20 --------------------
 4 files changed, 89 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cb19f1540d98..23292680adbd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -58,7 +58,6 @@
 #include <linux/rcupdate.h>
 
 #include <linux/uaccess.h>
-#include <linux/nfs_ssc.h>
 
 #include <uapi/linux/tls.h>
 
@@ -92,12 +91,6 @@ const struct super_operations nfs_sops = {
 };
 EXPORT_SYMBOL_GPL(nfs_sops);
 
-#ifdef CONFIG_NFS_V4_2
-static const struct nfs_ssc_client_ops nfs_ssc_clnt_ops_tbl = {
-	.sco_sb_deactive = nfs_sb_deactive,
-};
-#endif
-
 #if IS_ENABLED(CONFIG_NFS_V4)
 static int __init register_nfs4_fs(void)
 {
@@ -119,18 +112,6 @@ static void unregister_nfs4_fs(void)
 }
 #endif
 
-#ifdef CONFIG_NFS_V4_2
-static void nfs_ssc_register_ops(void)
-{
-	nfs_ssc_register(&nfs_ssc_clnt_ops_tbl);
-}
-
-static void nfs_ssc_unregister_ops(void)
-{
-	nfs_ssc_unregister(&nfs_ssc_clnt_ops_tbl);
-}
-#endif /* CONFIG_NFS_V4_2 */
-
 static struct shrinker *acl_shrinker;
 
 /*
@@ -163,9 +144,6 @@ int __init register_nfs_fs(void)
 
 	shrinker_register(acl_shrinker);
 
-#ifdef CONFIG_NFS_V4_2
-	nfs_ssc_register_ops();
-#endif
 	return 0;
 error_3:
 	nfs_unregister_sysctl();
@@ -185,9 +163,6 @@ void __exit unregister_nfs_fs(void)
 	shrinker_free(acl_shrinker);
 	nfs_unregister_sysctl();
 	unregister_nfs4_fs();
-#ifdef CONFIG_NFS_V4_2
-	nfs_ssc_unregister_ops();
-#endif
 	unregister_filesystem(&nfs_fs_type);
 }
 
diff --git a/fs/nfs_common/nfs_ssc.c b/fs/nfs_common/nfs_ssc.c
index 832246b22c51..8d8b7344ab4f 100644
--- a/fs/nfs_common/nfs_ssc.c
+++ b/fs/nfs_common/nfs_ssc.c
@@ -47,45 +47,3 @@ void nfs42_ssc_unregister(const struct nfs4_ssc_client_ops *ops)
 }
 EXPORT_SYMBOL_GPL(nfs42_ssc_unregister);
 #endif /* CONFIG_NFS_V4_2 */
-
-#ifdef CONFIG_NFS_V4_2
-/**
- * nfs_ssc_register - install the NFS_FS client ops in the nfs_ssc_client_tbl
- * @ops: NFS_FS ops to be installed
- *
- * Return values:
- *   None
- */
-void nfs_ssc_register(const struct nfs_ssc_client_ops *ops)
-{
-	nfs_ssc_client_tbl.ssc_nfs_ops = ops;
-}
-EXPORT_SYMBOL_GPL(nfs_ssc_register);
-
-/**
- * nfs_ssc_unregister - uninstall the NFS_FS client ops from
- *				the nfs_ssc_client_tbl
- * @ops: ops to be uninstalled
- *
- * Return values:
- *   None
- */
-void nfs_ssc_unregister(const struct nfs_ssc_client_ops *ops)
-{
-	if (nfs_ssc_client_tbl.ssc_nfs_ops != ops)
-		return;
-	nfs_ssc_client_tbl.ssc_nfs_ops = NULL;
-}
-EXPORT_SYMBOL_GPL(nfs_ssc_unregister);
-
-#else
-void nfs_ssc_register(const struct nfs_ssc_client_ops *ops)
-{
-}
-EXPORT_SYMBOL_GPL(nfs_ssc_register);
-
-void nfs_ssc_unregister(const struct nfs_ssc_client_ops *ops)
-{
-}
-EXPORT_SYMBOL_GPL(nfs_ssc_unregister);
-#endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b7d745020fd1..83715ba38b6a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1697,8 +1697,6 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 				   nfs4_stateid *stateid);
 extern void nfs42_ssc_close(struct file *filep);
 
-extern void nfs_sb_deactive(struct super_block *sb);
-
 #define NFSD42_INTERSSC_MOUNTOPS "vers=4.2,addr=%s,sec=sys"
 
 /*
diff --git a/include/linux/nfs_ssc.h b/include/linux/nfs_ssc.h
index 22265b1ff080..ba236dba8975 100644
--- a/include/linux/nfs_ssc.h
+++ b/include/linux/nfs_ssc.h
@@ -21,16 +21,8 @@ struct nfs4_ssc_client_ops {
 	void (*sco_close)(struct file *filep);
 };
 
-/*
- * NFS_FS
- */
-struct nfs_ssc_client_ops {
-	void (*sco_sb_deactive)(struct super_block *sb);
-};
-
 struct nfs_ssc_client_ops_tbl {
 	const struct nfs4_ssc_client_ops *ssc_nfs4_ops;
-	const struct nfs_ssc_client_ops *ssc_nfs_ops;
 };
 
 extern void nfs42_ssc_register_ops(void);
@@ -67,15 +59,3 @@ struct nfsd4_ssc_umount_item {
 	struct vfsmount *nsui_vfsmount;
 	char nsui_ipaddr[RPC_MAX_ADDRBUFLEN + 1];
 };
-
-/*
- * NFS_FS
- */
-extern void nfs_ssc_register(const struct nfs_ssc_client_ops *ops);
-extern void nfs_ssc_unregister(const struct nfs_ssc_client_ops *ops);
-
-static inline void nfs_do_sb_deactive(struct super_block *sb)
-{
-	if (nfs_ssc_client_tbl.ssc_nfs_ops)
-		(*nfs_ssc_client_tbl.ssc_nfs_ops->sco_sb_deactive)(sb);
-}
-- 
2.54.0

